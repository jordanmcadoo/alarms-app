import XCTest
@testable import AlarmsApp

final class AddAlarmViewModelTests: XCTestCase {
    func testSaveAddsAlarmUsingSelectedFormValues() {
        let calendar = Calendar(identifier: .gregorian)
        let selectedTime = calendar.date(from: DateComponents(year: 2026, month: 4, day: 29, hour: 6, minute: 45))!
        let store = AlarmStore()
        let viewModel = AddAlarmViewModel(store: store)

        viewModel.selectedTime = selectedTime
        viewModel.selectedSound = .party
        viewModel.selectedRecurring = .weekly

        viewModel.save()

        XCTAssertEqual(store.alarms.count, 1)
        XCTAssertEqual(store.alarms[0].time, selectedTime)
        XCTAssertEqual(store.alarms[0].sound, .party)
        XCTAssertEqual(store.alarms[0].recurring, .weekly)
        XCTAssertTrue(store.alarms[0].isEnabled)
        XCTAssertFalse(store.alarms[0].isSaved)
    }
}
