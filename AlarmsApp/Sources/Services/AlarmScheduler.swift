import Foundation
import AVFoundation
import AudioToolbox
import Observation

@Observable
final class AlarmScheduler {
    private(set) var firingAlarm: Alarm? = nil

    private var timer: Timer?
    private var player: AVAudioPlayer?

    func start(watching store: AlarmStore) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick(store: store)
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        stopSound()
        firingAlarm = nil
    }

    func dismissFiringAlarm() {
        stopSound()
        firingAlarm = nil
    }

    private func tick(store: AlarmStore) {
        guard firingAlarm == nil else { return }

        let now = Calendar.current.dateComponents([.hour, .minute], from: Date())

        for alarm in store.alarms where alarm.isEnabled {
            let alarmComponents = Calendar.current.dateComponents([.hour, .minute], from: alarm.time)
            if alarmComponents.hour == now.hour && alarmComponents.minute == now.minute {
                fire(alarm: alarm)
                return
            }
        }
    }

    private func fire(alarm: Alarm) {
        firingAlarm = alarm
        play(sound: alarm.sound)
    }

    private func play(sound: AlarmSound) {
        // Use a system sound file bundled with the app. Fallback to a beep via AudioServicesPlaySystemSound.
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

        // No audio file bundled — use a system alert sound as fallback.
        AudioServicesPlaySystemSound(1005)
    }

    private func stopSound() {
        player?.stop()
        player = nil
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}
