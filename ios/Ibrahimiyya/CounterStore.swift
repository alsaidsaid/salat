import SwiftUI
import UIKit
import AudioToolbox

/// منطق العدّ والتخزين.
///
/// الصلاة الإبراهيمية لا تكتمل إلا بالعبارتين معاً، لذلك:
/// الضغطة الأولى تعرض «اللهم بارك»، والضغطة الثانية تُتمّ الصلاة فتُحتسب واحدة.
@MainActor
final class CounterStore: ObservableObject {

    static let phrases = [
        "اللهم صلِّ على محمد وعلى آل محمد كما صليت على إبراهيم وعلى آل إبراهيم إنك حميد مجيد",
        "اللهم بارك على محمد وعلى آل محمد كما باركت على إبراهيم وعلى آل إبراهيم إنك حميد مجيد"
    ]

    /// عدد الصلوات المجانية قبل أن تبدأ الإعلانات بالظهور
    static let adFreeThreshold = 100

    @Published private(set) var count: Int
    @Published private(set) var index: Int
    @Published private(set) var justCompleted = false

    @Published var soundOn: Bool {
        didSet { defaults.set(soundOn, forKey: Keys.sound) }
    }

    private let defaults: UserDefaults

    private enum Keys {
        static let count = "ibrahimiyya.count"
        static let index = "ibrahimiyya.index"
        static let sound = "ibrahimiyya.sound"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.count = defaults.integer(forKey: Keys.count)
        let storedIndex = defaults.integer(forKey: Keys.index)
        self.index = (storedIndex == 1) ? 1 : 0
        // الصوت مفعّل افتراضياً عند أول تشغيل
        self.soundOn = (defaults.object(forKey: Keys.sound) as? Bool) ?? true
    }

    // MARK: - حالة العرض

    var phrase: String { Self.phrases[index] }

    /// هل العبارة المعروضة الآن هي «اللهم بارك»؟ (الضغطة التالية تُتمّ الصلاة)
    var isOnBaraka: Bool { index == 1 }

    /// امتلاء شريط التقدّم: ٠ عند «صلِّ»، النصف عند «بارك»، ويكتمل لحظة الإتمام
    var progress: Double {
        if justCompleted { return 1.0 }
        return index == 1 ? 0.5 : 0.0
    }

    /// تبدأ الإعلانات بعد إتمام ١٠٠ صلاة
    var hasReachedAdThreshold: Bool { count >= Self.adFreeThreshold }

    var salawatUntilAds: Int { max(0, Self.adFreeThreshold - count) }

    // MARK: - الأفعال

    func tap() {
        let completes = isOnBaraka

        playFeedback(completed: completes)

        if completes {
            count += 1
            defaults.set(count, forKey: Keys.count)
        }

        index = (index + 1) % Self.phrases.count
        defaults.set(index, forKey: Keys.index)

        if completes {
            justCompleted = true
            Task { [weak self] in
                try? await Task.sleep(nanoseconds: 340_000_000)
                await MainActor.run { self?.justCompleted = false }
            }
        }
    }

    func reset() {
        count = 0
        index = 0
        justCompleted = false
        defaults.set(0, forKey: Keys.count)
        defaults.set(0, forKey: Keys.index)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    // MARK: - الصوت والاهتزاز

    private func playFeedback(completed: Bool) {
        if soundOn {
            // نغمة مميزة عند إتمام الصلاة
            AudioServicesPlaySystemSound(completed ? 1057 : 1104)
        }
        UIImpactFeedbackGenerator(style: completed ? .medium : .light).impactOccurred()
    }
}
