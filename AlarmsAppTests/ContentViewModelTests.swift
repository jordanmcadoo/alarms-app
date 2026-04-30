import XCTest
@testable import AlarmsApp

@MainActor
final class ContentViewModelTests: XCTestCase {
    func testLoadRemoteAlarmsReplacesStoreAndClearsLoadingState() async {
        let calendar = Calendar(identifier: .gregorian)
        let existingLocal = Alarm(
            time: calendar.date(from: DateComponents(year: 2026, month: 4, day: 29, hour: 9, minute: 0))!,
            sound: .ocean,
            isSaved: false
        )
        let remote = Alarm(
            time: calendar.date(from: DateComponents(year: 2026, month: 4, day: 30, hour: 6, minute: 30))!,
            sound: .brownNoise,
            recurring: .yearly,
            isEnabled: false,
            isSaved: true
        )

        let store = AlarmStore()
        store.alarms = [existingLocal]
        let viewModel = ContentViewModel(store: store)

        await viewModel.loadRemoteAlarms {
            [remote]
        }

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.alarms, [remote, existingLocal])
    }

    func testLoadRemoteAlarmsStoresErrorAndClearsLoadingStateOnFailure() async {
        struct FetchFailure: LocalizedError {
            var errorDescription: String? { "Network unavailable" }
        }

        let viewModel = ContentViewModel(store: AlarmStore())

        await viewModel.loadRemoteAlarms {
            throw FetchFailure()
        }

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.errorMessage, "Network unavailable")
        XCTAssertTrue(viewModel.isShowingError)
    }
}
