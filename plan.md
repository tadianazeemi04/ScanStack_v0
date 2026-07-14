# ScanStack - Development Plan & Log

*This document tracks the ongoing development progress, tasks to be completed, and a timestamped log of what has been accomplished.*

## Task Checklist (Next 48 Hours)
- [ ] **Home Screen:** UI layout and basic navigation.
- [x] **Scanning Module:** Album selection, ML Classification integration, Vision OCR integration, and summary report generation.
- [x] **Stacks Module:** Folder UI and logic to display images categorized by the ML model.
- [x] **Image Preview:** UI to show image, metadata (size, path, date), and OCR text.
- [ ] **Search Module:** Search bar and logic to filter by OCR text and Stack names.
- [ ] **Settings:** *Pending requirements.*

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
