#!/usr/bin/env bash
# إعداد مشروع Xcode بأمر واحد. يُشغَّل على جهاز Mac فقط.
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

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "▸ تثبيت XcodeGen…"
  if command -v brew >/dev/null 2>&1; then
    brew install xcodegen
  else
    echo "❌ Homebrew غير مثبّت. ثبّته من https://brew.sh ثم أعد التشغيل."
    exit 1
  fi
fi

echo "▸ توليد مشروع Xcode…"
xcodegen generate

echo
echo "✅ تم إنشاء Ibrahimiyya.xcodeproj"
echo
echo "الخطوات المتبقية قبل الرفع للمتجر:"
echo "  ١. افتح المشروع:  open Ibrahimiyya.xcodeproj"
echo "  ٢. Signing & Capabilities ← اختر فريق المطوّر الخاص بك"
echo "  ٣. استبدل معرّفات AdMob في:"
echo "       ios/project.yml            (GADApplicationIdentifier)"
echo "       Ibrahimiyya/AdBannerView.swift  (bannerUnitID داخل فرع #else)"
echo "     ثم أعد تشغيل هذا السكربت لتحديث Info.plist"
echo "  ٤. انسخ قائمة SKAdNetworkItems كاملة من وثائق AdMob إلى project.yml"
echo "  ٥. أنشئ منتج الشراء في App Store Connect بالمعرّف:"
echo "       com.alsaid.ibrahimiyya.removeads   (نوع: Non-Consumable، السعر: 0.99\$)"
echo
echo "للتشغيل على المحاكي مباشرة:"
echo "  xcodebuild -scheme Ibrahimiyya -destination 'platform=iOS Simulator,name=iPhone 16' build"
