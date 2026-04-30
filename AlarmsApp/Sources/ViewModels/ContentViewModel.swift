import Foundation
import Observation

@MainActor
@Observable
final class ContentViewModel {
    private let store: AlarmStore
    private(set) var showAddAlarm = false
    private(set) var isLoading = false
    private(set) var errorMessage: String? = nil

    init(store: AlarmStore) {
        self.store = store
    }

    var isShowingError: Bool {
        errorMessage != nil
    }

    var sortedAlarms: [Alarm] {
        store.sortedAlarms
    }

    var alarms: [Alarm] {
        store.alarms
    }

    func makeAddAlarmViewModel() -> AddAlarmViewModel {
        AddAlarmViewModel(store: store)
    }

    func toggleEnabled(id: UUID) {
        store.toggleEnabled(id: id)
    }

    func presentAddAlarm() {
        showAddAlarm = true
    }

    func dismissAddAlarm() {
        showAddAlarm = false
    }

    func dismissError() {
        errorMessage = nil
    }

    func loadRemoteAlarms(
        fetch: () async throws -> [Alarm] = AlarmService.fetchAlarms
    ) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let fetched = try await fetch()
            store.replace(with: fetched)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
