#!/usr/bin/env bash
# إعداد مشروع Xcode بأمر واحد. يُشغَّل على جهاز Mac فقط.
#
# لا يحتاج Homebrew ولا صلاحية مدير ولا كلمة مرور:
# إن لم يجد XcodeGen، حمّل النسخة الجاهزة من GitHub إلى مجلد المشروع واستعملها.
set -euo pipefail

cd "$(dirname "$0")"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "❌ هذا السكربت يعمل على macOS فقط — بناء تطبيقات iOS يتطلب Xcode."
  exit 1
fi

if ! xcode-select -p >/dev/null 2>&1; then
  echo "❌ Xcode غير مثبّت. ثبّته من Mac App Store ثم شغّل: xcode-select --install"
  exit 1
fi

# ── العثور على XcodeGen أو إحضاره ──────────────────────────────────────────
TOOLS_DIR=".tools"
LOCAL_XCODEGEN="$TOOLS_DIR/xcodegen/bin/xcodegen"

if command -v xcodegen >/dev/null 2>&1; then
  XCODEGEN="xcodegen"
  echo "▸ XcodeGen موجود في النظام"

elif [[ -x "$LOCAL_XCODEGEN" ]]; then
  XCODEGEN="$LOCAL_XCODEGEN"
  echo "▸ XcodeGen موجود في $TOOLS_DIR"

else
  echo "▸ XcodeGen غير موجود — تحميل النسخة الجاهزة (بلا تثبيت ولا كلمة مرور)…"
  mkdir -p "$TOOLS_DIR"

  if ! curl -fL --progress-bar -o "$TOOLS_DIR/xcodegen.zip" \
       "https://github.com/yonaskolb/XcodeGen/releases/latest/download/xcodegen.zip"; then
    echo "❌ فشل التحميل. تحقق من اتصالك بالإنترنت ثم أعد المحاولة."
    exit 1
  fi

  unzip -q -o "$TOOLS_DIR/xcodegen.zip" -d "$TOOLS_DIR"
  rm -f "$TOOLS_DIR/xcodegen.zip"
  chmod +x "$LOCAL_XCODEGEN"

  # تحرير الملف من حجر macOS إن وُضع عليه
  xattr -dr com.apple.quarantine "$TOOLS_DIR/xcodegen" 2>/dev/null || true

  if [[ ! -x "$LOCAL_XCODEGEN" ]]; then
    echo "❌ تعذّر تجهيز XcodeGen."
    exit 1
  fi

  XCODEGEN="$LOCAL_XCODEGEN"
  echo "✓ تم — بلا Homebrew"
fi

# ── توليد المشروع ──────────────────────────────────────────────────────────
echo "▸ توليد مشروع Xcode…"
"$XCODEGEN" generate

if [[ ! -d "Ibrahimiyya.xcodeproj" ]]; then
  echo "❌ لم يُنشأ المشروع. راجع رسائل XcodeGen أعلاه."
  exit 1
fi

echo
echo "✅ تم إنشاء Ibrahimiyya.xcodeproj"
echo
echo "الخطوة التالية — بناء التطبيق:"
echo
echo "  cd ~/salat/ios && xcodebuild -project Ibrahimiyya.xcodeproj \\"
echo "    -scheme Ibrahimiyya -destination 'generic/platform=iOS Simulator' build"
echo
echo "ولفتح المشروع في Xcode:  open Ibrahimiyya.xcodeproj"
