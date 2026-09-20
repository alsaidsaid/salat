import SwiftUI

struct ReminderView: View {
    @ObservedObject var reminder: ReminderManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 22) {
            Spacer(minLength: 20)

            Image(systemName: "bell.badge.fill")
                .font(.system(size: 42))
                .foregroundStyle(Theme.gold)

            Text("تذكير يومي")
                .font(.system(size: 25, weight: .black))
                .foregroundStyle(Theme.gold)

            Text("يصلك إشعار واحد كل يوم يذكّرك بالصلاة على النبي ﷺ")
                .font(.system(size: 15))
                .foregroundStyle(.white.opacity(0.85))
                .multilineTextAlignment(.center)

            VStack(spacing: 14) {
                Toggle("تفعيل التذكير", isOn: $reminder.isEnabled)
                    .tint(Theme.green)
                    .font(.system(size: 17, weight: .semibold))

                if reminder.isEnabled {
                    DatePicker("وقت التذكير",
                               selection: $reminder.time,
                               displayedComponents: .hourAndMinute)
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .foregroundStyle(.white)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.black.opacity(0.28))
                    .overlay(RoundedRectangle(cornerRadius: 18)
                        .stroke(Theme.gold.opacity(0.35), lineWidth: 1))
            )

            if reminder.authorizationDenied {
                Text("الإشعارات موقوفة لهذا التطبيق. فعّلها من: الإعدادات ← الإشعارات ← الصلاة الإبراهيمية")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.goldSoft)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Button("تم") { dismiss() }
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Theme.ink)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LinearGradient(colors: [Theme.goldSoft, Theme.gold],
                                             startPoint: .top, endPoint: .bottom))
                )
                .padding(.bottom, 16)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: 480)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background, ignoresSafeAreaEdges: .all)
        .environment(\.layoutDirection, .rightToLeft)
        .preferredColorScheme(.dark)
    }
}
