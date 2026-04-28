import Foundation

struct AlarmService {
    private static let endpoint = URL(string: "https://671267816c5f5ced6623613b.mockapi.io/alarms")!

    static func fetchAlarms() async throws -> [Alarm] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let (data, _) = try await URLSession.shared.data(from: endpoint)
        let remote = try decoder.decode([RemoteAlarm].self, from: data)
        return remote.map { $0.toAlarm() }
    }
}
