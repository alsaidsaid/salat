import StoreKit
import Combine

/// إدارة الشراء داخل التطبيق (StoreKit 2).
///
/// المنتج: شراء غير استهلاكي (Non-Consumable) بـ 0.99$ مرة واحدة مدى الحياة
/// يزيل الإعلانات نهائياً، ويُستعاد مجاناً على كل أجهزة نفس حساب Apple.
@MainActor
final class StoreManager: ObservableObject {

    /// يجب أن يطابق المعرّف المُنشأ في App Store Connect حرفياً
    static let removeAdsProductID = "com.alsaid.ibrahimiyya.removeads"

    @Published private(set) var removeAdsProduct: Product?
    @Published private(set) var hasRemovedAds = false
    @Published private(set) var isPurchasing = false
    @Published var errorMessage: String?

    // nonisolated(unsafe) لأن deinit غير معزول ولا يستطيع لمس خاصية معزولة بـ @MainActor.
    // آمن هنا: تُسنَد مرة واحدة في init ولا تُقرأ إلا للإلغاء.
    private nonisolated(unsafe) var updatesTask: Task<Void, Never>?

    init() {
        // الاستماع للمعاملات التي تصل من خارج التطبيق (شراء من جهاز آخر، استرداد، مشاركة عائلية)
        updatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self.refreshEntitlements()
                }
            }
        }

        Task {
            await loadProduct()
            await refreshEntitlements()
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    // MARK: - تحميل المنتج

    func loadProduct() async {
        do {
            let products = try await Product.products(for: [Self.removeAdsProductID])
            removeAdsProduct = products.first
            if products.isEmpty {
                errorMessage = "تعذّر تحميل المنتج. تأكد من إعداده في App Store Connect."
            }
        } catch {
            errorMessage = "تعذّر الاتصال بمتجر التطبيقات."
        }
    }

    /// السعر منسَّقاً بعملة المستخدم المحلية (مثل "0.99 US$" أو "٣٫٧٥ ر.س.")
    var displayPrice: String {
        removeAdsProduct?.displayPrice ?? "0.99$"
    }

    // MARK: - الشراء والاسترجاع

    func purchase() async {
        guard let product = removeAdsProduct else {
            await loadProduct()
            return
        }

        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    hasRemovedAds = true
                case .unverified:
                    errorMessage = "تعذّر التحقق من عملية الشراء."
                }
            case .userCancelled:
                break
            case .pending:
                errorMessage = "الشراء بانتظار الموافقة."
            @unknown default:
                break
            }
        } catch {
            errorMessage = "لم تكتمل عملية الشراء."
        }
    }

    /// مطلوب من Apple: زر ظاهر لاسترجاع المشتريات (إرشاد 3.1.1)
    func restorePurchases() async {
        do {
            try await AppStore.sync()
        } catch {
            // إلغاء المستخدم لنافذة تسجيل الدخول ليس خطأً يستحق رسالة
        }
        await refreshEntitlements()
        if !hasRemovedAds {
            errorMessage = "لم يُعثر على عملية شراء سابقة بهذا الحساب."
        }
    }

    /// مصدر الحقيقة الوحيد لملكية المنتج
    func refreshEntitlements() async {
        var owned = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.removeAdsProductID,
               transaction.revocationDate == nil {
                owned = true
            }
        }
        hasRemovedAds = owned
    }
}
