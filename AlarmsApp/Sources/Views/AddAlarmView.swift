import SwiftUI

struct AddAlarmView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddAlarmViewModel

    init(viewModel: AddAlarmViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Time", selection: $viewModel.selectedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                }

                Section("Sound") {
                    Picker("Sound", selection: $viewModel.selectedSound) {
                        ForEach(AlarmSound.allCases, id: \.self) { sound in
                            Text(sound.displayName).tag(sound)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section("Repeat") {
                    Picker("Repeat", selection: $viewModel.selectedRecurring) {
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
                        viewModel.save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .firingAlarmPresentation()
    }
}
