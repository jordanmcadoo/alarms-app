import SwiftUI

struct ContentView: View {
    let viewModel: ContentViewModel

    init(viewModel: ContentViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            AlarmListView(
                sortedAlarms: viewModel.sortedAlarms,
                isLoading: viewModel.isLoading,
                onToggle: viewModel.toggleEnabled
            )
                .navigationTitle("Alarms")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            viewModel.presentAddAlarm()
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: Binding(
                    get: { viewModel.showAddAlarm },
                    set: { if !$0 { viewModel.dismissAddAlarm() } }
                )) {
                    AddAlarmView(viewModel: viewModel.makeAddAlarmViewModel())
                }
        }
        .task {
            await viewModel.loadRemoteAlarms()
        }
        .firingAlarmPresentation()
        .alert(
            "Failed to Load Alarms",
            isPresented: Binding(
                get: { viewModel.isShowingError },
                set: { if !$0 { viewModel.dismissError() } }
            )
        ) {
            Button("OK") { viewModel.dismissError() }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
