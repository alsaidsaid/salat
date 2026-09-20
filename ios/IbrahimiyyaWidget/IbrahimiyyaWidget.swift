import WidgetKit
import SwiftUI

// ملاحظة: هذا الهدف يحتاج نسخاً من AppGroup.swift و Theme.swift
// (حدّد الملفين في Xcode ← File Inspector ← Target Membership ← فعّل هدف الـ Widget)

struct SalawatEntry: TimelineEntry {
    let date: Date
    let count: Int
}

struct SalawatProvider: TimelineProvider {

    func placeholder(in context: Context) -> SalawatEntry {
        SalawatEntry(date: Date(), count: 313)
    }

    func getSnapshot(in context: Context, completion: @escaping (SalawatEntry) -> Void) {
        completion(SalawatEntry(date: Date(), count: currentCount()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SalawatEntry>) -> Void) {
        // لا حاجة لجدول زمني: التطبيق نفسه يطلب التحديث عند تغيّر العدد
        // عبر WidgetCenter.reloadTimelines، لذا نكتفي بمدخل واحد.
        let entry = SalawatEntry(date: Date(), count: currentCount())
        completion(Timeline(entries: [entry], policy: .never))
    }

    private func currentCount() -> Int {
        AppGroup.defaults.integer(forKey: AppGroup.Keys.count)
    }
}

// MARK: - الواجهة

struct IbrahimiyyaWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    var entry: SalawatEntry

    var body: some View {
        switch family {
        case .accessoryCircular:
            lockScreenCircular
        case .accessoryInline:
            Text("الصلوات: \(entry.count)")
        default:
            homeScreen
        }
    }

    private var homeScreen: some View {
        VStack(spacing: family == .systemSmall ? 2 : 6) {
            Text("ﷺ")
                .font(.system(size: family == .systemSmall ? 18 : 22))
                .foregroundStyle(Theme.goldSoft)

            Text("\(entry.count)")
                .font(.system(size: family == .systemSmall ? 40 : 52, weight: .black).monospacedDigit())
                .foregroundStyle(Theme.gold)
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            Text("صلاة إبراهيمية")
                .font(.system(size: family == .systemSmall ? 12 : 14, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))

            if family != .systemSmall {
                Text("اللهم صلِّ وسلّم على نبينا محمد")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.goldSoft.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(\.layoutDirection, .rightToLeft)
    }

    private var lockScreenCircular: some View {
        VStack(spacing: 0) {
            Text("ﷺ").font(.system(size: 11))
            Text("\(entry.count)")
                .font(.system(size: 16, weight: .bold).monospacedDigit())
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
    }
}

// MARK: - التعريف

struct IbrahimiyyaWidget: Widget {
    let kind = AppGroup.widgetKind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SalawatProvider()) { entry in
            IbrahimiyyaWidgetEntryView(entry: entry)
                .widgetBackgroundCompat()
        }
        .configurationDisplayName("عدد الصلوات")
        .description("يعرض عدد الصلوات الإبراهيمية التي أتممتها.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryInline])
    }
}

/// من iOS 17 صار لزاماً استخدام containerBackground وإلا ظهر الـ Widget بلا خلفية
private extension View {
    @ViewBuilder
    func widgetBackgroundCompat() -> some View {
        if #available(iOS 17.0, *) {
            self.containerBackground(for: .widget) {
                LinearGradient(colors: [Theme.bg1, Theme.bg3],
                               startPoint: .top, endPoint: .bottom)
            }
        } else {
            self.background(
                LinearGradient(colors: [Theme.bg1, Theme.bg3],
                               startPoint: .top, endPoint: .bottom)
            )
        }
    }
}

@main
struct IbrahimiyyaWidgetBundle: WidgetBundle {
    var body: some Widget {
        IbrahimiyyaWidget()
    }
}
