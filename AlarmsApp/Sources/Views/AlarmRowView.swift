import SwiftUI

struct AlarmRowView: View {
    let alarm: Alarm
    let onToggle: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(alarm.displayTime)
                        .font(.system(size: 40, weight: .thin, design: .default))

                    if alarm.isSaved {
                        Image(systemName: "cloud.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Text(alarm.displayDetails)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { alarm.isEnabled },
                set: { _ in onToggle() }
            ))
            .labelsHidden()
        }
        .padding(.vertical, 6)
    }
}
