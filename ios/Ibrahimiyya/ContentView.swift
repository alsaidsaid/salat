import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var counter = CounterStore()
    @StateObject private var reminder = ReminderManager()

    @State private var showResetConfirm = false
    @State private var showReminder = false
    @State private var flash = false

    var body: some View {
        // التخطيط يُحسب من الارتفاع المتاح فعلاً.
        // المقاسات الثابتة كانت تجعل المحتوى أطول من الشاشة فينسكب
        // من أعلى وأسفل، فيختفي العنوان خلف Dynamic Island ويُقطع آخر زر.
        GeometryReader { geo in
            let h = geo.size.height
            let gap = max(8, min(14, h * 0.016))

            VStack(spacing: gap) {
                titleCard
                hadithCard
                dhikrCircle(size: circleSize(width: geo.size.width, height: h))
                hintText
                progressBar
                counterCard
                actionButtons
                Spacer(minLength: 0)
                footer
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(maxWidth: 520)
            .frame(width: geo.size.width, height: h)
        }
        .background(Theme.background, ignoresSafeAreaEdges: .all)
        .environment(\.layoutDirection, .rightToLeft)
        .preferredColorScheme(.dark)
        .animation(.easeInOut(duration: 0.25), value: counter.progress)
        .confirmationDialog(
            "هل تريد إعادة ضبط العدّاد؟",
            isPresented: $showResetConfirm,
            titleVisibility: .visible
        ) {
            Button("نعم، صفّر العدّاد", role: .destructive) { counter.reset() }
            Button("إلغاء", role: .cancel) {}
        } message: {
            Text("سيعود عدد الصلوات إلى الصفر")
        }
        .sheet(isPresented: $showReminder) {
            ReminderView(reminder: reminder)
        }
    }

    // MARK: - الترويسة

    private var titleCard: some View {
        VStack(spacing: 4) {
            Text("الصلاة الإبراهيمية")
                .font(.system(size: 28, weight: .black))
                .foregroundStyle(Theme.gold)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text("ﷺ")
                .font(.system(size: 18))
                .foregroundStyle(Theme.goldSoft)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Theme.bg1.opacity(0.95))
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(Theme.gold, lineWidth: 2))
        )
    }

    private var hadithCard: some View {
        VStack(spacing: 4) {
            Text("«مَن صلّى عليَّ صلاةً واحدةً صلّى اللهُ عليه بها عشرًا»")
                .multilineTextAlignment(.center)
                .font(.system(size: 17))
                .foregroundStyle(Color(white: 0.95))
            Text("(رواه مسلم)")
                .font(.system(size: 14))
                .foregroundStyle(Theme.goldSoft)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.28))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.gold.opacity(0.35), lineWidth: 1))
        )
    }

    // MARK: - دائرة الذكر

    private func dhikrCircle(size: CGFloat) -> some View {
        Button {
            counter.tap()
            flash = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) { flash = false }
        } label: {
            Text(counter.phrase)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .minimumScaleFactor(0.6)
                .padding(size * 0.1)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color(white: 1.0), Theme.cream],
                                center: UnitPoint(x: 0.5, y: 0.35),
                                startRadius: 0,
                                endRadius: size * 0.7
                            )
                        )
                )
                .overlay(Circle().stroke(Theme.gold, lineWidth: 5))
                .shadow(color: Theme.gold.opacity(flash ? 0.75 : 0.35), radius: flash ? 34 : 18)
                .font(.system(size: max(15, size * 0.072), weight: .bold))
        }
        .buttonStyle(PressableButtonStyle(scale: 0.955))
        .accessibilityLabel("اضغط للذكر والانتقال إلى العبارة التالية")
        .accessibilityValue("عدد الصلوات \(counter.count)")
    }

    /// الدائرة محدودة بالعرض **والارتفاع** معاً، فلا تدفع بقية العناصر خارج الشاشة
    private func circleSize(width: CGFloat, height: CGFloat) -> CGFloat {
        min(width * 0.70, height * 0.30, 300)
    }

    private var hintText: some View {
        Text("اضغط على الدائرة — «صلِّ» ثم «بارك» تُحتسبان صلاة واحدة")
            .font(.system(size: 13))
            .foregroundStyle(Color.white.opacity(0.62))
            .multilineTextAlignment(.center)
    }

    private var progressBar: some View {
        GeometryReader { geo in
            // .leading في بيئة RTL = الحافة اليمنى، فيمتلئ الشريط من اليمين
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.14))
                Capsule()
                    .fill(LinearGradient(colors: [Theme.goldSoft, Theme.gold],
                                         startPoint: .leading, endPoint: .trailing))
                    .frame(width: geo.size.width * counter.progress)
            }
        }
        .frame(height: 9)
    }

    // MARK: - العدّاد

    private var counterCard: some View {
        VStack(spacing: 2) {
            Text("عدد الصلوات")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
            Text(counter.count.salawatFormatted)
                .font(.system(size: 38, weight: .black).monospacedDigit())
                .foregroundStyle(Theme.gold)
        }
        .frame(minWidth: 190)
        .padding(.vertical, 12)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(LinearGradient(colors: [Theme.green, Theme.greenDark],
                                     startPoint: .top, endPoint: .bottom))
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(Theme.gold, lineWidth: 3))
        )
    }

    // MARK: - الأزرار

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button { showResetConfirm = true } label: {
                Label("إعادة الضبط", systemImage: "arrow.counterclockwise")
                    .filledButton(colors: [Theme.red, Theme.redDark])
            }
            .buttonStyle(PressableButtonStyle())

            Button { counter.soundOn.toggle() } label: {
                Label(counter.soundOn ? "إيقاف الصوت" : "تشغيل الصوت",
                      systemImage: counter.soundOn ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .filledButton(colors: counter.soundOn
                                  ? [Theme.blue, Theme.blueDark]
                                  : [Theme.slate, Theme.slateDark])
            }
            .buttonStyle(PressableButtonStyle())

            Button { showReminder = true } label: {
                Label(reminder.isEnabled ? "التذكير اليومي مفعّل" : "تذكير يومي",
                      systemImage: reminder.isEnabled ? "bell.fill" : "bell")
                    .filledButton(colors: reminder.isEnabled
                                  ? [Theme.green, Theme.greenDark]
                                  : [Theme.slate, Theme.slateDark])
            }
            .buttonStyle(PressableButtonStyle())
        }
    }

    private var footer: some View {
        Text("اللهم صلِّ وسلّم على نبينا محمد")
            .font(.system(size: 13))
            .foregroundStyle(Theme.goldSoft.opacity(0.75))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .layoutPriority(-1)   // أول ما يتقلّص عند ضيق الارتفاع
    }
}

// MARK: - تنسيق مشترك للأزرار

private extension View {
    func filledButton(colors: [Color], foreground: Color = .white) -> some View {
        self
            .font(.system(size: 17, weight: .bold))
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom))
            )
    }
}

#Preview {
    ContentView()
}
