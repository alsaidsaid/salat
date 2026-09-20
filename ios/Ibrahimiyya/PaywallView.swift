import SwiftUI

/// شاشة شراء النسخة الخالية من الإعلانات.
/// تلتزم بإرشاد Apple 3.1.1: وصف واضح لما يحصل عليه المستخدم،
/// السعر بعملته، زر استرجاع المشتريات، وروابط الشروط والخصوصية.
struct PaywallView: View {
    @ObservedObject var store: StoreManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Theme.background

            VStack(spacing: 20) {
                Spacer(minLength: 12)

                Image(systemName: "sparkles")
                    .font(.system(size: 46))
                    .foregroundStyle(Theme.gold)

                Text("نسخة بلا إعلانات")
                    .font(.system(size: 26, weight: .black))
                    .foregroundStyle(Theme.gold)

                VStack(alignment: .leading, spacing: 12) {
                    benefit("إزالة جميع الإعلانات نهائياً")
                    benefit("دفعة واحدة مدى الحياة — بلا اشتراك متجدد")
                    benefit("تعمل على كل أجهزتك بنفس حساب Apple")
                }
                .padding(.horizontal, 8)

                Spacer(minLength: 0)

                if let message = store.errorMessage {
                    Text(message)
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.goldSoft)
                        .multilineTextAlignment(.center)
                }

                Button {
                    Task {
                        await store.purchase()
                        if store.hasRemovedAds { dismiss() }
                    }
                } label: {
                    Group {
                        if store.isPurchasing {
                            ProgressView().tint(Theme.ink)
                        } else {
                            Text("شراء — \(store.displayPrice)")
                        }
                    }
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Theme.ink)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LinearGradient(colors: [Theme.goldSoft, Theme.gold],
                                                 startPoint: .top, endPoint: .bottom))
                    )
                }
                .disabled(store.isPurchasing || store.removeAdsProduct == nil)

                Button("استرجاع المشتريات") {
                    Task {
                        await store.restorePurchases()
                        if store.hasRemovedAds { dismiss() }
                    }
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.goldSoft)

                // مطلوبان من Apple في أي شاشة شراء
                HStack(spacing: 16) {
                    Link("شروط الاستخدام", destination: URL(string: "https://alsaidsaid.github.io/salat/terms.html")!)
                    Link("سياسة الخصوصية", destination: URL(string: "https://alsaidsaid.github.io/salat/privacy.html")!)
                }
                .font(.system(size: 12))
                .foregroundStyle(Color.white.opacity(0.6))

                Button("ليس الآن") { dismiss() }
                    .font(.system(size: 15))
                    .foregroundStyle(Color.white.opacity(0.55))
                    .padding(.bottom, 8)
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: 480)
        }
        .environment(\.layoutDirection, .rightToLeft)
        .preferredColorScheme(.dark)
    }

    private func benefit(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Theme.gold)
            Text(text)
                .font(.system(size: 16))
                .foregroundStyle(.white)
            Spacer(minLength: 0)
        }
    }
}
