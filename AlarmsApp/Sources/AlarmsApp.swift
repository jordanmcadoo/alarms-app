import SwiftUI

@main
struct AlarmsApp: App {
    private let store: AlarmStore
    private let scheduler: AlarmScheduler
    private let contentViewModel: ContentViewModel

    init() {
        let store = AlarmStore()
        let scheduler = AlarmScheduler()
        self.store = store
        self.scheduler = scheduler
        self.contentViewModel = ContentViewModel(store: store)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: contentViewModel)
                .environment(scheduler)
                .onAppear {
                    scheduler.start(watching: store)
                }
        }
    }
}
