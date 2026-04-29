import SwiftUI

struct ContentView: View {
    @Environment(AlarmStore.self) var store
    @Environment(AlarmScheduler.self) var scheduler
    @State private var showAddAlarm = false
    @State private var fetchErrorMessage: String? = nil

    var body: some View {
        NavigationStack {
            AlarmListView()
                .navigationTitle("Alarms")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showAddAlarm = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showAddAlarm) {
                    AddAlarmView()
                }
        }
        .task {
            await loadRemoteAlarms()
        }
        .sheet(item: Binding(
            get: { scheduler.firingAlarm },
            set: { _ in }
        )) { alarm in
            FiringAlarmView(alarm: alarm)
        }
        .alert(
            "Failed to Load Alarms",
            isPresented: Binding(
                get: { fetchErrorMessage != nil },
                set: { if !$0 { fetchErrorMessage = nil } }
            )
        ) {
            Button("OK") { fetchErrorMessage = nil }
        } message: {
            Text(fetchErrorMessage ?? "")
        }
    }

    private func loadRemoteAlarms() async {
        do {
            let fetched = try await AlarmService.fetchAlarms()
            store.replace(with: fetched)
        } catch {
            fetchErrorMessage = error.localizedDescription
        }
    }
}
