import Foundation

enum AlarmSound: String, CaseIterable, Codable {
    case party = "party"
    case brownNoise = "brown-noise"
    case ocean = "ocean"
    case whiteNoise = "white-noise"

    var displayName: String {
        switch self {
        case .party: return "Party"
        case .brownNoise: return "Brown Noise"
        case .ocean: return "Ocean"
        case .whiteNoise: return "White Noise"
        }
    }
}

enum Recurring: String, Codable {
    case oneTime = "one-time"
    case weekly = "weekly"
    case yearly = "yearly"
}

struct Alarm: Identifiable {
    let id: UUID
    var time: Date
    var sound: AlarmSound
    var recurring: Recurring
    var isEnabled: Bool
    /// True when fetched from the backend.
    var isSaved: Bool

    init(
        id: UUID = UUID(),
        time: Date,
        sound: AlarmSound,
        recurring: Recurring = .oneTime,
        isEnabled: Bool = true,
        isSaved: Bool = false
    ) {
        self.id = id
        self.time = time
        self.sound = sound
        self.recurring = recurring
        self.isEnabled = isEnabled
        self.isSaved = isSaved
    }
}

// MARK: - Backend decoding

struct RemoteAlarm: Decodable {
    let timestamp: Date
    let sound: AlarmSound
    let recurring: Recurring

    func toAlarm() -> Alarm {
        Alarm(time: timestamp, sound: sound, recurring: recurring, isSaved: true)
    }
}
