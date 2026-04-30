import XCTest
@testable import AlarmsApp

final class AlarmSchedulerTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    func testOneTimeAlarmFiresOnlyOnExactStoredDay() {
        let alarm = Alarm(
            time: calendar.date(from: DateComponents(year: 2026, month: 4, day: 29, hour: 7, minute: 30))!,
            sound: .ocean,
            recurring: .oneTime
        )

        let matchingMoment = calendar.date(from: DateComponents(year: 2026, month: 4, day: 29, hour: 7, minute: 30))!
        let nextDaySameTime = calendar.date(from: DateComponents(year: 2026, month: 4, day: 30, hour: 7, minute: 30))!

        XCTAssertTrue(AlarmScheduler.shouldFire(alarm, at: matchingMoment, calendar: calendar))
        XCTAssertFalse(AlarmScheduler.shouldFire(alarm, at: nextDaySameTime, calendar: calendar))
    }

    func testWeeklyAlarmFiresOnMatchingWeekdayAndTime() {
        let alarm = Alarm(
            time: calendar.date(from: DateComponents(year: 2026, month: 4, day: 29, hour: 7, minute: 30))!,
            sound: .party,
            recurring: .weekly
        )

        let oneWeekLater = calendar.date(from: DateComponents(year: 2026, month: 5, day: 6, hour: 7, minute: 30))!
        let differentWeekday = calendar.date(from: DateComponents(year: 2026, month: 5, day: 7, hour: 7, minute: 30))!

        XCTAssertTrue(AlarmScheduler.shouldFire(alarm, at: oneWeekLater, calendar: calendar))
        XCTAssertFalse(AlarmScheduler.shouldFire(alarm, at: differentWeekday, calendar: calendar))
    }

    func testYearlyAlarmFiresOnMatchingMonthDayAndTime() {
        let alarm = Alarm(
            time: calendar.date(from: DateComponents(year: 2026, month: 4, day: 29, hour: 7, minute: 30))!,
            sound: .whiteNoise,
            recurring: .yearly
        )

        let nextYearSameDate = calendar.date(from: DateComponents(year: 2027, month: 4, day: 29, hour: 7, minute: 30))!
        let wrongDay = calendar.date(from: DateComponents(year: 2027, month: 4, day: 30, hour: 7, minute: 30))!

        XCTAssertTrue(AlarmScheduler.shouldFire(alarm, at: nextYearSameDate, calendar: calendar))
        XCTAssertFalse(AlarmScheduler.shouldFire(alarm, at: wrongDay, calendar: calendar))
    }
}
