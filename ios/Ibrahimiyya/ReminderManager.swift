import Foundation
import UserNotifications

/// تذكير يومي بالصلاة على النبي ﷺ عبر إشعار محلي.
/// الإشعارات المحلية لا تحتاج خادماً ولا صلاحية Push Notifications — إذن المستخدم فقط.
@MainActor
final class ReminderManager: ObservableObject {

    private static let requestID = "ibrahimiyya.daily.reminder"

    @Published private(set) var authorizationDenied = false

    @Published var isEnabled: Bool {
        didSet {
            guard !suppressSideEffects else { return }
            defaults.set(isEnabled, forKey: AppGroup.Keys.reminderOn)
            Task { await apply() }
        }
    }

    /// يمنع didSet من إعادة استدعاء apply() حين نطفئ المفتاح برمجياً بعد رفض الإذن
    private var suppressSideEffects = false

    @Published var time: Date {
        didSet {
            let parts = Calendar.current.dateComponents([.hour, .minute], from: time)
            defaults.set(parts.hour ?? 20, forKey: AppGroup.Keys.reminderHour)
            defaults.set(parts.minute ?? 0, forKey: AppGroup.Keys.reminderMinute)
            Task { await apply() }
        }
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = AppGroup.defaults) {
        self.defaults = defaults
        self.isEnabled = defaults.bool(forKey: AppGroup.Keys.reminderOn)

        // الافتراضي: الثامنة مساءً
        let hour = defaults.object(forKey: AppGroup.Keys.reminderHour) as? Int ?? 20
        let minute = defaults.object(forKey: AppGroup.Keys.reminderMinute) as? Int ?? 0
        var parts = DateComponents()
        parts.hour = hour
        parts.minute = minute
        self.time = Calendar.current.date(from: parts) ?? Date()
    }

    /// يُستدعى عند تغيّر الإعداد: يطلب الإذن عند الحاجة ثم يجدول أو يلغي
    private func apply() async {
        guard isEnabled else {
            cancel()
            return
        }

        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .notDetermined:
            let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
            if granted {
                authorizationDenied = false
                schedule()
            } else {
                refuse()
            }
        case .denied:
            refuse()
        default:
            authorizationDenied = false
            schedule()
        }
    }

    /// المستخدم رفض الإذن: نُرجع المفتاح إلى الإيقاف ونوضّح السبب في الواجهة
    private func refuse() {
        setEnabledSilently(false)
        authorizationDenied = true
        cancel()
    }

    /// يغيّر المفتاح دون إطلاق didSet، تفادياً لاستدعاء apply() من جديد بلا نهاية
    private func setEnabledSilently(_ value: Bool) {
        suppressSideEffects = true
        isEnabled = value
        suppressSideEffects = false
        defaults.set(value, forKey: AppGroup.Keys.reminderOn)
    }

    private func schedule() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [Self.requestID])

        let content = UNMutableNotificationContent()
        content.title = "الصلاة الإبراهيمية"
        content.body = "«مَن صلّى عليَّ صلاةً واحدةً صلّى اللهُ عليه بها عشرًا»"
        content.sound = .default

        var parts = Calendar.current.dateComponents([.hour, .minute], from: time)
        parts.second = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: parts, repeats: true)
        let request = UNNotificationRequest(identifier: Self.requestID, content: content, trigger: trigger)

        center.add(request)
    }

    private func cancel() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [Self.requestID])
    }
}
