import Foundation
import AVFoundation
import AudioToolbox
import Observation

@Observable
@MainActor
final class AlarmScheduler {
    private(set) var firingAlarm: Alarm? = nil

    private var timer: Timer?
    private var player: AVAudioPlayer?
    private weak var store: AlarmStore?

    func start(watching store: AlarmStore) {
        self.store = store
        tick()
        scheduleAlignedTimer()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        stopSound()
        firingAlarm = nil
    }

    func dismissFiringAlarm() {
        if let alarm = firingAlarm, alarm.recurring == .oneTime {
            store?.disable(id: alarm.id)
        }
        stopSound()
        firingAlarm = nil
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
        guard firingAlarm == nil, let store else { return }
        let now = Calendar.current.dateComponents([.hour, .minute], from: Date())
        for alarm in store.alarms where alarm.isEnabled {
            let alarmComponents = Calendar.current.dateComponents([.hour, .minute], from: alarm.time)
            guard alarmComponents.hour == now.hour, alarmComponents.minute == now.minute else { continue }
            fire(alarm: alarm)
            return
        }
    }

    private func fire(alarm: Alarm) {
        firingAlarm = alarm
        play(sound: alarm.sound)
    }

    // MARK: - Audio

    private func play(sound: AlarmSound) {
        let candidates: [(String, String)] = [
            (sound.rawValue, "mp3"),
            (sound.rawValue, "wav"),
            (sound.rawValue, "caf"),
        ]

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

        AudioServicesPlaySystemSound(1005)
    }

    private func stopSound() {
        player?.stop()
        player = nil
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}
