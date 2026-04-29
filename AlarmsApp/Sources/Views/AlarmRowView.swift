import SwiftUI

struct AlarmRowView: View {
    @Environment(AlarmStore.self) var store
    let alarm: Alarm

    private var timeString: String {
        alarm.time.formatted(date: .omitted, time: .shortened)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(timeString)
                        .font(.system(size: 40, weight: .thin, design: .default))

                    if alarm.isSaved {
                        Image(systemName: "cloud.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Text("\(alarm.sound.displayName) · \(alarm.recurring.displayName)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { alarm.isEnabled },
                set: { _ in store.toggleEnabled(id: alarm.id) }
            ))
            .labelsHidden()
        }
        .padding(.vertical, 6)
    }
}
