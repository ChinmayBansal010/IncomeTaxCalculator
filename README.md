# 💼 Income Tax Calculator & Employee Management System

A full-featured **Income Tax Calculator and Employee Data Management Tool** built using **Flutter**, **Firebase**, and **Android Studio**. Designed primarily for **web use** and adopted by the **MCD Dispensary, Delhi**, it provides seamless handling of income tax computation, arrears, DA, deductions, and monthly records — all exportable in **clean Excel format**.

---

## 🛠️ Tech Stack

- **Flutter** (UI)
- **Firebase** (Realtime DB + Storage)
- **Syncfusion XlsIO** (Excel Export)
- **Android Studio**

---

## 🌐 Platform Compatibility

- ✅ **Web App** (Primary usage)
- 📱 **Android APK** (Optional)

---

## ✨ Features

- 🔢 Accurate income tax calculations
- 👥 Complete employee management (PAN, salary, etc.)
- 📊 Export data to Excel (clean structured format)
- 📅 Monthly salary view and tracking
- 🧾 Arrear, DA, TDS, and deduction handling
- 🔍 Advanced search and filters
- 🔐 Secure and realtime updates via Firebase

---

## 📁 Folder Structure Overview

```
lib/
├── arrear/                  # Arrear-related screens or logic
├── deduction/              # Deduction-related screens or logic
├── main/                   # Main application structure/screens
├── monthpages/             # Monthly breakdown views and pages

# Dart Files
├── arrear_data.dart        # Handles arrear data logic
├── calc.dart               # Core tax calculation functions
├── da.dart                 # DA calculation logic
├── deduction_data.dart     # Deduction data handling
├── exportall.dart          # Excel export functions
├── home.dart               # App landing/home page
├── itax.dart               # Income tax specific logic
├── main.dart               # App entry point
├── main_data.dart          # Core data model or structure
├── month_data.dart         # Monthly salary and data models
├── shared.dart             # Shared data or state logic
├── tax.dart                # Tax breakdown logic
├── tds.dart                # TDS computation logic
├── test.dart               # Test functions or UI
```

---

## 📦 How to Run

1. Clone this repo.
2. Make sure Flutter is installed and set up.
3. Run:
   ```bash
   flutter pub get
   flutter run -d chrome   # for web
   flutter build apk       # for Android
   ```
4. Ensure Firebase project is linked with correct credentials and database.

---

## 👤 Intended For

- **Dispensary HR/Admin staff**
- Any government/organization-based employee tax management
- Accountants managing salary structure for multiple individuals

---

## 🏢 Real-World Usage

✅ **Currently in Active Use:**  
This application is deployed and being used to manage salary and tax data for **over 400 employees** at the **MCD Dispensary, Delhi**.  
It streamlines the entire finance process and generates audit-ready reports in Excel format.

---

## 📩 Contact

**Developer**: Chinmay Bansal  
📧 Email: chinmay8521@example.com  

---

## 📝 License

This project is intended for internal and organizational use. For custom deployments or licensing, please contact the developer.
