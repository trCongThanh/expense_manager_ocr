<div align="center">
  <h1>💸 Quản Lý Chi Tiêu OCR Hóa Đơn</h1>
  <p><i>Ứng dụng quản lý tài chính cá nhân thông minh tích hợp công nghệ AI (Google ML Kit) để tự động đọc và trích xuất dữ liệu từ hóa đơn.</i></p>
  
  <p>
    <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" alt="Flutter"></a>
    <a href="https://dart.dev"><img src="https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"></a>
    <a href="https://firebase.google.com/docs/ml-kit"><img src="https://img.shields.io/badge/Google%20ML%20Kit-FFCA28?style=for-the-badge&logo=google&logoColor=black" alt="Google ML Kit"></a>
  </p>
</div>

---

## 🚀 Trải Nghiệm Ứng Dụng (Live Demo & Download)

Bạn có thể trải nghiệm ngay giao diện Dashboard siêu mượt (Dark Mode, Glassmorphism, Material 3) trực tiếp trên trình duyệt Web:

📱 **[Tải file cài đặt APK (Android) - v1.0.20](https://github.com/trCongThanh/expense_manager_ocr/releases/tag/v1.0.20)**

*(Lưu ý: Do hạn chế của trình duyệt, tính năng **Quét Camera OCR** không hoạt động trên nền Web. Vui lòng cài đặt file APK bên dưới để trải nghiệm toàn bộ tính năng)*

🌍 **[Live Demo (Netlify)](https://trcongthanh-expense-manager-ocr.netlify.app/)**  
🌐 **[Live Demo (GitHub Pages)](https://trcongthanh.github.io/expense_manager_ocr/)**

🎥 **[Video Demo (Google Drive)](https://drive.google.com/file/d/1fgdavtXxjGgYxtHgmyQbPLuYvB01vmhI/view)**

<div align="center">
  <img src="https://i.ibb.co/TMB3qkcz/image-demo-1.png" alt="image demo 1" border="0" width="30%">
  <img src="https://i.ibb.co/ymgwddrZ/image-demo-2-png.png" alt="image demo 2 png" border="0" width="30%">
  <img src="https://i.ibb.co/kLqJkLG/image-demo-3-png.png" alt="image demo 3 png" border="0" width="30%">
</div>
<br>
<div align="center">
  <img src="https://i.ibb.co/vvmwczJQ/image-demo-4-png.png" alt="image demo 4 png" border="0" width="30%">
  <img src="https://i.ibb.co/fYCqWR1B/image-demo-5-png.png" alt="image demo 5 png" border="0" width="30%">
  <img src="https://i.ibb.co/Z06k0N2/image-demo-6-png.png" alt="image demo 6 png" border="0" width="30%">
</div>
---

## ✨ Tính Năng Nổi Bật

### 🧠 1. OCR Thông Minh (Cốt Lõi)
- **Quét Hóa Đơn Tự Động:** Nhận diện và bóc tách dữ liệu từ hóa đơn vật lý bằng lõi AI của Google ML Kit cực nhanh.
- **Side-by-Side Review:** Giao diện vuốt (Sliding Up Panel) cho phép kiểm tra song song ảnh hóa đơn gốc và kết quả trích xuất.

### 💳 2. Quản Lý Tài Chính (Gây Nghiện)
- **Thống kê Trực Quan:** Biểu đồ đường (Line Chart) theo dõi dòng tiền mượt mà.
- **Chế Độ Riêng Tư (Privacy Mode):** Làm mờ toàn bộ số tiền chỉ với một nút bấm (hiệu ứng kính mờ Blur) giúp bảo vệ thông tin khi dùng app ở nơi công cộng.
- **Dark Mode & Material 3:** Giao diện tối sang trọng, tôn lên các con số tài chính với điểm nhấn xanh Neon (Thu) và Đỏ Coral (Chi).

---

## 📦 Kiến Trúc & Công Nghệ Sử Dụng

Ứng dụng được xây dựng trên nền tảng kiến trúc **Feature-First** tiên tiến, sử dụng các thư viện hàng đầu:

| Nhóm Công Nghệ | Thư Viện Sử Dụng | Vai Trò |
| :--- | :--- | :--- |
| **Quét & AI** | `google_mlkit_text_recognition`, `image_picker` | Trích xuất ký tự (OCR) từ Camera / Thư viện. |
| **Giao Diện (UI)** | `fl_chart`, `lucide_icons_flutter` | Vẽ biểu đồ tài chính và cung cấp bộ icon Minimalist. |
| **UX & Chuyển Động**| `flutter_animate`, `skeletonizer`, `sliding_up_panel` | Tạo hiệu ứng bóng ma loading, slide mượt mà, fade-in. |
| **Kiến Trúc & State**| `flutter_riverpod`, `hive` | Quản lý luồng dữ liệu (State) và cơ sở dữ liệu NoSQL cục bộ. |

---

## 🛠 Hướng Dẫn Chạy Cục Bộ (Local Development)

Nếu bạn muốn clone dự án này về máy và phát triển tiếp:

1. **Clone repository:**
   ```bash
   git clone https://github.com/trCongThanh/expense_manager_ocr.git
   cd expense_manager_ocr
   ```

2. **Cài đặt các thư viện phụ thuộc:**
   ```bash
   flutter pub get
   ```

3. **Chạy ứng dụng (trên máy ảo Android/iOS để test OCR):**
   ```bash
   flutter run
   ```

<div align="center">
  <p>Được thiết kế và phát triển bởi <b>trCongThanh</b> ❤️</p>
</div>
