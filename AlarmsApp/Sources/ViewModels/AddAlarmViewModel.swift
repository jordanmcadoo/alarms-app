import Foundation
import Observation

@Observable
final class AddAlarmViewModel {
    private let store: AlarmStore
    var selectedTime = Date()
    var selectedSound = AlarmSound.ocean
    var selectedRecurring = Recurring.oneTime

    init(store: AlarmStore) {
        self.store = store
    }

    func save() {
        let alarm = Alarm(
            time: selectedTime,
            sound: selectedSound,
            recurring: selectedRecurring
        )
        store.add(alarm)
    }
}
