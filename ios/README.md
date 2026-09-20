# نسخة iOS — الرفع إلى App Store

تطبيق **أصلي (Native SwiftUI)** وليس غلافاً لصفحة ويب. هذا الاختيار مقصود، والسبب في القسم التالي.

---

## ⚠️ اقرأ هذا أولاً: خطر الرفض

**إرشاد Apple رقم 4.2 (الحد الأدنى من الوظائف)** ينص على رفض التطبيقات البسيطة جداً أو التي هي مجرد موقع ويب مُغلّف. **عدّاد بزرّين هو تحديداً النوع الذي تُرفضه Apple كثيراً.**

لذلك كُتب التطبيق بـ SwiftUI أصلاً — لا WebView — وهذا يرفع فرص القبول كثيراً لكنه **لا يضمنها**.

### ما أُضيف بالفعل لتقليل خطر الرفض

| الإضافة | الحالة | الأثر |
|---|---|---|
| **Widget** للشاشة الرئيسية وشاشة القفل | ✅ مُنفَّذ | الأقوى أثراً — وظيفة يستحيل على موقع ويب تقديمها |
| **تذكير يومي** عبر الإشعارات المحلية | ✅ مُنفَّذ | قيمة أصلية واضحة |
| اهتزاز وأصوات النظام | ✅ مُنفَّذ | |
| **مزامنة iCloud** بين الأجهزة | ◻️ مقترح | يبرّر كون التطبيق أصلياً |
| **تطبيق Apple Watch** | ◻️ مقترح | ممتاز لتطبيقات الذكر تحديداً |
| إحصاءات أسبوعية | ◻️ مقترح | يحوّله من «عدّاد» إلى «تطبيق» |

الـ Widget وحده يغيّر الصورة كثيراً أمام المراجع، ومعه التذكير اليومي يصبح ملف التطبيق مقنعاً.

---

## المتطلبات

| المتطلب | التكلفة | ملاحظة |
|---|---|---|
| جهاز Mac | — | إلزامي، لا يمكن بناء تطبيق iOS على Windows أو Linux |
| Xcode 16 فأحدث | مجاني | من Mac App Store |
| حساب Apple Developer | **99$ سنوياً** | متجدّد — بدونه لا يمكن الرفع |
| حساب AdMob | مجاني | للإعلانات |

> **عن الـ 0.99$:** Apple تأخذ **15%** إن كنت في برنامج الشركات الصغيرة (دخل أقل من مليون دولار سنوياً — يلزم التقديم له)، وإلا **30%**. صافي الـ 0.99$ ≈ **0.84$** أو **0.69$**.

---

## ملفات المشروع

| الملف | الدور |
|---|---|
| `IbrahimiyyaApp.swift` | نقطة الدخول، تهيئة AdMob وطلب إذن التتبّع |
| `ContentView.swift` | الواجهة الرئيسية |
| `CounterStore.swift` | منطق العدّ (ضغطتان = صلاة) والتخزين |
| `StoreManager.swift` | الشراء داخل التطبيق (StoreKit 2) |
| `PaywallView.swift` | شاشة الشراء |
| `AdBannerView.swift` | الإعلان وشرط ظهوره بعد ١٠٠ صلاة |
| `ReminderManager.swift` | التذكير اليومي عبر الإشعارات المحلية |
| `ReminderView.swift` | شاشة ضبط التذكير |
| `AppGroup.swift` | التخزين المشترك بين التطبيق والـ Widget |
| `Theme.swift` | الألوان |
| `Products.storekit` | لاختبار الشراء محلياً بلا حساب |
| `Info-additions.plist` | المفاتيح المطلوب إضافتها لـ Info.plist |
| `../IbrahimiyyaWidget/` | هدف الـ Widget |
| `../project.yml` | مواصفة XcodeGen — تُنشئ المشروع كاملاً |
| `../setup.sh` | سكربت الإعداد بأمر واحد (macOS) |
| `../AppStoreConnect.md` | نصوص صفحة المتجر جاهزة للّصق |

---

## الطريق السريع (موصى به)

على جهاز Mac، بعد استنساخ المستودع:

```bash
git clone https://github.com/alsaidsaid/salat.git
cd salat/ios
./setup.sh
```

السكربت يثبّت XcodeGen وينشئ `Ibrahimiyya.xcodeproj` كاملاً من `project.yml`،
**متكفّلاً نيابةً عنك بـ:** الهدفين (التطبيق والـ Widget)، المجموعة المشتركة على
كليهما بنفس المعرّف، ملفات الصلاحيات، ربط مكتبة AdMob، مفاتيح Info.plist،
وربط `Products.storekit` بالـ Scheme لاختبار الشراء محلياً.

يبقى عليك ثلاثة أشياء فقط: **اختيار فريق التوقيع**، و**وضع معرّفات AdMob**،
و**إنشاء منتج الشراء في App Store Connect**.

> يبقى القسم التالي مرجعاً إن فضّلت الإعداد اليدوي أو أردت فهم ما يفعله السكربت.

---

## الإعداد اليدوي (بديل)

### ١. إنشاء المشروع

```
Xcode → File → New → Project → iOS → App
  Product Name: Ibrahimiyya
  Interface: SwiftUI        Language: Swift
  Bundle Identifier: com.alsaid.ibrahimiyya
```

احذف `ContentView.swift` الافتراضي، ثم اسحب كل ملفات `.swift` من هذا المجلد إلى المشروع مع تفعيل **Copy items if needed**.

### ٢. تفعيل المجموعة المشتركة (App Group)

الـ Widget عملية منفصلة لا ترى تخزين التطبيق، والمجموعة هي الجسر بينهما.

```
الهدف Ibrahimiyya → Signing & Capabilities → + Capability → App Groups
  أضف:  group.com.alsaid.ibrahimiyya
```

**كرّر الخطوة نفسها على هدف الـ Widget بنفس المعرّف حرفياً.** بدون ذلك سيعرض الـ Widget صفراً دائماً.

### ٣. إضافة هدف الـ Widget

```
File → New → Target → Widget Extension
  Product Name: IbrahimiyyaWidget
  ✗ أزل علامة "Include Live Activity"
  ✗ أزل علامة "Include Configuration App Intent"
```

احذف الملف الذي ينشئه Xcode تلقائياً، وضع مكانه `IbrahimiyyaWidget/IbrahimiyyaWidget.swift`.

ثم حدّد `AppGroup.swift` و `Theme.swift` في متصفح الملفات، وفي **File Inspector ← Target Membership** فعّل هدف الـ Widget أيضاً — الملفان يحتاجهما الهدفان معاً.

### ٤. إضافة مكتبة AdMob

```
File → Add Package Dependencies…
  https://github.com/googleads/swift-package-manager-google-mobile-ads.git
```

> راجع **وثائق AdMob الحالية** لأسماء الأصناف: الإصدار ١٢ فما فوق أسقط البادئة `GAD` (أي `BannerView` بدل `GADBannerView`). الكود مكتوب للإصدار ١٢، والتعليق في أعلى `AdBannerView.swift` يوضّح مقابلاتها في الإصدار ١١.

### ٥. إعداد AdMob

1. أنشئ تطبيقاً في [AdMob](https://admob.google.com) واختر iOS.
2. انسخ **App ID** (`ca-app-pub-…~…`) إلى `GADApplicationIdentifier` في Info.plist.
3. أنشئ وحدة إعلان **Banner** وانسخ **Ad Unit ID** (`ca-app-pub-…/…`) إلى `AdConfig.bannerUnitID` داخل فرع `#else` في `AdBannerView.swift`.
4. انسخ قائمة `SKAdNetworkItems` كاملة من وثائق AdMob إلى Info.plist.

> ⚠️ **لا تضغط على إعلاناتك الحقيقية أبداً** — Google توقف الحسابات بسبب ذلك. فرع `#if DEBUG` يستخدم معرّفات الاختبار تلقائياً أثناء التطوير.

### ٦. إعداد الشراء داخل التطبيق

في **App Store Connect → تطبيقك → In-App Purchases → +**:

| الحقل | القيمة |
|---|---|
| النوع | **Non-Consumable** (غير استهلاكي) |
| Reference Name | Remove Ads (Lifetime) |
| Product ID | `com.alsaid.ibrahimiyya.removeads` |
| السعر | **Tier 1** = 0.99$ |
| Display Name (ar) | نسخة بلا إعلانات |
| Description (ar) | إزالة جميع الإعلانات نهائياً — دفعة واحدة مدى الحياة |

> **النوع «غير استهلاكي» ضروري.** لو اخترت Consumable فلن يستطيع المستخدم استرجاع شرائه، وهذا سبب رفض مباشر.

المعرّف في `StoreManager.removeAdsProductID` يجب أن يطابق Product ID **حرفياً**.

في Xcode: `Signing & Capabilities → + Capability → In-App Purchase`.

### ٧. الاختبار

**محلياً بلا حساب:** `Product → Scheme → Edit Scheme → Run → Options → StoreKit Configuration → Products.storekit`

**في Sandbox:** أنشئ Sandbox Tester من App Store Connect → Users and Access → Sandbox.

اختبر تحديداً:
- [ ] الإعلان **لا يظهر** قبل ١٠٠ صلاة
- [ ] الإعلان يظهر عند الوصول إلى ١٠٠
- [ ] الشراء يخفي الإعلان فوراً
- [ ] «استرجاع المشتريات» يعمل بعد حذف التطبيق وإعادة تثبيته
- [ ] العدّاد: ضغطتان = صلاة واحدة
- [ ] الـ Widget يعرض العدد نفسه ويتحدّث بعد الذكر
- [ ] التذكير اليومي يصل في وقته، ورفض الإذن يُرجع المفتاح إلى الإيقاف

> الإشعارات المحلية **لا تحتاج** صلاحية Push Notifications ولا خادماً — إذن المستخدم فقط.

### ٨. ما تحتاجه صفحة المتجر

> **كل النصوص مكتوبة وجاهزة في [`AppStoreConnect.md`](AppStoreConnect.md)** —
> الاسم والعنوان الفرعي والوصف والكلمات المفتاحية بالعربية والإنجليزية،
> وملاحظات المراجعة، وإجابات استبيان الخصوصية. الصقها مباشرة.

| العنصر | التفاصيل |
|---|---|
| الاسم | الصلاة الإبراهيمية |
| الفئة | Reference أو Lifestyle |
| لقطات الشاشة | 6.7" و 6.5" إلزامية (من المحاكي: `⌘S`) |
| الأيقونة | 1024×1024، بلا شفافية وبلا زوايا دائرية |
| سياسة الخصوصية | `https://alsaidsaid.github.io/salat/privacy.html` ✅ جاهزة |
| شروط الاستخدام | `https://alsaidsaid.github.io/salat/terms.html` ✅ جاهزة |
| App Privacy | صرّح بـ **Identifiers → Device ID** للإعلانات |
| التصنيف العمري | 4+ |

### ٩. الرفع

```
Xcode → Product → Destination → Any iOS Device
        Product → Archive → Distribute App → App Store Connect
```

المراجعة تستغرق عادة **١–٣ أيام**.

---

## ملاحظات على السياسة والمحتوى

- **التوقيت:** الإعلانات تظهر بعد ١٠٠ صلاة كشريط سفلي ثابت فقط. تجنّبتُ الإعلانات البينية (Interstitial) عمداً — مقاطعة المستخدم أثناء الذكر تُنتج تقييمات سيئة وقد تُخالف إرشاد Apple 4.5.4.
- **اعتبار وارد:** بعض المستخدمين يعترضون على الإعلانات في تطبيقات دينية. البديل الشائع هو تطبيق مدفوع بالكامل أو تبرّع اختياري — القرار قرارك، والكود يدعم إخفاء الإعلانات كلياً بتغيير سطر واحد.
- نصوص الصلاة والحديث راجعها قبل النشر؛ أخطاء النقل في المحتوى الديني أشدّ إحراجاً من أخطاء البرمجة.

---

## ما لم يُختبر

كُتب هذا الكود على Linux حيث **لا يتوفّر Swift ولا Xcode**، فلم يُصرَّف ولم يُشغَّل. راجعته سطراً سطراً، لكن توقّع تعديلات بسيطة عند أول بناء — خاصة في أسماء أصناف AdMob التي تختلف بين الإصدارات.
