import SwiftUI

/// هوية التطبيق البصرية — مطابقة لنسخة الويب
enum Theme {
    static let bg1       = Color(red: 0.290, green: 0.063, blue: 0.141) // #4A1024
    static let bg2       = Color(red: 0.420, green: 0.086, blue: 0.188) // #6B1630
    static let bg3       = Color(red: 0.165, green: 0.039, blue: 0.086) // #2A0A16
    static let gold      = Color(red: 0.910, green: 0.710, blue: 0.227) // #E8B53A
    static let goldSoft  = Color(red: 0.961, green: 0.851, blue: 0.541) // #F5D98A
    static let cream     = Color(red: 0.969, green: 0.953, blue: 0.847) // #F7F3D8
    static let ink       = Color(red: 0.110, green: 0.071, blue: 0.031) // #1C1208
    static let green     = Color(red: 0.118, green: 0.478, blue: 0.235) // #1E7A3C
    static let greenDark = Color(red: 0.078, green: 0.380, blue: 0.180) // #14612E
    static let red       = Color(red: 0.827, green: 0.133, blue: 0.133) // #D32222
    static let redDark   = Color(red: 0.659, green: 0.094, blue: 0.094) // #A81818
    static let blue      = Color(red: 0.086, green: 0.408, blue: 0.847) // #1668D8
    static let blueDark  = Color(red: 0.059, green: 0.310, blue: 0.659) // #0F4FA8
    static let slate     = Color(red: 0.353, green: 0.373, blue: 0.420)
    static let slateDark = Color(red: 0.239, green: 0.259, blue: 0.298)

    /// خلفية متدرّجة دائرية كما في نسخة الويب.
    /// RadialGradient نمطُ شكل (ShapeStyle)، فيصحّ تمريره إلى
    /// ‎.background(_:ignoresSafeAreaEdges:)‎ لتتجاوز الخلفيةُ وحدَها
    /// المنطقةَ الآمنة بينما يبقى المحتوى داخلها.
    static var background: RadialGradient {
        RadialGradient(
            gradient: Gradient(colors: [bg2, bg1, bg3]),
            center: UnitPoint(x: 0.5, y: 0.12),
            startRadius: 0,
            endRadius: 760
        )
    }
}

extension Int {
    /// الأرقام لاتينية دائماً ومستقلة عن لغة الجهاز.
    /// الأرقام العربية-الهندية تُرسم بها بعض الخطوط رموزاً بديلة
    /// (ظهر الصفر ◆ في وزن black)، والنسخة الإلكترونية تستعمل اللاتينية أيضاً.
    var salawatFormatted: String {
        formatted(.number.locale(Locale(identifier: "en_US_POSIX")))
    }
}

/// زر بتأثير ضغط خفيف
struct PressableButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.97
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
