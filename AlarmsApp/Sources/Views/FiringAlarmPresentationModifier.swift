import SwiftUI

private struct FiringAlarmPresentationModifier: ViewModifier {
    @Environment(AlarmScheduler.self) private var scheduler

    func body(content: Content) -> some View {
        content.fullScreenCover(item: Binding(
            get: { scheduler.firingAlarm },
            set: { _ in /* no-op: scheduler owns dismissal */ }
        )) { alarm in
            FiringAlarmView(alarm: alarm)
        }
    }
}

extension View {
    func firingAlarmPresentation() -> some View {
        modifier(FiringAlarmPresentationModifier())
    }
}
