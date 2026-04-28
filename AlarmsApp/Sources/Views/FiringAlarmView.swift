import SwiftUI

struct FiringAlarmView: View {
    @Environment(AlarmScheduler.self) var scheduler
    let alarm: Alarm

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "alarm.fill")
                .font(.system(size: 80))
                .foregroundStyle(.red)
                .symbolEffect(.pulse)

            Text(alarm.time.formatted(date: .omitted, time: .shortened))
                .font(.system(size: 64, weight: .thin))

            Text(alarm.sound.displayName)
                .font(.title3)
                .foregroundStyle(.secondary)

            Spacer()

            Button {
                scheduler.dismissFiringAlarm()
            } label: {
                Text("Stop")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.red)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .interactiveDismissDisabled()
    }
}
