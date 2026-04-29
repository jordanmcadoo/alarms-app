import SwiftUI

struct AddAlarmView: View {
    @Environment(AlarmStore.self) var store
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTime = Date()
    @State private var selectedSound = AlarmSound.ocean
    @State private var selectedRecurring = Recurring.oneTime

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                }

                Section("Sound") {
                    Picker("Sound", selection: $selectedSound) {
                        ForEach(AlarmSound.allCases, id: \.self) { sound in
                            Text(sound.displayName).tag(sound)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section("Repeat") {
                    Picker("Repeat", selection: $selectedRecurring) {
                        ForEach(Recurring.allCases, id: \.self) { r in
                            Text(r.displayName).tag(r)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
            }
            .navigationTitle("Add Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let alarm = Alarm(time: selectedTime, sound: selectedSound, recurring: selectedRecurring)
                        store.add(alarm)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
