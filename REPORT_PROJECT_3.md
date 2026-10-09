# MINI-PROJECT SHORT TECHNICAL REPORT

**Course:** Cross-Platform Mobile App Development (VKU)  
**Mini-Project Title:** Mini-Project 3 - Expense Manager OCR (Flutter & Google ML Kit)  
**Team / Student Name:** Trương Công Thành  
**Submission Date:** 10/10/2026  

---

## 1. GENERAL INFORMATION & DELIVERABLE LINKS
* **Team Members:**
  1. Trương Công Thành – Student ID: [23IT251] – Role: Mobile App Developer / System Architect – Contribution: 100%
* **🔗 Live Demo URL:** [https://trcongthanh-expense-manager-ocr.netlify.app/](https://trcongthanh-expense-manager-ocr.netlify.app/)
* **📂 GitHub Repository:** [https://github.com/trCongThanh/expense_manager_ocr](https://github.com/trCongThanh/expense_manager_ocr)

---

## 2. FEATURE IMPLEMENTATION CHECKLIST

| # | Required Feature | Status | Implementation Details & Acceptance Level |
|:---:|---|:---:|---|
| 1 | Cross-Platform & UI Responsiveness | 🟢 Complete | Giao diện Material 3 đáp ứng tốt trên cả Android và Web. Tích hợp thanh điều hướng Bottom Navigation Bar. Xử lý khéo léo lỗi Camera trên môi trường Web bằng ImageFallback. |
| 2 | Offline Text Recognition (OCR) | 🟢 Complete | Tích hợp thành công thư viện `google_mlkit_text_recognition` của Google để nhận diện toàn bộ văn bản trên hóa đơn ngay trên thiết bị mà không cần Internet (Offline). |
| 3 | Heuristic Parsing Logic (Trích xuất) | 🟢 Complete | Thay thế AI đám mây bằng thuật toán lọc dữ liệu tại local. Tự động nhận diện Tên Cửa Hàng dựa trên từ khóa cứng (coffee, shopee, circle k...) và trích xuất Tổng Tiền bằng cách dùng RegExp thu thập toàn bộ số liệu, sau đó lấy ra con số lớn nhất (Max Price). |
| 4 | Persistence & State Management | 🟢 Complete | Ứng dụng `Hive` Database để lưu trữ vĩnh viễn (Persistence) trên ổ cứng thiết bị. Dùng `Riverpod` quản lý State Global giúp tự động tính toán lại Tổng Số Dư, Thu nhập và Chi tiêu mỗi khi có Hóa đơn mới được lưu. |
| 5 | Dynamic Theming & Typography | 🟢 Complete | Giao diện hỗ trợ Dark Mode/Light Mode và khả năng điều chỉnh kích thước chữ (Text Scale) toàn cục. Tùy chỉnh được lưu ngay lập tức vào Hive. |

---

## 3. TECHNICAL ARCHITECTURE & PROJECT STRUCTURE

* **Tech Stack:** Flutter, Riverpod (State Management), Hive (Local DB), Google ML Kit (OCR), fl_chart (Data Viz), SlidingUpPanel.
* **Directory Structure:**
  * `lib/main.dart`: Entry point của ứng dụng. Khởi tạo `Hive` DB (mở box `app_data`) và bọc toàn bộ App bằng `ProviderScope` của Riverpod.
  * `lib/features/dashboard/main_screen.dart`: Chứa các Global Providers (`lightModeProvider`, `textSizeProvider`, `transactionsProvider`). Các Provider này kết nối trực tiếp với Hive để lấy và lưu dữ liệu. Quản lý việc chuyển đổi giữa các Tab (Dashboard, Analytics, Wallet, Settings).
  * `lib/features/dashboard/dashboard_screen.dart`: Màn hình Trang chủ. Thuật toán `_buildHeader` lắng nghe `transactionsProvider` để linh hoạt cộng dồn Thu Nhập, trừ đi Chi Tiêu và hiển thị Tổng Số Dư (Dynamic Balance) thời gian thực.
  * `lib/features/ocr/ocr_scanner_screen.dart`: Màn hình cốt lõi. Chịu trách nhiệm chụp ảnh/chọn ảnh, đưa qua ML Kit để trích xuất mảng String, chạy Regex bóc tách Dữ liệu (Store & Price). Lưu giao dịch vào State và Hive DB khi bấm "Lưu Hóa Đơn".
* **Cross-platform Handling:** Sử dụng `kIsWeb` để vô hiệu hóa Camera và ML Kit khi người dùng truy cập từ trình duyệt Web (do ML Kit hiện tại chỉ support Native iOS/Android).

---

## 4. EMPIRICAL EVIDENCE & SCREENSHOTS

*(Hình ảnh minh họa chức năng Quét OCR và Đồng bộ Dữ liệu)*

* **Screenshot 1: Dynamic Dashboard**
  - Hiển thị Tổng số dư thay đổi động theo từng giao dịch thu/chi được lưu trữ trong Hive DB.
  
* **Screenshot 2: Interactive Analytics & Theming**
  - Giao diện Biểu đồ (`fl_chart`) và Chế độ ban đêm (Dark Mode) kết hợp Typography do người dùng tùy chỉnh.

* **Screenshot 3: ML Kit Offline Scanner & Heuristics**
  - Nhận diện thành công văn bản trong ảnh, tìm ra tên cửa hàng và lọc ra giá trị số tiền hóa đơn lớn nhất hoàn toàn Offline không cần WiFi.

*(Ghi chú: Thay thế bằng hình thực tế nếu có)*

---

## 5. TECHNICAL CHALLENGES & RESOLUTIONS

* **Challenge 1: Lỗi Build Gradle do thư viện cũ (`flutter_tesseract_ocr`).** 
  * *Mô tả:* Ban đầu dự định dùng Tesseract cho tính năng quét chữ. Tuy nhiên, thư viện này quá cũ, phụ thuộc vào kho `jcenter()` đã chết và cấu hình Kotlin Android lỗi thời, dẫn đến việc hỏng hoàn toàn quá trình Build APK trên Gradle 8.0+.
  * *Resolution:* Chấp nhận đập bỏ Tesseract. Xóa toàn bộ dependency cũ và chuyển hướng sang sử dụng `google_mlkit_text_recognition`. Thư viện này được Google bảo trì chính thức, tốc độ nhận diện nhanh hơn và không yêu cầu setup model ngôn ngữ phức tạp.

* **Challenge 2: Obfuscation (R8 Shrinker) xóa nhầm Class của Google ML Kit trên bản Release.**
  * *Mô tả:* Khi chạy App ở chế độ Debug, ML Kit quét ảnh rất mượt. Nhưng khi chạy lệnh `flutter build apk --release`, App bị văng (Crash) với lỗi `NullPointerException` tại `java.lang.Class`.
  * *Resolution:* Phát hiện ra nguyên nhân là do công cụ nén code (R8) của Android đã xóa nhầm các class nội bộ của Google ML Kit vì tưởng không dùng đến. Khắc phục bằng cách tạo file `android/app/proguard-rules.pro` và thêm chỉ thị khai báo `-keep class com.google.mlkit.** { *; }` và `-keep class com.google.android.gms.** { *; }` để ép trình biên dịch giữ lại ML Kit.

* **Challenge 3: Viết thuật toán (Heuristic Parsing) trích xuất hóa đơn Offline thay cho AI.**
  * *Mô tả:* Rủi ro từ việc API Key của Gemini AI liên tục bị lộ (GitHub Secret Scanning) và hết hạn Token. Cần một giải pháp trích xuất dữ liệu "Cửa Hàng" và "Tổng Tiền" mà không dùng tới AI đám mây, chạy 100% dưới máy.
  * *Resolution:* Tự xây dựng thuật toán phân tích chuỗi văn bản (Deterministic Algorithm). Dùng danh sách từ khóa cứng mảng (`'store', 'coffee', 'circle k', 'winmart'`) để phát hiện Tên cửa hàng. Dùng Regular Expression (`\b\d{1,3}(?:[.,]\d{3})+\b|\b\d{4,}\b`) để cào toàn bộ các cụm số giống định dạng Tiền tệ, loại bỏ dấu thập phân, chuyển về kiểu `int` và chạy thuật toán so sánh để tìm ra con số có giá trị Max - ngầm định đây là Tổng Bill. Logic chạy siêu tốc và độ chính xác ở mức chấp nhận được cho Prototype.
