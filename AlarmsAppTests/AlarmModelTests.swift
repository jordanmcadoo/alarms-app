import XCTest
@testable import AlarmsApp

final class AlarmModelTests: XCTestCase {
    func testDecodingWithoutIDDerivesStableIDFromAlarmContent() throws {
        let json = """
        {
          "timestamp": "2026-04-29T12:30:00Z",
          "sound": "ocean",
          "recurring": "weekly"
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let first = try decoder.decode(Alarm.self, from: Data(json.utf8))
        let second = try decoder.decode(Alarm.self, from: Data(json.utf8))

        XCTAssertEqual(first.id, second.id)
        XCTAssertTrue(first.isEnabled)
        XCTAssertFalse(first.isSaved)
    }

    func testDecodingNonUUIDStringIDFallsBackToStableDerivedUUID() throws {
        let json = """
        {
          "id": "backend-123",
          "timestamp": "2026-04-29T12:30:00Z",
          "sound": "party",
          "recurring": "one-time"
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let first = try decoder.decode(Alarm.self, from: Data(json.utf8))
        let second = try decoder.decode(Alarm.self, from: Data(json.utf8))

        XCTAssertEqual(first.id, second.id)
    }

    func testDisplayHelpersExposeFormattedTimeAndSummary() {
        let calendar = Calendar(identifier: .gregorian)
        let alarm = Alarm(
            time: calendar.date(from: DateComponents(year: 2026, month: 4, day: 29, hour: 7, minute: 15))!,
            sound: .whiteNoise,
            recurring: .yearly
        )

        XCTAssertFalse(alarm.displayTime.isEmpty)
        XCTAssertEqual(alarm.displayDetails, "White Noise · Yearly")
    }
}
