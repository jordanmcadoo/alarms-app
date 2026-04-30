import SwiftUI

struct AlarmListView: View {
    let sortedAlarms: [Alarm]
    let isLoading: Bool
    let onToggle: (UUID) -> Void

    var body: some View {
        List {
            ForEach(sortedAlarms) { alarm in
                AlarmRowView(alarm: alarm, onToggle: { onToggle(alarm.id) })
            }
        }
        .listStyle(.plain)
        .overlay {
            if sortedAlarms.isEmpty {
                if isLoading {
                    ProgressView("Loading alarms...")
                } else {
                    ContentUnavailableView("No Alarms", systemImage: "alarm", description: Text("Tap + to add an alarm."))
                }
            }
        }
    }
}
