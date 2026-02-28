# 🎓 শিশু শিক্ষা - Kids Learning App

একটি সম্পূর্ণ **ফ্রি** বাচ্চাদের শিক্ষামূলক অ্যাপ যা Flutter এবং GetX দিয়ে তৈরি!

## ✨ Features (বৈশিষ্ট্য)

### 📝 বাংলা বর্ণমালা

- স্বরবর্ণ (অ, আ, ই... ঔ)
- ব্যঞ্জনবর্ণ (ক, খ, গ... ঞ)
- উচ্চারণ সহ
- ইংরেজি transliteration

### 🔢 সংখ্যা শিখি

- ০ থেকে ১০ পর্যন্ত
- বাংলা সংখ্যা (০, ১, ২...)
- উচ্চারণ (শূন্য, এক, দুই...)
- Emoji সহ (0️⃣, 1️⃣, 2️⃣...)

### 🎨 রঙ চিনি

- ১০টি মৌলিক রঙ
- বাংলা নাম (লাল, সবুজ, নীল...)
- রঙিন প্রদর্শন
- ইংরেজি নাম

### 🐾 প্রাণীর নাম

- ১০টি প্রাণী
- বাংলা নাম (বিড়াল, কুকুর, হাতি...)
- Emoji সহ (🐱, 🐶, 🐘...)
- ইংরেজি নাম

### 🍎 ফলের নাম

- ১০টি ফল
- বাংলা নাম (আম, কলা, আপেল...)
- Emoji সহ (🥭, 🍌, 🍎...)
- ইংরেজি নাম

## 🎨 Design Features

- ✅ **Beautiful Gradient UI** - আকর্ষণীয় রঙিন ডিজাইন
- ✅ **Bengali Typography** - Google Fonts দিয়ে সুন্দর বাংলা ফন্ট
- ✅ **Interactive Cards** - বড় এবং স্পষ্ট প্রদর্শন
- ✅ **Progress Tracking** - কতটুকু শিখেছে দেখা যায়
- ✅ **Smooth Navigation** - সহজ navigation
- ✅ **Kid-Friendly** - বাচ্চাদের জন্য উপযুক্ত

## 🚀 কিভাবে চালাবেন

### Prerequisites

```bash
flutter --version  # Flutter installed থাকতে হবে
```

### Installation

```bash
# Dependencies install করুন
flutter pub get

# Chrome এ রান করুন
flutter run -d chrome

# Android এ রান করুন
flutter run -d android

# iOS এ রান করুন (Mac এ)
flutter run -d ios
```

## 📁 Project Structure

```
lib/
├── main.dart                 # Entry point
├── models/
│   └── lesson_model.dart     # Data models
├── controllers/
│   └── home_controller.dart  # GetX controllers
├── views/
│   ├── home_view.dart        # Home screen
│   └── lesson_view.dart      # Learning screen
├── bindings/
│   └── home_binding.dart     # Dependency injection
└── data/
    └── lesson_data.dart      # All learning content
```

## 🎯 কিভাবে ব্যবহার করবেন

1. **Home Screen** - ৫টি category দেখবেন
2. **Category Select** - যেকোনো একটি card এ tap করুন
3. **Learning** - বড় card এ content দেখবেন
4. **Navigation** - "আগের" এবং "পরের" বাটন দিয়ে navigate করুন
5. **Progress** - উপরে progress bar দেখবেন
6. **Back** - Back button দিয়ে home এ ফিরে যান

## 💡 Technology Stack

- **Framework:** Flutter 3.10+
- **State Management:** GetX 4.6.6
- **Fonts:** Google Fonts (Noto Sans Bengali)
- **Architecture:** MVC with GetX
- **No Paid Tools:** সম্পূর্ণ ফ্রি!

## 🎨 Color Scheme

- Primary: `#6B73FF` (Blue)
- Accent Colors:
  - Red: `#FF6B6B`
  - Teal: `#4ECDC4`
  - Orange: `#FFA07A`
  - Purple: `#9B59B6`
  - Yellow: `#F39C12`

## 📱 Play Store এ Publish করার জন্য

### 1. App Icon তৈরি করুন

```bash
# pubspec.yaml এ flutter_launcher_icons যোগ করুন
flutter pub add flutter_launcher_icons
```

### 2. Build করুন

```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store এর জন্য)
flutter build appbundle --release
```

### 3. App Details

- **Name:** শিশু শিক্ষা - Kids Learning
- **Category:** Education
- **Age:** 3+
- **Price:** Free
- **Ads:** AdMob যোগ করতে পারেন

### 4. Screenshots নিন

- Home screen
- প্রতিটি category এর screenshot
- Learning screen

## 🔮 Future Features (ভবিষ্যতে যোগ করা যাবে)

- [ ] 🔊 Audio pronunciation
- [ ] 🎮 Quiz games
- [ ] ⭐ Star rewards system
- [ ] 📊 Progress tracking
- [ ] 🎵 Background music
- [ ] 🌙 Dark mode
- [ ] 📱 Offline support
- [ ] 🏆 Achievements
- [ ] 👨‍👩‍👧 Parent dashboard
- [ ] 🌍 More languages

## 📝 License

Free to use and modify!

## 🤝 Contributing

এই অ্যাপটি improve করতে চাইলে:

1. Fork করুন
2. Feature যোগ করুন
3. Pull request পাঠান

## 💰 Monetization Ideas

1. **AdMob Ads** - Banner এবং Interstitial ads
2. **Premium Version** - Ad-free + extra content
3. **In-App Purchase** - নতুন categories unlock
4. **Subscription** - Monthly premium features

## 📞 Support

কোনো সমস্যা হলে issue create করুন!

---

**Made with ❤️ for Bangladeshi Kids**

**শুভকামনা! আপনার অ্যাপ Play Store এ সফল হোক!** 🎉
