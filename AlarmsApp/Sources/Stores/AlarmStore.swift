import Foundation
import Observation

@Observable
final class AlarmStore {
    var alarms: [Alarm] = []

    // Sorted to match the stock Clock app: by time-of-day (hour + minute), ascending.
    var sortedAlarms: [Alarm] {
        alarms.sorted { lhs, rhs in
            let lhsComponents = Calendar.current.dateComponents([.hour, .minute], from: lhs.time)
            let rhsComponents = Calendar.current.dateComponents([.hour, .minute], from: rhs.time)
            let lhsMinutes = (lhsComponents.hour ?? 0) * 60 + (lhsComponents.minute ?? 0)
            let rhsMinutes = (rhsComponents.hour ?? 0) * 60 + (rhsComponents.minute ?? 0)
            return lhsMinutes < rhsMinutes
        }
    }

    func add(_ alarm: Alarm) {
        alarms.append(alarm)
    }

    func toggleEnabled(id: UUID) {
        guard let idx = alarms.firstIndex(where: { $0.id == id }) else { return }
        alarms[idx].isEnabled.toggle()
    }

    func disable(id: UUID) {
        guard let idx = alarms.firstIndex(where: { $0.id == id }) else { return }
        alarms[idx].isEnabled = false
    }

    func replace(with remoteAlarms: [Alarm]) {
        let existingLocal = alarms.filter { !$0.isSaved }
        alarms = remoteAlarms + existingLocal
    }
}
