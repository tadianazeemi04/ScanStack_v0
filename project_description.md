# ScanStack - Project Description

**ScanStack** is an intelligent, AI-powered iOS application designed to automatically scan, categorize, and extract text from images in a user's photo albums.

## Core Modules & Functionality

### 1. Home Screen & Navigation
- **Custom Tab Bar:** A floating bottom navigation bar that allows users to switch between 4 main screens: Home, Activity, Search, and Stacks.
- **Top Bar:** Displays the "ScanStack" logo on the left and the user's Firebase (Google) profile picture on the right. Tapping the profile picture opens a dropdown menu with "Settings" and "Logout" options.
- **Dynamic Greeting:** Greets new users with "Hello {FirstName}" and returning users with "Welcome back {FirstName}".
- **Active Stacks Dashboard:**
  - Displays a "No Stacks" empty state if the user hasn't scanned anything, providing a call-to-action button to navigate to the Activity screen.
  - If stacks exist, displays a visually appealing grid (e.g., Shopping, Emails, Food, Documents) showing the most recent scanned stacks at the top left, along with the image count for each stack.
- **Ad Integrations:** Reserved placeholder space at the bottom for future Google AdMob banners.

### 2. Scanning Module (The AI Engine)
- **Input Methods:** When the user taps "Scan Now", they are presented with 3 options:
  1. **Camera:** Take a real-time picture.
  2. **Photos:** Select a single existing photo.
  3. **Album:** Select an entire photo album to process in bulk.
  *(Note: The scanning module processes **images only**. If an album contains videos, they are automatically skipped).*
- **Classification:** The app runs a custom CoreML model (`ScanStackClassifier_1.mlmodel`) on every selected image to determine its category. The model specifically categorizes images into one of 9 classes:
  - Chats
  - Document
  - Emails
  - Finance Receipts
  - Food
  - Maps
  - Other
  - Shopping
  - Social
- **OCR Extraction:** Simultaneously, the app uses the native iOS Vision framework to perform Optical Character Recognition (OCR), extracting all readable text from the images.
- **Summary:** Once the scan is complete, the module provides a summary report to the user, detailing how many images were found for each specific category.

### 2. Stacks Module (Organization)
- "Stacks" act as internal folders or albums within the app.
- Based on the categories determined by the CoreML model during the scanning phase, images are automatically routed and displayed in their respective Stacks.

### 3. Image Preview Module
When a user taps on an image within a Stack or Search result, they are presented with a detailed Image Preview screen. This screen displays:
- **Image Name**
- **Date/Day Created**
- **Image Original Path**
- **Image Size (in KB)**
- **Collection / Stack Name** (The category it belongs to)
- **Extracted Text** (The raw text pulled from the image via OCR)

### 4. Search Module
- A robust search interface that allows the user to type in keywords.
- The app searches through both the **Extracted Text** (OCR data) and the **Stack Names**.
- It returns and displays the images that match the search queries.

### 5. Authentication & Security (Completed)
- A highly secure, visually stunning Glassmorphism UI for user onboarding.
- Features include: Email/Password Registration, Password Strength Evaluation, Email Verification locking, Login, and Google Sign-In integration using Firebase Authentication and Firestore.

### 6. Settings Module
- *Details pending further specification.*
