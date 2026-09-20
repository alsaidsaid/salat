import Foundation

/// مساحة تخزين مشتركة بين التطبيق والـ Widget.
///
/// مهم: الـ Widget عملية منفصلة تماماً عن التطبيق، فلا يرى `UserDefaults.standard`.
/// المجموعة (App Group) هي الجسر الوحيد بينهما، ويجب تفعيلها على **كلا الهدفين**
/// في Xcode بنفس المعرّف حرفياً.
enum AppGroup {
    static let identifier = "group.com.alsaid.ibrahimiyya"

    /// يعود إلى التخزين العادي إن لم تُفعَّل المجموعة بعد، فلا ينهار التطبيق أثناء التطوير
    static var defaults: UserDefaults {
        UserDefaults(suiteName: identifier) ?? .standard
    }

    enum Keys {
        static let count = "ibrahimiyya.count"
        static let index = "ibrahimiyya.index"
        static let sound = "ibrahimiyya.sound"
        static let reminderOn = "ibrahimiyya.reminder.on"
        static let reminderHour = "ibrahimiyya.reminder.hour"
        static let reminderMinute = "ibrahimiyya.reminder.minute"
    }

    /// اسم الـ Widget كما يُعرَّف في `kind` — يُستخدم لتحديثه عند تغيّر العدد
    static let widgetKind = "IbrahimiyyaWidget"
}
