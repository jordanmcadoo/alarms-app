import SwiftUI

struct AlarmListView: View {
    @Environment(AlarmStore.self) var store

    var body: some View {
        List {
            ForEach(store.sortedAlarms) { alarm in
                AlarmRowView(alarm: alarm)
            }
        }
        .listStyle(.plain)
        .overlay {
            if store.alarms.isEmpty {
                ContentUnavailableView("No Alarms", systemImage: "alarm", description: Text("Tap + to add an alarm."))
            }
        }
    }
}
