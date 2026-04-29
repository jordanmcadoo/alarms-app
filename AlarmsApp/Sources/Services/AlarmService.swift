import Foundation

struct AlarmService {
    private static let endpoint = URL(string: "https://671267816c5f5ced6623613b.mockapi.io/alarms")!

    static func fetchAlarms() async throws -> [Alarm] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let (data, _) = try await URLSession.shared.data(from: endpoint)
        let alarms = try decoder.decode([Alarm].self, from: data)
        return alarms.map { var a = $0; a.isSaved = true; return a }
    }
}
