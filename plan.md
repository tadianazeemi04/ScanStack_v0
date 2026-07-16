# ScanStack - Development Plan & Log

*This document tracks the ongoing development progress, tasks to be completed, and a timestamped log of what has been accomplished.*

## Task Checklist (Next 48 Hours)
- [x] **Home Screen:** UI layout and basic navigation.
- [x] **Scanning Module:** Album selection, ML Classification integration, Vision OCR integration, and summary report generation.
- [x] **Stacks Module:** Folder UI and logic to display images categorized by the ML model.
- [x] **Image Preview:** UI to show image, metadata (size, path, date), and OCR text.
- [x] **Search Module:** Search bar and logic to filter by OCR text and Stack names.
- [x] **Settings:** Profile UI, Premium Card, dynamic Core Data Storage Insights, and global Face ID App Lock.

---

## Action Log

**[2026-07-09]**
- **11:30 AM:** Created `project_description.md` to outline the core functionality of the app based on user requirements (Scanning, Stacks, Image Preview, Search, Settings).
- **11:30 AM:** Created this `plan.md` file to track development progress over the crucial next 2 days.

**[Previous Work Completed]**
- **Authentication Flow Full Implementation:**
  - Designed and built `Registration.swift` using a custom Glassmorphism UI with animated backgrounds and an interactive rotating gradient on text fields.
  - Built `RegistrationViewModel.swift` with real-time field validation and Firebase Auth integration.
  - Implemented a complete `Security.swift` view featuring a dynamic, color-changing Password Strength meter.
  - Created `EmailVerificationView.swift` to strictly lock users out of the Home screen until they verify their email address.
  - Designed and built `Login.swift` featuring a password visibility toggle and a "Forgot Password" feature connected to Firebase.
  - Integrated **Google Sign-In** seamlessly across both Login and Registration.
  - Handled common iOS simulator edge-cases (e.g., auto-trimming trailing spaces in email addresses to prevent Firebase credential errors).
  - Configured top-level routing in `StartupView.swift` to direct unauthenticated users to Onboarding/Registration, and fully verified users to the Home Screen.

**[2026-07-13]**
- **Activity / Scanning Module:**
  - Resolved `ZStack` touch interception issues in `ActivityScreen`.
  - Replaced native iOS `actionSheet` with a custom gradient dropdown menu for "Scan Now" options (Camera, Photos, Album).
  - Integrated `ScanningViewModel` to process selected images via CoreML (`ScanStackClassifier_1`) and Vision OCR.
  - Set up persistence to save scanned images and metadata to Core Data (`ScannedDocument` entity).
- **Stacks Module:**
  - Created `StacksViewModel` to query Core Data and group images by category name.
  - Built `StacksScreen` displaying "Recently" and "Other Stacks" categories.
  - Built `InsideStackScreen` featuring a 3-column photo grid and sorting options (newest/oldest).
- **Image Preview Module:**
  - Designed full-screen image preview with a swipe-up "Overview" pane.
  - Displayed detailed metadata (Name, Date, Path, Size, Stack Name) and raw extracted OCR text using custom UI matching premium mockups.

**[2026-07-16]**
- **UI Polish & Navigation Fixes:**
  - **Image Preview Restructure:** Redesigned `ImagePreview.swift` to use a strict `VStack` layout. Added a solid black header to prevent the image from bleeding into navigation controls. Implemented a bottom floating "Overview" button overlaying a solid white card layout to perfectly match the Figma design.
  - **Favorites System:** Implemented a persistent "Heart" favorite system in `ImagePreview` connected to `UserDefaults`. Synthesized a permanent **"My Favorite"** stack pinned to the top of the Dashboard and Collections, which dynamically updates via `NotificationCenter` broadcasts.
  - **Collection Screen Bug Fixes:** Fixed unresponsive touch bounds by adding `.contentShape(Rectangle())` to custom stack cards. Resolved a major navigation bug by replacing the nested `NavigationStack` with `.fullScreenCover` in `StacksCollectionScreen`.
  - **Activity Screen Dynamic State:** Replaced the hard-coded "13 new screenshots found" placeholder with a dynamic list that accurately persists and displays the `extractionStats` from the most recent scan.
- **Search Module:**
  - Built `SearchViewModel.swift` using Combine to debounce search queries for optimal performance, checking Core Data against `extractedText` and `stackName`.
  - Built `SearchScreen.swift` featuring a custom search bar, dynamic empty/no-results states, and a 3-column `LazyVGrid` mimicking the Stacks UI.
  - Wired search results directly to `ImagePreview` via full-screen cover navigation.
- **Home Screen Module:**
  - Replaced placeholder view with a rich dashboard layout.
  - Built `HomeViewModel.swift` to fetch user's display name from Firebase Auth and calculate total scans/stacks from Core Data.
  - Built `HomeScreen.swift` featuring a custom greeting, two glassmorphism stat cards, a horizontally scrolling "Recent Activity" carousel, and an integrated top-right Log Out button.
  - Wired recent scan thumbnails to launch `ImagePreview` via `.fullScreenCover`.
- **Settings Module & App Lock:**
  - Designed and built `SettingsScreen.swift` mirroring the Figma UI (Profile header, Premium Card, Storage Insights).
  - Implemented `SettingsViewModel.swift` to compute physical device storage used by saved Core Data documents.
  - Designed `SecuritySettingsScreen.swift` featuring a toggle switch for global App Lock.
  - Built `AppLockManager.swift` leveraging `LAContext` to integrate Face ID, Touch ID, or Passcode.
  - Intercepted `.scenePhase` in `StartupView.swift` to enforce global App Lock anytime the app is backgrounded.
- **Subscription Module:**
  - Built `SubscriptionScreen.swift` matching the new Figma design (gradient header, highlighted Pro card with custom overlapping badge, Basic tier card).
  - Updated `SettingsScreen.swift` to route to the Pricing Plans view when tapping the Manage Subscription or Pricing Plans buttons.
- **Ads & Screenshots Extraction:**
  - Added "All Screenshots" option to the Activity tab dropdown.
  - Built `LimitPopupScreen.swift` restricting full extractions behind an Ad Wall.
  - Built `AdScreen.swift` with a strict 30-second timer and hidden close button logic.
  - Upgraded `ScanningViewModel` to use `PhotoKit` to fetch `PHAsset`s natively from the user's hidden Screenshots album.
