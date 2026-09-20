import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency

@main
struct IbrahimiyyaApp: App {
    init() {
        // انظر التعليق في AdBannerView.swift بخصوص أسماء الأصناف حسب إصدار SDK
        MobileAds.shared.start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    // Apple تشترط طلب إذن التتبّع قبل استخدام مُعرّف الإعلانات (ATT).
                    // التأخير البسيط يمنع ظهور النافذة قبل اكتمال تحميل الواجهة.
                    try? await Task.sleep(nanoseconds: 1_200_000_000)
                    if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
                        _ = await ATTrackingManager.requestTrackingAuthorization()
                    }
                }
        }
    }
}
