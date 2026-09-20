import SwiftUI
import GoogleMobileAds

// ─────────────────────────────────────────────────────────────────────────────
//  أسماء الأصناف أدناه تتبع Google Mobile Ads SDK 12 وما بعده (بلا بادئة GAD).
//  إن كنت تستخدم الإصدار 11 أو أقدم، استبدل:
//      BannerView      →  GADBannerView
//      AdSizeBanner    →  GADAdSizeBanner
//      Request()       →  GADRequest()
//      MobileAds.shared→  GADMobileAds.sharedInstance()
//  راجع وثائق AdMob الحالية قبل البناء.
// ─────────────────────────────────────────────────────────────────────────────

/// إعدادات الإعلانات في مكان واحد
enum AdConfig {
    /// معرّف الاختبار الرسمي من Google — استبدله بمعرّفك قبل الرفع للمتجر.
    /// تحذير: استخدام إعلانات حقيقية أثناء التطوير يعرّض حسابك في AdMob للإيقاف.
    #if DEBUG
    static let bannerUnitID = "ca-app-pub-3940256099942544/2934735716"
    #else
    static let bannerUnitID = "ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY"
    #endif
}

/// شريط إعلاني في أسفل الشاشة
struct AdBannerView: UIViewRepresentable {
    let adUnitID: String

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = adUnitID
        banner.rootViewController = Self.topViewController()
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}

    private static func topViewController() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        return scene?.keyWindow?.rootViewController
    }
}

/// يعرض الإعلان فقط إذا تحقق الشرطان:
///   ١) أتمّ المستخدم ١٠٠ صلاة   ٢) لم يشترِ النسخة الخالية من الإعلانات
struct GatedAdBanner: View {
    @ObservedObject var counter: CounterStore
    @ObservedObject var store: StoreManager

    var body: some View {
        if counter.hasReachedAdThreshold && !store.hasRemovedAds {
            AdBannerView(adUnitID: AdConfig.bannerUnitID)
                .frame(height: 50)
                .transition(.opacity)
        }
    }
}
