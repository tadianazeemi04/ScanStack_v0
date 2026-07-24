# 🎯 Udhaarly FYP Demo — Complete Q&A Preparation Guide

> **Purpose**: Every possible question your supervisor (especially Mr. Wajahat Chaudhary) can ask during the demo, with confident, technically accurate answers. Organized module-by-module.

---

## 🔷 PART 1: PROJECT OVERVIEW & JUSTIFICATION

### Q1: What problem does this app solve?
**A:** People frequently need items temporarily (a drill for a weekend, formal clothes for an event, a book for a semester) but buying them permanently is expensive and wasteful. At the same time, many people own items that sit idle. There's no dedicated, trustworthy platform to connect these two sides. Udhaarly solves this by providing a peer-to-peer borrowing and lending platform where people can share items within their community — eliminating unnecessary purchases, reducing waste, and letting owners monetize idle assets.

### Q2: Why "Udhaarly"? What does the name mean?
**A:** "Udhaarly" comes from the Urdu word "Udhaar" (meaning "to borrow/lend"). It reflects the core concept — borrowing and lending items between people. The name instantly communicates the app's purpose to our target Pakistani audience.

### Q3: Who is your target audience?
**A:** University students, hostel residents, and urban communities in Pakistan — people who frequently need items for short durations (electronics, books, furniture, fashion) and can't justify purchasing them permanently.

### Q4: What makes this different from OLX or Facebook Marketplace?
**A:** OLX and Facebook Marketplace are for **buying and selling permanently**. Udhaarly is specifically for **temporary borrowing and lending** with:
- A structured request lifecycle (pending → accepted → returned → completed)
- Duration-based pricing (per day/week/month)
- Built-in accountability through reviews and ratings
- In-app real-time chat with read receipts
- Return verification with photo evidence

### Q5: Why did you build this as an iOS app and not a web app?
**A:** iOS was chosen because:
1. It's our FYP requirement to build a native mobile app
2. Native iOS gives access to device capabilities (camera, photo library, keychain, local notifications)
3. SwiftData provides robust on-device persistence
4. UIKit gives pixel-perfect control over the premium UI we wanted

### Q6: Why no backend/server? Why is everything local?
**A:** This is a deliberate architectural decision for the FYP scope. We focused on building a **fully functional prototype** demonstrating the complete user journey on a single device. The architecture is designed so that `LocalDataManager` can be swapped with a network API layer (Firebase, REST API) in production without changing any UI code — the singleton pattern makes this a clean swap.

---

## 🔷 PART 2: TECH STACK & ARCHITECTURE

### Q7: What is your complete tech stack?
**A:** Swift, UIKit (100% programmatic UI), SwiftData (database), Auto Layout, Core Animation (CAGradientLayer), PhotosUI, UserNotifications, UserDefaults, iOS Keychain, JSON (Codable) — all native Apple frameworks, zero third-party dependencies.

### Q8: Why UIKit instead of SwiftUI?
**A:** UIKit was chosen because:
1. It provides **fine-grained control** over complex layouts (custom cells, floating buttons, gradient headers)
2. UIKit is **production-proven** and used by most professional iOS apps
3. SwiftUI still has limitations with complex navigation stacks and custom animations
4. Our supervisor recommended UIKit for better learning of iOS fundamentals

### Q9: Why programmatic UI instead of Storyboards?
**A:** Programmatic UI gives us:
1. **No merge conflicts** — Storyboard XML files cause massive git conflicts in team projects
2. **Better reusability** — Custom views like `GradientView`, `GradientCardView`, `RequestCardView` can be instantiated anywhere
3. **Full control** — Dynamic layouts, conditional UI, and animations are easier to implement in code
4. **Performance** — No Storyboard loading overhead

### Q10: What architecture pattern are you using?
**A:** MVC (Model-View-Controller) — the standard iOS architecture:
- **Models**: SwiftData `@Model` classes (`LocalUser`, `LocalProduct`, `LocalRequest`, `LocalChat`, `LocalMessage`, `LocalReview`, `LocalNotification`)
- **Views**: Custom `UITableViewCell` / `UICollectionViewCell` subclasses and reusable components
- **Controllers**: `UIViewController` subclasses handling logic and data flow

### Q11: Why MVC and not MVVM or VIPER?
**A:** MVC is the **native iOS pattern** recommended by Apple. For the scale of this FYP (7 models, ~40 screens), MVC keeps the codebase straightforward and maintainable. MVVM/VIPER add unnecessary abstraction layers for a project of this size. However, we've applied clean separation — `LocalDataManager` handles all data operations, `NotificationManager` handles alerts, and `BackupManager` handles recovery — so the controllers aren't bloated with business logic.

### Q12: Why SwiftData instead of Core Data or Realm?
**A:** SwiftData is Apple's **latest persistence framework** (introduced iOS 17), built on top of Core Data but with:
1. **Native Swift syntax** — Uses `@Model` macro instead of XML schema files
2. **Type-safe queries** — `#Predicate` and `FetchDescriptor` with compile-time safety
3. **Automatic schema migration** — Handles model changes without manual migration code
4. **Less boilerplate** — No NSManagedObjectContext ceremony

### Q13: Why Singleton pattern for LocalDataManager?
**A:** The Singleton pattern (`LocalDataManager.shared`) ensures:
1. **Single source of truth** — One `ModelContainer` and `ModelContext` for the entire app
2. **Thread safety** — Prevents multiple contexts from conflicting
3. **Consistent state** — All screens read/write from the same instance
4. **Easy testability** — Can be swapped with a mock in unit tests

### Q14: How many data models do you have and what are they?
**A:** 7 SwiftData models:

| Model | Purpose | Key Attributes |
|:---|:---|:---|
| `LocalUser` | User accounts | `email` (unique), name, location, phone, address, DOB, password, profileImage |
| `LocalProduct` | Listed items | `id`, name, category, price, duration, images, publisherEmail, isDeleted, isFavorite |
| `LocalRequest` | Borrow/lend transactions | productId, borrower/lender emails, status, return/delay data, review flags |
| `LocalChat` | Conversation threads | participant emails, productId, lastMessage, lastUpdated |
| `LocalMessage` | Individual messages | chatId, senderEmail, content, imageData, isRead, isDelivered |
| `LocalReview` | User ratings | reviewer/reviewee emails, rating (1-5), title, body |
| `LocalNotification` | In-app alerts | recipientEmail, title, body, type, isRead, relatedId |

---

## 🔷 PART 3: AUTHENTICATION MODULE

### Q15: Walk me through the complete registration flow.
**A:** The flow is: **Home Screen → Sign Up → OTP Verification → Profile Info → Main App**
1. **HomeViewController**: Landing screen with swipe-up gesture (threshold: -100pt drag) that transitions to SignUp
2. **SignupViewController**: User enters email, password, confirm password. Real-time validation checks email format, password rules (≥6 chars + 1 digit), and match. Must accept Terms & Privacy Policy via checkbox
3. **OTPViewController**: 6-digit code entry with auto-focus jumping between boxes. 60-second resend timer
4. **InfoDataViewController**: Collects profile picture (required), first name, last name, location, phone, address, and DOB (must be ≥16 years old). Saves user to SwiftData, password to Keychain, sets session in UserDefaults
5. **MainTabBarController**: User lands on the main app

### Q16: How does your login/authentication work?
**A:** Three-layer verification:
1. **Keychain lookup** — `KeychainHelper.shared.read(account: email)` retrieves the stored encrypted password
2. **Password comparison** — Entered password is compared against the Keychain-stored value
3. **Profile check** — `LocalDataManager.shared.fetchUser(email:)` verifies the profile exists in SwiftData

If password matches but profile is missing (incomplete registration), the user is redirected to `InfoDataViewController` to complete their profile.

### Q17: Why Keychain for passwords and not UserDefaults?
**A:** **Security**. UserDefaults stores data as plain-text plist files — anyone with device access can read them. The iOS Keychain provides:
- **Hardware-level encryption** (Secure Enclave on modern iPhones)
- **Sandboxed storage** — Other apps cannot access it
- **Persistence across app reinstalls**
- It's the **Apple-recommended** way to store credentials

### Q18: How do you persist the login session?
**A:** Two `UserDefaults` keys:
- `isUserLoggedIn` (Bool) — Checked in `SceneDelegate` at app launch
- `currentUserEmail` (String) — Identifies the logged-in user throughout the app

In `SceneDelegate.scene(_:willConnectTo:)`, if `isUserLoggedIn == true`, the root is set to `MainTabBarController`. Otherwise, it's set to `HomeViewController` inside a `UINavigationController`.

### Q19: What validation rules do you enforce on sign-up?
**A:**
- **Email**: Regex `^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}$`
- **Password**: Minimum 6 characters AND at least 1 numeric digit
- **Confirm Password**: Must exactly match password
- **Terms & Privacy**: Checkbox must be checked
- **Profile Picture**: Required (default placeholder is rejected)
- **All 6 profile fields**: Must be non-empty
- **Age**: Must be ≥16 years old (calculated from DOB picker)

### Q20: What happens if someone enters an email that doesn't exist during login?
**A:** Keychain returns `nil`. We display an alert: *"No account found for this email. Would you like to sign up?"* — guiding them to registration.

### Q21: What happens if someone enters the wrong password?
**A:** Keychain returns a stored password but comparison fails. We display: *"Incorrect password. Please try again."*

### Q22: Is the OTP actually verified against a server?
**A:** No — it's a **client-side simulation**. The OTP screen validates that 6 numeric digits are entered, then forwards the user. In a production version, this would integrate with an SMS gateway (Twilio, Firebase Auth) for server-side verification.

### Q23: How does the password visibility toggle work? Any edge cases?
**A:** A custom `UIButton` with `eye` / `eye.slash` SF Symbols is added as `rightView` on password fields. When toggled:
1. `isSecureTextEntry` is flipped
2. **Critical edge case fix**: The text is temporarily cleared and re-set (`textField.text = ""` then `textField.text = currentText`) to prevent a **UIKit font rendering bug** where toggling secure entry causes the font to distort

### Q24: How does the admin login work?
**A:** Hardcoded bypass — if email is `"admin123@admin.com"` and password is `"admin123"`, the user is directly taken to `AdminViewController` (which shows all users, products, and the backup/restore panel). This is for demo/development purposes.

---

## 🔷 PART 4: DASHBOARD & PRODUCT MANAGEMENT

### Q25: What does the Dashboard show?
**A:** The Dashboard (`DashboardViewController`) displays:
1. **Brand logo** with notification bell (showing unread badge count)
2. **Search bar** — Tapping it pushes `SearchViewController` (not inline search)
3. **Category carousel** — Horizontal scroll of category pills (Mobile, Fashion, Electronics, Books, etc.)
4. **Udhaarly Premium banner** — Dark card promoting subscription upgrade
5. **Recent Ads grid** — 2-column collection view showing all non-deleted products, newest first

### Q26: How does your search work?
**A:** `SearchViewController` loads **all products** from `LocalDataManager.shared.fetchProducts()`, then uses real-time `textDidChange` filtering that matches the query (case-insensitive) against `product.name` OR `product.category`. Results update instantly as the user types.

### Q27: How does category filtering work?
**A:** Two approaches:
1. **Dashboard category tap**: Pushes `CategoryProductsViewController(category: selectedCategory)` which calls `fetchProducts(byCategory: category.rawValue)` — a SwiftData query with a `#Predicate` filtering on the `category` field
2. **"See All" button**: Opens `CategoriesViewController` — a 3-column grid of all 9 categories, each tapping through to filtered results

### Q28: What categories do you support?
**A:** 9 categories defined as a `Category` enum: All, Software, Home & Decor, Electronics, Furniture, Fashion, Books, Mobile, Other. Each has an SF Symbol icon, pastel theme color, and accent color.

### Q29: How do you handle product images?
**A:**
- **Storage**: Cover image uses `@Attribute(.externalStorage)` (SwiftData stores it as a separate file, not in SQLite). Gallery supports up to 5 images stored as `[Data]`
- **Compression**: Images are compressed to JPEG at 80% quality (~reasonable file size)
- **Display**: Product detail has a horizontal paging `UICollectionView` image slider with `UIPageControl`
- **Fallback**: If no image data exists, a `photo` SF Symbol placeholder is shown

### Q30: Why `@Attribute(.externalStorage)` for images?
**A:** **Performance**. Storing large binary blobs (images) directly in SQLite makes queries slow and inflates the database file. `externalStorage` tells SwiftData to store the binary data as **separate files on disk** while keeping a lightweight reference in the database. This keeps the main store responsive.

### Q31: How does the "Add Product" form work?
**A:**
- **Fields**: Product name (255 char limit with live counter), location (auto-filled from profile), category (dropdown `UIMenu`), 5 image slots + 1 promotion image, price, duration (number + unit: Days/Weeks/Months), description, highlights
- **Duration caps**: Max 30 days, 4 weeks, or 1 month
- **Validation**: ALL fields required, at least 1 product image AND 1 promotion image required
- **Edit mode**: Same form pre-populates when `productToEdit` is passed
- **Back guard**: If form has unsaved data, confirmation alert prevents accidental loss

### Q32: How does soft-delete vs hard-delete work for products?
**A:**
- **Soft delete** (`deleteProduct`): Sets `isDeleted = true`. Product disappears from dashboard but is recoverable from "Deleted Ads" screen
- **Hard delete** (`permanentlyDeleteProduct`): Calls `context?.delete()` — permanently removes from SwiftData. Requires confirmation alert ("Cannot be undone")
- **Restore** (`restoreProduct`): Sets `isDeleted = false` — product reappears on dashboard

### Q33: How do Favorites work?
**A:** `LocalProduct` has an `isFavorite: Bool` property. Toggling the heart button on `ProductDetailViewController` flips this flag, saves context, and posts a `FavoritesChanged` notification via `NotificationCenter`. The `FavoritesViewController` observes this notification and refreshes its grid in real-time.

### Q34: What does the Admin Panel show?
**A:** Three segments:
1. **Users**: Lists all registered users with emails and passwords (for demo/debug)
2. **Products**: Lists all active products with name, price, and location
3. **Backup**: Shows backup timestamp, user/product counts, and provides "Backup Now" and "Restore All Data" buttons

---

## 🔷 PART 5: REQUEST/TRANSACTION LIFECYCLE

### Q35: Walk me through the complete borrow-to-return lifecycle.
**A:**
```
Borrower requests item → Status: "pending"
    ↓
Lender accepts → Status: "accepted" (notification sent to borrower)
    ↓
Borrower uses item for agreed duration
    ↓
  ┌── Borrower marks returned → Status: "returned"
  │     → Submits return photo + condition notes
  │     → Lender sees "View Details" + "Confirm Return"
  │     → Lender confirms → Status: "completed"
  │     → Review modal auto-appears for rating
  │
  └── Borrower reports delay → Status: "delayed"
        → Submits extended time, condition, product-in-use photo, payment slip
        → Lender is notified
```

### Q36: What edge cases did you handle in the request system?
**A:**
1. **Duplicate request prevention**: `hasExistingRequest(productId:borrowerEmail:)` checks if a pending request already exists — prevents spamming
2. **Self-request prevention**: User cannot borrow their own product
3. **Availability calculation**: When a product is accepted, the return date is calculated (`requestDate + duration days`) and displayed as "Available on: dd/MM/yyyy" with the borrow button disabled
4. **Review flag system**: `isReviewedByBorrower` / `isReviewedByLender` booleans prevent duplicate reviews — the "Rate" button disappears once reviewed
5. **Return evidence**: Borrower must submit a photo of the returned item + condition notes as proof

### Q37: Why did you use String for request status instead of an enum?
**A:** Practical decision for SwiftData compatibility. SwiftData's `@Model` macro works most reliably with primitive types. Using a `String` for status ("pending", "accepted", "cancelled", "returned", "delayed", "completed") avoids schema migration complexities that SwiftData enums can cause. The status values are consistent throughout the codebase.

### Q38: What happens when a lender declines a request?
**A:** Status updates to `"declined"`, a notification is sent to the borrower via `NotificationManager`, and the product remains available for other borrowers.

### Q39: How does the delay reporting work?
**A:** When a borrower can't return on time, they:
1. Tap "Report Delay"
2. Fill in: extended time needed, condition of the product, a photo of the product currently in use, and a payment slip image
3. All 4 pieces of evidence are stored (images via `@Attribute(.externalStorage)`)
4. Status changes to `"delayed"` and the lender is notified

---

## 🔷 PART 6: CHAT & MESSAGING

### Q40: How does the chat system work end-to-end?
**A:**
1. **Initiation**: User taps "Chat" on a product detail page or request card
2. **Thread lookup**: `fetchChat(productId:participant1:participant2:)` searches for an existing conversation. If none exists, `createChat()` creates one
3. **Messaging**: Text or photos are sent via `sendMessage()` which creates a `LocalMessage`, updates `LocalChat.lastMessage` and `lastUpdated`
4. **Inbox**: `ChatsViewController` shows all threads sorted by `lastUpdated` descending, with the other participant's name, avatar, and last message preview

### Q41: How does the read receipt system work?
**A:** Three states, implemented through two boolean flags (`isDelivered`, `isRead`):

| State | Visual | Trigger |
|:---|:---|:---|
| **Sent** | `✓` (single gray tick) | Default when message is created |
| **Delivered** | `✓✓` (double gray ticks) | When recipient opens their **Inbox** (`ChatsViewController.viewWillAppear`) |
| **Read** | `✓✓` (double orange ticks) | When recipient opens the **specific chat** (`ChatDetailViewController`) |

Ticks are only rendered on **outgoing** messages.

### Q42: How does photo sharing in chat work?
**A:**
1. User taps the photo icon → action sheet: "Take Photo" vs "Choose from Library"
2. **Permission checks**: `AVCaptureDevice.authorizationStatus` for camera, `PHPhotoLibrary.authorizationStatus` for library
3. If denied → alert with direct link to Settings (`UIApplication.openSettingsURLString`)
4. Selected image compressed to 70% JPEG quality
5. Saved as `LocalMessage.imageData`
6. Inbox preview shows `"📸 Photo"` as lastMessage
7. Chat bubble shows a 200x200pt image thumbnail
8. Tapping the photo opens `FullscreenImageViewController` (blurred modal with aspect-fit image)

### Q43: How do you handle the SwiftData predicate limitation for chat queries?
**A:** SwiftData's `#Predicate` often crashes with complex OR conditions on optional `UUID?` fields. Instead of a compound predicate, we:
1. Fetch all chats for `participant1` using a simple predicate
2. Filter in-memory using Swift's `.first { ... }` to match `participant2` and `productId`

This avoids the crash while maintaining correctness.

### Q44: How does date grouping work in chat?
**A:** Messages are partitioned into sections using `Calendar.current`:
- `isDateInToday` → Section header: **"Today"**
- `isDateInYesterday` → Section header: **"Yesterday"**
- Otherwise → Formatted as **"MMM d, yyyy"** (e.g., "Apr 1, 2026")

Headers render as sticky peach capsule labels with orange text.

### Q45: How do you handle keyboard management in chat?
**A:** Three mechanisms:
1. `keyboardWillShow` / `keyboardWillHide` notifications dynamically adjust the input bar's bottom constraint with 0.3s animation
2. Table view's `keyboardDismissMode = .interactive` allows drag-to-dismiss
3. Auto-scroll to bottom on new message via `scrollToRow(at: lastIndexPath)`

---

## 🔷 PART 7: REVIEWS & RATINGS

### Q46: How does the review system work?
**A:**
1. When a lender confirms a product return (status → "completed"), `ReviewInputViewController` auto-presents as a modal
2. User selects 1-5 stars (with haptic feedback and pop animation), writes optional title and body
3. Review saved to SwiftData with `reviewerEmail`, `revieweeEmail`, rating, and timestamp
4. `markRequestAsReviewed()` sets the appropriate flag so the "Rate" button disappears
5. Reviews are displayed on:
   - **User's public profile** (`UserProfileViewController`) — shows all received reviews
   - **My Reviews screen** — segmented into "Received" vs "Placed" tabs

### Q47: How do you calculate the star rating?
**A:** `reviews.isEmpty ? 0 : Double(reviews.reduce(0) { $0 + $1.rating }) / Double(reviews.count)` — simple average with zero-division protection. The star display supports full stars (`star.fill`), half stars (`star.leadinghalf.filled`), and empty stars (`star`).

### Q48: What prevents a user from reviewing the same transaction twice?
**A:** `isReviewedByBorrower` and `isReviewedByLender` boolean flags on `LocalRequest`. Once set to `true`, the "Rate" button is hidden from the request card. The review modal also calls `markRequestAsReviewed()` immediately after saving.

---

## 🔷 PART 8: NOTIFICATIONS

### Q49: How does your notification system work?
**A:** Fully **in-app** (system notifications disabled). Three components:
1. **`NotificationManager.postNotification()`**: Saves `LocalNotification` to SwiftData, posts `NotificationCenter` broadcast, and shows animated top banner (`InAppNotificationView`)
2. **`InAppNotificationView`**: Spring-animated banner (orange accent bar, white background) that slides down from top, holds 3 seconds, then slides up and removes itself
3. **`NotificationsViewController`**: History screen showing all notifications with swipe-to-delete and "Clear All" button

### Q50: Why in-app notifications instead of push notifications?
**A:** Since there's no backend server, there's no APNs (Apple Push Notification Service) infrastructure to deliver remote pushes. In-app notifications are the appropriate choice for a local-only prototype. The `NotificationManager` is architecturally ready — `requestAuthorization()` and `scheduleSystemNotification()` methods exist but are disabled, ready to activate when a backend is added.

### Q51: What triggers notifications?
**A:**
- New borrow request received → Lender notified
- Request accepted/declined → Borrower notified
- Item returned → Lender notified
- Delay reported → Lender notified
- Welcome back on login → User notified

### Q52: How did you prevent the infinite notification loop?
**A:** Early in development, `markAllAsRead()` was posting a `didReceiveNewNotification` broadcast, which re-triggered the observer in `NotificationsViewController`, causing infinite recursion. We fixed this by **removing the broadcast from the read-marking function** — broadcasts only fire when new notifications are actually created.

---

## 🔷 PART 9: BACKUP & DATA RECOVERY

### Q53: Why did you build a backup system?
**A:** SwiftData schema migrations can **wipe the entire database** if models change incompatibly. During development, we lost all test data multiple times. The backup system creates **independent JSON snapshots** stored in the app's `Documents` directory — completely outside SwiftData's SQLite container — so data survives database crashes and schema changes.

### Q54: How does the backup work technically?
**A:**
1. Every time `saveContext()` is called, it triggers `BackupManager.shared.scheduleBackup(delay: 2.0)`
2. A **2-second debounce** (`DispatchWorkItem.cancel()`) prevents disk thrashing during rapid saves
3. Users and products are mapped to lightweight `Codable` structs (images excluded to keep file size small)
4. JSON encoded with `.prettyPrinted` and `.iso8601` date strategy
5. Written **atomically** to `udhaarly_recovery_backup.json`

### Q55: How does restore work?
**A:**
1. Reads and decodes the JSON backup file
2. For each user: checks if `fetchUser(email:)` already exists — **skips if duplicate** (prevents duplicate insertion)
3. For each product: checks if `fetchProduct(id:)` already exists — **skips if duplicate**
4. Returns a tuple `(restoredUsers: Int, restoredProducts: Int)` showing what was recovered

### Q56: Why debounce the backup?
**A:** The app calls `saveContext()` frequently (on every message send, favorite toggle, request update, etc.). Without debouncing, each save would trigger a full JSON serialization and disk write. The 2-second debounce cancels previous pending writes and only executes the latest one — preventing **excessive disk I/O** and potential performance lag.

---

## 🔷 PART 10: USER PROFILE & SETTINGS

### Q57: What can users do in Settings?
**A:** Two sections:
- **General**: Requests, Favorites, Saved Addresses, Edit Profile, My Reviews, Deleted Ads, Pricing Plans
- **Security**: Privacy Policy, Terms & Conditions, Logout

The header shows profile picture, name, location, and a stats card with: star rating, published ads count, pending requests count, and total reviews.

### Q58: How does profile editing work?
**A:**
- Email is **non-editable** (protected as unique identifier)
- User can update: First Name, Last Name, Phone, Address, and Profile Picture
- `hasUnsavedChanges()` compares current values against stored values (including JPEG binary comparison for image)
- If user taps back with unsaved changes → confirmation alert: "Discard changes?"
- Validation: First name and last name must be non-empty

### Q59: How does logout work?
**A:** Confirmation alert → Clears `isUserLoggedIn` in UserDefaults → Swaps `window.rootViewController` to `HomeViewController` with `.transitionCrossDissolve` animation. The session email remains stored so if the user logs back in, their data is still there.

---

## 🔷 PART 11: UI/UX DESIGN DECISIONS

### Q60: How do you maintain a consistent brand identity?
**A:**
- **Brand orange** (`#FF6700`) used throughout for primary actions, buttons, and accents
- `GradientView` (orange-to-red gradient) used on all major headers
- `GradientCardView` (peach-to-white) for soft content containers
- Centralized `UIColor(hex:)` extension for consistent color usage
- `Extensions.swift` provides shared `addDropShadow()` and `applyThemeGradient()` utilities

### Q61: Why the floating center "plus" button on the tab bar?
**A:** It follows the **FAB (Floating Action Button)** pattern used by apps like Instagram and Uber. The center button is the **most important action** in the app — posting a new ad — so it deserves visual prominence. It's a 64x64 circle with orange background, white icon, and drop shadow, positioned dynamically in `viewDidLayoutSubviews()`.

### Q62: How do you handle empty states?
**A:** Every list/grid screen has a dedicated empty state:
- Favorites: "No favorites yet" centered label
- Category Products: "No products found in this category"
- Deleted Ads: "No deleted ads" label
- Notifications: Bell icon + "All caught up!" stack
- Reviews: `EmptyStateCell` with descriptive message
- Chat: Empty inbox state

### Q63: How does the interactive swipe-up on the Home screen work?
**A:** A `UIPanGestureRecognizer` tracks vertical drag on the bottom sheet. If the user drags upward past a **-100pt threshold**, a custom `CATransition` (push from top) navigates to `SignupViewController`. If the drag doesn't meet the threshold, the sheet **springs back** to its resting position using spring animation.

---

## 🔷 PART 12: EDGE CASES & DEFENSIVE PROGRAMMING

### Q64: What edge cases have you handled?

| Area | Edge Case | Solution |
|:---|:---|:---|
| **Auth** | UIKit font bug on password toggle | Clear and re-set text to force re-render |
| **Auth** | Partial registration (Keychain saved, profile incomplete) | Redirect to InfoDataViewController |
| **Auth** | Under-age user | DOB age check ≥16 years |
| **Products** | Orphaned products (publisher deleted) | `cleanupMissingPublisherProducts()` on app launch |
| **Products** | Accidental delete | Soft-delete with recovery; hard-delete requires confirmation |
| **Requests** | Duplicate borrow request | `hasExistingRequest()` check before saving |
| **Requests** | Borrowing own product | Prevented with email comparison check |
| **Chat** | SwiftData OR predicate crash | In-memory filtering workaround |
| **Chat** | Photo-only message in inbox | Shows "📸 Photo" as lastMessage preview |
| **Chat** | Camera/Library denied | Alert with Settings deep-link |
| **Notifications** | Infinite recursion loop | Removed broadcast from markAllAsRead |
| **Notifications** | Memory leak from observers | Remove observers in `viewWillDisappear` |
| **Backup** | Rapid save disk thrashing | 2-second debounce with DispatchWorkItem |
| **Backup** | Duplicate restoration | Check existing records before inserting |
| **Profile** | Unsaved changes on back | Dirty-state comparison + confirmation alert |
| **Reviews** | Division by zero (no reviews) | `isEmpty` guard before average calculation |
| **Reviews** | Double review submission | `isReviewedByBorrower` / `isReviewedByLender` flags |
| **Images** | Large binary in SQLite | `@Attribute(.externalStorage)` for all heavy data |
| **Data** | Legacy test data pollution | `cleanupDummyReviews()` scrubs hardcoded test emails on launch |
| **Layout** | Dashed border on address card | Recalculated in `viewDidLayoutSubviews()` |
| **Tab Bar** | Center button misplacement | Dynamically centered in `viewDidLayoutSubviews()` |

---

## 🔷 PART 13: LEGAL & COMPLIANCE

### Q65: What legal documents does the app include?
**A:** Two comprehensive legal documents rendered via `LegalDocumentViewController`:
1. **Privacy Policy** — Compliant with Pakistan's **PECA 2016** (Prevention of Electronic Crimes Act). Covers: data collected (name, contact, profile, transactions, location), usage policies, third-party sharing rules, security measures, and user privacy rights
2. **Terms & Conditions** — Platform rules: 18+ eligibility, prohibited items, lender/borrower liability, review guidelines, termination rights, Pakistani legal jurisdiction, and Apple App Store disclaimers

### Q66: How do you track user agreement to legal terms?
**A:** Each document has:
1. An interactive checkbox + agreement label
2. An "Accept & Continue" button (disabled until checkbox is checked)
3. Agreement state stored in `UserDefaults` with key `"hasAcceptedTerms_\(docType)"` — so it persists and the checkbox auto-checks on revisit

---

## 🔷 PART 14: SCALABILITY & FUTURE SCOPE

### Q67: How would you add a backend?
**A:** The `LocalDataManager` singleton acts as a **data access layer**. Every screen calls methods like `fetchProducts()`, `saveUser()`, `sendMessage()` — never touching SwiftData directly. To add a backend:
1. Replace `LocalDataManager` internals with API calls (REST/GraphQL/Firebase)
2. Add network response → local cache sync
3. Zero UI code changes needed

### Q68: How would you add real push notifications?
**A:** `NotificationManager` already has `requestAuthorization()` and `scheduleSystemNotification()` methods (currently disabled). Steps:
1. Register for APNs in `AppDelegate`
2. Set up Firebase Cloud Messaging or custom APNs server
3. Enable the existing methods in `NotificationManager`

### Q69: How would you add real OTP verification?
**A:** Replace the client-side simulation with:
1. Backend API to generate and send OTP via SMS (Twilio/Firebase Auth)
2. Server-side verification endpoint
3. Update `OTPViewController.didTapVerify()` to call the API instead of directly pushing forward

### Q70: What features would you add next?
**A:**
- **Real-time chat** with WebSockets or Firebase Realtime Database
- **Location-based discovery** with MapKit
- **Payment integration** (JazzCash/Easypaisa for Pakistan)
- **User verification** (CNIC verification, trust badges)
- **Push notifications** via APNs
- **Cloud image storage** (AWS S3 / Firebase Storage)

---

## 🔷 PART 15: RAPID-FIRE TECHNICAL QUESTIONS

### Q71: How many screens does the app have?
**A:** ~25+ screens across 6 modules (Authentication, Dashboard, Home/Settings, Chats, Requests, Admin).

### Q72: How many lines of Swift code?
**A:** ~8,000+ lines of production Swift code across 40+ files.

### Q73: What iOS version does this target?
**A:** iOS 17+ (required for SwiftData framework).

### Q74: What design pattern does the notification badge use?
**A:** **Observer pattern** via `NotificationCenter`. When pending request counts change, a `"RequestsUpdatedCount"` notification is posted, and the tab bar controller observes it to update the badge dynamically.

### Q75: How do you handle keyboard in forms?
**A:** `UIResponder.keyboardWillShowNotification` and `keyboardWillHideNotification` adjust `scrollView.contentInset` by the keyboard height + 20pt buffer. This ensures text fields are never hidden behind the keyboard.

### Q76: Why `textContentType = .oneTimeCode` on password fields?
**A:** It prevents iOS from showing the yellow autofill bar that appears when the system detects password fields. Since we handle authentication locally (not through iCloud Keychain), the autofill suggestion is misleading and visually intrusive.

### Q77: What happens if SwiftData initialization fails?
**A:** The `ModelContainer` initialization is wrapped in a `do-catch`. If it fails, the error is logged to console: `"Failed to initialize swiftdata: \(error)"`. The app continues running but database operations will silently fail (context is `nil`). The JSON backup system provides a safety net for data recovery.

### Q78: How do you ensure image quality vs storage balance?
**A:** Different compression levels for different use cases:
- **Profile pictures**: 50% JPEG quality (small, frequently loaded)
- **Chat photos**: 70% JPEG quality (moderate, sent frequently)
- **Product images**: 80% JPEG quality (higher quality for listings)
- **Heavy images**: `@Attribute(.externalStorage)` keeps them out of SQLite

---

> [!TIP]
> **Confidence is key.** When answering, start with the **"what"** (what you did), then explain the **"why"** (your reasoning), and finish with **"edge cases"** (what could go wrong and how you handled it). This three-part structure shows depth and ownership.
