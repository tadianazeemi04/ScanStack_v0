<p align="center">
  <h1 align="center">📱 ScanStack</h1>
  <p align="center">
    <strong>AI-Powered Screenshot Organizer for iOS</strong>
  </p>
  <p align="center">
    Automatically classify, extract text from, and organize your screenshots using on-device machine learning.
  </p>
  <p align="center">
    <img src="https://img.shields.io/badge/Platform-iOS%2016%2B-blue?style=flat-square&logo=apple" />
    <img src="https://img.shields.io/badge/Language-Swift%205.9-orange?style=flat-square&logo=swift" />
    <img src="https://img.shields.io/badge/UI-SwiftUI-purple?style=flat-square&logo=swift" />
    <img src="https://img.shields.io/badge/ML-CoreML%20%7C%20Vision-green?style=flat-square&logo=apple" />
    <img src="https://img.shields.io/badge/Architecture-MVVM-red?style=flat-square" />
  </p>
</p>

---

## 📌 Overview

ScanStack is a native iOS application that solves the universal problem of **screenshot clutter**. The average smartphone user accumulates thousands of screenshots — recipes, notes, receipts, social media posts, schedules — all dumped into one unorganized camera roll with no way to search or categorize them.

ScanStack uses **on-device AI** to automatically:
- **Classify** screenshots into smart categories (Social, Education, Shopping, Finance, etc.)
- **Extract text** from images using OCR, making them fully searchable by keyword
- **Organize** related screenshots into browsable, categorized "Stacks"

All processing happens **100% on-device** — no cloud servers, no data uploads, complete user privacy.

---

## ✨ Key Features

| Feature | Description |
|---|---|
| 🤖 **AI Classification** | Custom-trained CoreML model classifies screenshots into intelligent categories |
| 🔍 **OCR Text Extraction** | Apple Vision framework extracts all text from screenshots for keyword search |
| 📚 **Smart Stacks** | Auto-groups screenshots by category into browsable collections |
| 📸 **Bulk Screenshot Scan** | Scans the entire Screenshots album with one tap using PhotoKit |
| 🔒 **Privacy-First** | Zero cloud dependency — all ML inference runs on-device |
| 🚫 **Duplicate Prevention** | Tracks scanned assets to prevent re-processing |
| 💾 **Memory-Safe Processing** | Stream-processes images one at a time to handle 1000+ screenshots |
| 🎯 **Real-Time Progress** | Live progress bar, ETA, and extraction stats during scanning |
| 📷 **Multi-Source Input** | Scan from Camera, Photo Picker, Album Selection, or All Screenshots |
| 🔎 **Full-Text Search** | Search across all extracted text and categories instantly |
| 💰 **Ad Monetization** | Integrated Google AdMob (Rewarded Video + Banner Ads) |
| 🔐 **App Lock** | Biometric authentication for app security |

---

## 🏗️ Architecture

ScanStack follows the **MVVM (Model-View-ViewModel)** architecture pattern:

```
┌─────────────────────────────────────────────────┐
│                     VIEW                         │
│  (SwiftUI Screens — declarative, reactive UI)    │
│  ActivityScreen · HomeScreen · StacksScreen      │
│  SearchScreen · SettingsScreen                   │
└──────────────────────┬──────────────────────────┘
                       │ @StateObject / @Published
┌──────────────────────▼──────────────────────────┐
│                  VIEWMODEL                       │
│  (Business Logic — @MainActor, ObservableObject) │
│  ScanningViewModel · HomeViewModel               │
│  StacksViewModel · SearchViewModel               │
└──────────────────────┬──────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────┐
│                    MODEL                         │
│  Core Data (ScannedDocument) · CoreML Model      │
│  PhotoKit · Vision OCR · UserDefaults            │
└─────────────────────────────────────────────────┘
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Language** | Swift 5.9 |
| **UI Framework** | SwiftUI |
| **AI / ML** | CoreML (Image Classification) |
| **OCR** | Apple Vision (`VNRecognizeTextRequest`) |
| **Photo Access** | PhotoKit (`PHAssetCollection`, `PHImageManager`) |
| **Persistence** | Core Data (SQLite) |
| **Reactive Binding** | Combine (`@Published`, `ObservableObject`) |
| **Concurrency** | Swift async/await, `@MainActor` |
| **Ad Monetization** | Google Mobile Ads SDK (AdMob) |
| **Ad Attribution** | SKAdNetwork |
| **Architecture** | MVVM |
| **Min Deployment** | iOS 16.0 |

---

## 📂 Project Structure

```
ScanStack_v0/
├── ScanStack_v0App.swift              # App entry point & AdMob initialization
├── ContentView.swift                  # Root TabView navigation
├── ScanStackClassifier_1.mlmodel      # Trained CoreML classification model
│
├── Modules/
│   ├── Activity/                      # Main scanning module
│   │   ├── ActivityScreen.swift       # Scan UI with dropdown options
│   │   └── ScanningViewModel.swift    # Core scanning logic (PhotoKit + CoreML + Vision)
│   │
│   ├── Home/                          # Dashboard
│   │   ├── HomeScreen.swift           # Recent scans & quick stats
│   │   └── HomeViewModel.swift
│   │
│   ├── Stacks/                        # Categorized collections
│   │   ├── StacksScreen.swift         # Grid of category stacks
│   │   ├── InsideStackScreen.swift    # Documents within a stack
│   │   └── StacksViewModel.swift
│   │
│   ├── Search/                        # Full-text search
│   │   ├── SearchScreen.swift
│   │   └── SearchViewModel.swift
│   │
│   ├── Ads/                           # Ad monetization
│   │   ├── BannerAdView.swift         # AdMob banner component
│   │   ├── RewardedAdManager.swift    # Rewarded video ad singleton
│   │   ├── LimitPopupScreen.swift     # Premium feature gate UI
│   │   └── AdScreen.swift             # Full-screen ad view
│   │
│   ├── ImagePreview/                  # Full-screen image viewer
│   ├── Settings/                      # App settings & preferences
│   ├── Subscription/                  # Pricing plans UI
│   ├── Authentication/                # App lock & biometrics
│   ├── Profile/                       # User profile
│   └── Startup/                       # Welcome & onboarding
│
├── Model/                             # Data models & extensions
├── Common/                            # Shared utilities & helpers
├── Perisistance/                      # Core Data stack (PersistenceController)
│
├── Assets.xcassets/                   # App icons, colors, images
└── ScanStack_v0.xcdatamodeld/         # Core Data schema (ScannedDocument entity)
```

---

## ⚙️ Setup & Installation

### Prerequisites
- **Xcode 15+**
- **iOS 16.0+** deployment target
- Physical iPhone recommended (Camera & PhotoKit features require a real device)

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/ScanStack.git
   cd ScanStack
   ```

2. **Open in Xcode**
   ```bash
   open ScanStack_v0.xcodeproj
   ```

3. **Install Dependencies**
   - Google Mobile Ads SDK is integrated via Swift Package Manager.
   - Xcode will automatically resolve packages on first open.

4. **Configure Signing**
   - Select your Development Team under `Signing & Capabilities`.
   - Update the Bundle Identifier if needed.

5. **Build & Run**
   - Select your target device or simulator.
   - Press `Cmd + R` to build and run.

> **Note:** For testing ads, the app uses Google's official test Ad Unit IDs. Replace them with your own production IDs before submitting to the App Store.

---

## 🔐 Privacy

ScanStack is designed with a **privacy-first** approach:

- ✅ All AI/ML inference runs **on-device** using CoreML and Vision
- ✅ No screenshot data is uploaded to any external server
- ✅ Photo library access requires explicit user consent
- ✅ Camera access requires explicit user consent
- ✅ Extracted text and classifications are stored locally in Core Data

---

## 📄 License

This project is developed as a **Final Year Project (FYP)** and is intended for academic and educational purposes.

---

<p align="center">
  Built with ❤️ using Swift & SwiftUI
</p>
