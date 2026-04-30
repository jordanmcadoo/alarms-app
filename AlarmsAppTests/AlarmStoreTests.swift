import XCTest
@testable import AlarmsApp

final class AlarmStoreTests: XCTestCase {
    func testSortedAlarmsOrdersByTimeOfDayAscending() {
        let calendar = Calendar(identifier: .gregorian)
        let morning = Alarm(time: calendar.date(from: DateComponents(year: 2026, month: 4, day: 29, hour: 7, minute: 15))!, sound: .ocean)
        let evening = Alarm(time: calendar.date(from: DateComponents(year: 2026, month: 4, day: 29, hour: 21, minute: 45))!, sound: .party)
        let noon = Alarm(time: calendar.date(from: DateComponents(year: 2026, month: 4, day: 29, hour: 12, minute: 0))!, sound: .whiteNoise)

        let store = AlarmStore()
        store.alarms = [evening, noon, morning]

        XCTAssertEqual(store.sortedAlarms.map(\.id), [morning.id, noon.id, evening.id])
    }

    func testReplacePreservesLocalAlarmsWhileRefreshingSavedOnes() {
        let calendar = Calendar(identifier: .gregorian)
        let localAlarm = Alarm(
            time: calendar.date(from: DateComponents(year: 2026, month: 4, day: 29, hour: 9, minute: 0))!,
            sound: .ocean,
            recurring: .oneTime,
            isEnabled: true,
            isSaved: false
        )
        let oldRemote = Alarm(
            time: calendar.date(from: DateComponents(year: 2026, month: 4, day: 29, hour: 10, minute: 0))!,
            sound: .party,
            recurring: .weekly,
            isEnabled: true,
            isSaved: true
        )
        let newRemote = Alarm(
            time: calendar.date(from: DateComponents(year: 2026, month: 4, day: 30, hour: 6, minute: 30))!,
            sound: .brownNoise,
            recurring: .yearly,
            isEnabled: false,
            isSaved: true
        )

        let store = AlarmStore()
        store.alarms = [localAlarm, oldRemote]

        store.replace(with: [newRemote])

        XCTAssertEqual(store.alarms, [newRemote, localAlarm])
    }

    func testToggleEnabledFlipsMatchingAlarmOnly() {
        let calendar = Calendar(identifier: .gregorian)
        let first = Alarm(
            time: calendar.date(from: DateComponents(year: 2026, month: 4, day: 29, hour: 8, minute: 0))!,
            sound: .ocean,
            isEnabled: true
        )
        let second = Alarm(
            time: calendar.date(from: DateComponents(year: 2026, month: 4, day: 29, hour: 9, minute: 0))!,
            sound: .party,
            isEnabled: false
        )

        let store = AlarmStore()
        store.alarms = [first, second]

        store.toggleEnabled(id: first.id)

        XCTAssertEqual(store.alarms[0].isEnabled, false)
        XCTAssertEqual(store.alarms[1].isEnabled, false)
    }

    func testDisableTurnsOffMatchingAlarm() {
        let calendar = Calendar(identifier: .gregorian)
        let alarm = Alarm(
            time: calendar.date(from: DateComponents(year: 2026, month: 4, day: 29, hour: 8, minute: 0))!,
            sound: .ocean,
            isEnabled: true
        )

        let store = AlarmStore()
        store.alarms = [alarm]

        store.disable(id: alarm.id)

        XCTAssertFalse(store.alarms[0].isEnabled)
    }
}
