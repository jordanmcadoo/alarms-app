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

enum Recurring: String, Codable, CaseIterable {
    case oneTime = "one-time"
    case weekly = "weekly"
    case yearly = "yearly"

    var displayName: String {
        switch self {
        case .oneTime: return "One Time"
        case .weekly: return "Weekly"
        case .yearly: return "Yearly"
        }
    }
}

struct Alarm: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var time: Date
    var sound: AlarmSound
    var recurring: Recurring
    var isEnabled: Bool
    /// True when fetched from the backend.
    var isSaved: Bool

    enum CodingKeys: String, CodingKey {
        case id, sound, recurring
        case time = "timestamp"
        case isEnabled, isSaved
    }

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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        time = try container.decode(Date.self, forKey: .time)
        sound = try container.decode(AlarmSound.self, forKey: .sound)
        recurring = try container.decode(Recurring.self, forKey: .recurring)
        // The backend does not provide a reliable id, so derive a deterministic
        // UUID from the alarm's content to keep remote alarms identifiable.
        id = Alarm.stableUUID(from: "\(time.timeIntervalSinceReferenceDate)-\(sound.rawValue)-\(recurring.rawValue)")
        isEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? true
        isSaved = try container.decodeIfPresent(Bool.self, forKey: .isSaved) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(time, forKey: .time)
        try container.encode(sound, forKey: .sound)
        try container.encode(recurring, forKey: .recurring)
        try container.encode(isEnabled, forKey: .isEnabled)
        try container.encode(isSaved, forKey: .isSaved)
    }

    // XOR-folds the UTF-8 bytes of `string` into 16 bytes to produce a
    // deterministic UUID. Not cryptographic — purely for stable identity.
    private static func stableUUID(from string: String) -> UUID {
        var bytes = [UInt8](repeating: 0, count: 16)
        for (i, byte) in string.utf8.enumerated() { bytes[i % 16] ^= byte }
        return UUID(uuid: (
            bytes[0],  bytes[1],  bytes[2],  bytes[3],
            bytes[4],  bytes[5],  bytes[6],  bytes[7],
            bytes[8],  bytes[9],  bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15]
        ))
    }
}

extension Alarm {
    var displayTime: String {
        time.formatted(date: .omitted, time: .shortened)
    }

    var displayDetails: String {
        "\(sound.displayName) · \(recurring.displayName)"
    }
}
