import Foundation
import AVFoundation
import AudioToolbox
import Observation

@Observable
@MainActor
final class AlarmScheduler {
    /// The alarm currently being presented to the user, if any.
    private(set) var firingAlarm: Alarm? = nil

    private var timer: Timer?
    private var player: AVAudioPlayer?
    private var audioEngine: AVAudioEngine?
    private var sourceNode: AVAudioSourceNode?
    private weak var store: AlarmStore?
    // If multiple alarms match in the same minute, present them one at a time.
    private var pendingAlarms: [Alarm] = []
    private var lastCheckedMinute: Date?

    /// Starts foreground alarm monitoring against the shared store.
    func start(watching store: AlarmStore) {
        self.store = store
        pendingAlarms.removeAll()
        tick()
        scheduleAlignedTimer()
    }

    /// Stops monitoring and clears any active alarm/audio state.
    func stop() {
        timer?.invalidate()
        timer = nil
        pendingAlarms.removeAll()
        stopSound()
        firingAlarm = nil
    }

    /// Dismisses the current alarm and advances to the next queued match, if any.
    func dismissFiringAlarm() {
        if let alarm = firingAlarm, alarm.recurring == .oneTime {
            store?.disable(id: alarm.id)
        }
        stopSound()
        firingAlarm = nil

        if !pendingAlarms.isEmpty {
            fire(alarm: pendingAlarms.removeFirst())
        }
    }

    // MARK: - Timer

    private func scheduleAlignedTimer() {
        timer?.invalidate()
        let now = Date()
        guard let nextMinute = Calendar.current.nextDate(
            after: now,
            matching: DateComponents(second: 0),
            matchingPolicy: .nextTime
        ) else { return }

        // Fire once at the next minute boundary, then repeat every 60 s.
        let delay = nextMinute.timeIntervalSince(now)
        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.tick()
                self?.startRepeatingTimer()
            }
        }
    }

    private func startRepeatingTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.tick()
            }
        }
    }

    // MARK: - Alarm checking

    private func tick() {
        guard let store else { return }

        let now = Date()
        // Guard against duplicate checks within the same minute if `tick()` gets
        // called more than once around the timer boundary.
        let currentMinute = Calendar.current.dateInterval(of: .minute, for: now)?.start ?? now
        guard currentMinute != lastCheckedMinute else { return }
        lastCheckedMinute = currentMinute

        let matches = store.alarms
            .filter { $0.isEnabled && shouldFire($0, at: now) }
            .sorted(by: alarmSortComparator)

        guard !matches.isEmpty else { return }

        pendingAlarms.append(contentsOf: matches)

        if firingAlarm == nil, !pendingAlarms.isEmpty {
            fire(alarm: pendingAlarms.removeFirst())
        }
    }

    private func shouldFire(_ alarm: Alarm, at now: Date) -> Bool {
        Self.shouldFire(alarm, at: now)
    }

    /// Pure firing logic used both at runtime and in unit tests.
    nonisolated static func shouldFire(_ alarm: Alarm, at now: Date, calendar: Calendar = .current) -> Bool {
        let nowComponents = calendar.dateComponents([.year, .month, .day, .weekday, .hour, .minute], from: now)
        let alarmComponents = calendar.dateComponents([.year, .month, .day, .weekday, .hour, .minute], from: alarm.time)

        guard alarmComponents.hour == nowComponents.hour,
              alarmComponents.minute == nowComponents.minute
        else {
            return false
        }

        switch alarm.recurring {
        case .oneTime:
            return alarmComponents.year == nowComponents.year &&
                alarmComponents.month == nowComponents.month &&
                alarmComponents.day == nowComponents.day
        case .weekly:
            return alarmComponents.weekday == nowComponents.weekday
        case .yearly:
            return alarmComponents.month == nowComponents.month &&
                alarmComponents.day == nowComponents.day
        }
    }

    private var alarmSortComparator: (Alarm, Alarm) -> Bool {
        { lhs, rhs in
            let calendar = Calendar.current
            let lhsComponents = calendar.dateComponents([.hour, .minute], from: lhs.time)
            let rhsComponents = calendar.dateComponents([.hour, .minute], from: rhs.time)
            let lhsMinutes = (lhsComponents.hour ?? 0) * 60 + (lhsComponents.minute ?? 0)
            let rhsMinutes = (rhsComponents.hour ?? 0) * 60 + (rhsComponents.minute ?? 0)
            return lhsMinutes < rhsMinutes
        }
    }

    private func fire(alarm: Alarm) {
        firingAlarm = alarm
        play(sound: alarm.sound)
    }

    // MARK: - Audio

    private func play(sound: AlarmSound) {
        // Check both the bundle root (flat copy) and the Audio subfolder (folder reference).
        let extensions = ["mp3", "m4a", "wav", "caf"]
        let candidates: [(String, String)] = extensions.flatMap { ext in
            [(sound.rawValue, ext), ("Audio/\(sound.rawValue)", ext)]
        }

        for (name, ext) in candidates {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                try? AVAudioSession.sharedInstance().setCategory(.playback)
                try? AVAudioSession.sharedInstance().setActive(true)
                player = try? AVAudioPlayer(contentsOf: url)
                player?.numberOfLoops = -1
                player?.play()
                return
            }
        }

        playFallbackTone(for: sound)
    }

    private func playFallbackTone(for sound: AlarmSound) {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)

        let sampleRate = 44_100.0
        var phase = 0.0
        let (frequency, amplitude) = fallbackToneProfile(for: sound)

        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)
        let engine = AVAudioEngine()

        guard let format else {
            AudioServicesPlaySystemSound(1005)
            return
        }

        let node = AVAudioSourceNode { _, _, frameCount, audioBufferList in
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let increment = 2.0 * Double.pi * frequency / sampleRate

            for frame in 0..<Int(frameCount) {
                let sample = Float32(sin(phase) * amplitude)
                phase += increment
                if phase >= 2.0 * Double.pi {
                    phase -= 2.0 * Double.pi
                }

                for buffer in ablPointer {
                    let pointer = buffer.mData?.assumingMemoryBound(to: Float32.self)
                    pointer?[frame] = sample
                }
            }

            return noErr
        }

        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: format)

        do {
            try engine.start()
            audioEngine = engine
            sourceNode = node
        } catch {
            audioEngine = nil
            sourceNode = nil
            AudioServicesPlaySystemSound(1005)
        }
    }

    private func fallbackToneProfile(for sound: AlarmSound) -> (frequency: Double, amplitude: Double) {
        switch sound {
        case .party:
            return (880.0, 0.2)
        case .brownNoise:
            return (196.0, 0.14)
        case .ocean:
            return (329.63, 0.12)
        case .whiteNoise:
            return (523.25, 0.1)
        }
    }

    private func stopSound() {
        player?.stop()
        player = nil
        // Detach before stop so the render callback cannot run after the engine halts.
        if let sourceNode {
            audioEngine?.detach(sourceNode)
        }
        audioEngine?.stop()
        sourceNode = nil
        audioEngine = nil
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}
