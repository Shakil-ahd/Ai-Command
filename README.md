# 🤖 SakoAI - Your Personal AI Assistant

<div align="center">

![SakoAI](assets/images/launcher_icon.png)

**Advanced AI-Powered Android Assistant with Voice & Text Commands**

[![Flutter](https://img.shields.io/badge/Flutter-3.5.0+-blue?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-1.0.0-brightgreen)]()

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [Technology Stack](#-technology-stack)

</div>

---

## 📱 About SakoAI

**SakoAI** is a powerful, AI-driven smartphone assistant that listens to your voice commands and helps you control your Android device with ease. Whether you want to open apps, make calls, search YouTube, or control your device settings, SakoAI is here to help—all in **English, Bengali, or Banglish**!

Developed with ❤️ by **Shakil Ahmed** from Bangladesh.

---

## ✨ Key Features

### 🎤 Voice & Text Commands

- **Speech Recognition**: Talk naturally to SakoAI in English, Bengali, or Banglish
- **Text Input**: Type your commands when voice isn't convenient
- **Voice Response**: Get AI-generated responses spoken aloud (toggle on/off)
- **Smart Recognition**: Understands aliases and common phrases

### 📱 App Management

- **Open Any App**: "Open Facebook", "Launch WhatsApp", "Start Instagram"
- **Quick Launch**: Fuzzy matching finds apps even with partial names
- **Recently Used**: Quickly reopen the last app you used

### ☎️ Contact & Communication

- **Make Calls**: "Call Mom", "Phone John", "Dial Dad"
- **Contact Search**: Intelligent fuzzy matching for contact names
- **Multiple Matches**: Choose from several matches when needed
- **Works Offline**: Some features work without internet

### 📺 YouTube Integration

- **Search YouTube**: "Search sad songs on YouTube", "Play funny videos"
- **Smart Mood Detection**: Recognizes mood-based searches
- **Direct Integration**: Opens YouTube directly in your browser

### 🔧 Device Control

- **Flashlight**: "Turn on flashlight", "Torch off", "Light on"
- **WiFi Control**: "Turn on WiFi", "WiFi off", "Enable WiFi"
- **Bluetooth**: "Bluetooth on", "Turn off Bluetooth"
- **Camera**: "Open camera", "Start camera app"
- **Settings**: Quick access to location, airplane mode, brightness, and more

### 🌐 Web Browsing

- **Open URLs**: Direct links like "Open amazon.com"
- **Web Search**: Access websites instantly

### 🤖 AI-Powered Chat

- **Google Gemini Integration**: Advanced conversational AI
- **Smart Responses**: Contextual and intelligent replies
- **Learning System**: Understands commands better over time
- **General Questions**: Ask anything—"What's the capital of Japan?", "Write a poem"

### 🎨 Customization

- **Multiple Themes**: Choose from vibrant theme options
- **Light/Dark Mode**: Eye-friendly display modes
- **Custom UI**: Beautiful, animated interface with smooth transitions
- **User Preferences**: Save your settings

### 💾 Chat Management

- **Persistent Chat History**: Your conversations are saved
- **Clear History**: Delete chat messages anytime
- **Chat Bubbles**: Clean, intuitive messaging interface
- **Timestamps**: Know when each message was sent

### ⚙️ Advanced Features

- **Permission Management**: Handles microphone and other permissions gracefully
- **Connectivity Awareness**: Works offline for device controls
- **Error Handling**: Clear error messages when things go wrong
- **Onboarding**: First-time user guide with feature highlights
- **Settings Panel**: Control all aspects of the app

---

## 🚀 Installation

### Prerequisites

- **Flutter SDK**: Version 3.5.0 or higher
- **Android SDK**: Android 21 or higher
- **Git**: For cloning the repository

### Steps

1. **Clone the Repository**

   ```bash
   git clone <your-repo-url>
   cd new_project_app
   ```

2. **Install Dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure Google Gemini API**
   - Get your API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Update the API key in the configuration

4. **Build the App**

   ```bash
   # For debug build
   flutter run

   # For release build
   flutter build apk --release
   ```

5. **Install on Device**
   ```bash
   flutter install
   ```

---

## 📖 Usage Guide

### 🎙️ Voice Commands

#### Open Apps

- "Open Facebook"
- "Launch WhatsApp"
- "Start Instagram"
- "Run Google Maps"

#### Make Calls

- "Call Mom"
- "Phone John"
- "Dial Dad"
- "Contact Sarah"

#### Device Controls

```
Flashlight:    "Turn on flashlight", "Torch off", "Light on"
WiFi:          "WiFi on", "Turn off WiFi", "Enable WiFi"
Bluetooth:     "Bluetooth on", "Turn off Bluetooth"
Camera:        "Open camera", "Start camera app"
Location:      "Turn on location", "GPS on"
Airplane Mode: "Airplane mode on", "Flight mode off"
Brightness:    "Increase brightness", "Brightness settings"
Mobile Data:   "Turn on mobile data", "Data off"
Sound:         "Mute", "Silent mode", "Vibration mode"
```

#### YouTube Search

- "Search sad songs on YouTube"
- "Play funny videos"
- "Find workout music on YouTube"

#### AI Chat

- "What is the capital of Japan?"
- "Write a poem"
- "How do I make coffee?"
- "Tell me a joke"

#### Multi-Language Support

- **English**: "Open WhatsApp"
- **Banglish**: "WhatsApp kholo"
- **Bengali**: "হোয়াটসঅ্যাপ খোলো"

### 💬 Text Input

Simply type your command in the input bar if voice isn't available or you prefer typing.

### ⚙️ Settings

1. Open the menu (hamburger icon)
2. Tap "Settings"
3. Customize:
   - Voice Response toggle
   - Theme selection
   - Chat history management

### 🎨 Themes

1. Menu → "Themes"
2. Browse available theme options
3. Tap a theme to apply it instantly

---

## 🛠️ Technology Stack

### Frontend Framework

- **Flutter**: Cross-platform UI framework
- **Material Design**: Clean, intuitive design language

### State Management

- **BLoC Pattern**: Scalable architecture using flutter_bloc
- **Equatable**: Easy state comparison

### AI & Natural Language

- **Google Generative AI**: Gemini API for intelligent responses
- **Fuzzy Matching**: Smart app and contact searching
- **Intent Detection**: Advanced command understanding

### Voice & Audio

- **Speech to Text**: Convert voice to commands
- **Flutter TTS**: Convert responses back to speech
- **Permission Handler**: Safe permission management

### Device Integration

- **Contacts Management**: Access and dial contacts
- **Android Intent Plus**: Control device features
- **Torch Light**: Flashlight control
- **Connectivity Plus**: Check internet status

### UI Components

- **Google Fonts**: Beautiful typography
- **Flutter Animate**: Smooth animations
- **Lottie**: Complex animations support
- **Cupertino Icons**: iOS-style icons

### Storage & Preferences

- **Shared Preferences**: Save app settings and chat history
- **Service Locator (GetIt)**: Dependency injection

### Other Utilities

- **URL Launcher**: Open links and apps
- **String Similarity**: Fuzzy matching algorithm

---

## 🎯 How It Works

1. **User Input** → Voice or text command received
2. **Intent Detection** → AI analyzes the command to understand intent
3. **Command Processing** → Appropriate action executed (open app, call, search, etc.)
4. **Response Generation** → AI generates a contextual response
5. **Voice Output** → Response spoken aloud (if enabled)
6. **Chat History** → Message saved for future reference

---

## 🔐 Permissions Required

- **Microphone**: For speech recognition
- **Contacts**: To make calls
- **Phone**: To dial contacts
- **Camera**: To open camera app
- **Location**: For location-based services
- **WiFi State**: To toggle WiFi
- **Bluetooth**: To control Bluetooth

---

## 📱 Supported Devices

- **Minimum SDK**: Android 21 (Android 5.0)
- **Target SDK**: Android 34+
- **Devices**: All Android phones and tablets

---

## 🐛 Troubleshooting

### "Microphone not available"

- Grant microphone permission in app settings
- Check device microphone is working

### "Command not recognized"

- Try using clearer language
- Use common phrases
- Check "How to Use" section for examples

### "No internet connection"

- Ensure WiFi or mobile data is enabled
- Device control features work offline
- AI chat requires internet

### "Contact not found"

- Make sure contact exists in your phone
- Try exact contact name
- Check app has contacts permission

---

## 🤝 Contributing

Contributions are welcome! To contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 👨‍💻 Developer

**Shakil Ahmed** - A passionate Flutter developer from Bangladesh 🇧🇩

---

## 🙏 Acknowledgments

- **Google**: For Gemini API and Flutter
- **Flutter Community**: For amazing packages and support
- **Users**: For feedback and suggestions

---

## 📞 Support & Feedback

- 📧 Email: Contact the developer
- 🐛 Report Bugs: Open an issue on GitHub
- 💡 Feature Requests: Suggest improvements
- ⭐ Star this repo if you find it helpful!

---

## 📚 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [BLoC Pattern](https://bloclibrary.dev)
- [Google Generative AI](https://ai.google.dev)
- [Speech Recognition Package](https://pub.dev/packages/speech_to_text)

---

<div align="center">

**Made with ❤️ using Flutter**

_Version 1.0.0 - © 2026 SakoAI_

</div>
