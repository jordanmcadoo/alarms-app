import SwiftUI

@main
struct AlarmsApp: App {
    @State private var store = AlarmStore()
    @State private var scheduler = AlarmScheduler()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .environment(scheduler)
                .onAppear {
                    scheduler.start(watching: store)
                }
        }
    }
}
