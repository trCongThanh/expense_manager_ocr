# Quản Lý Chi Tiêu OCR Hóa Đơn

🚀 **[Trải nghiệm bản Web trực tiếp tại đây (Live Demo)](https://trCongThanh.github.io/expense_manager_ocr/)**
*(Lưu ý: Tính năng Camera OCR chỉ hoạt động trên thiết bị di động thật)*

📦 **[Tải file APK Android (Bản cài đặt)](https://github.com/trCongThanh/expense_manager_ocr/releases/latest)**

Dự án Flutter quản lý chi tiêu kết hợp công nghệ OCR (nhận diện ký tự quang học) để trích xuất thông tin tự động từ hình ảnh hóa đơn.

## Các Thư Viện Đã Tích Hợp

### 1. OCR & Quét ảnh
* **[google_mlkit_text_recognition](https://pub.dev/packages/google_mlkit_text_recognition):** Nhận diện và trích xuất văn bản từ hình ảnh hóa đơn.
* **[image_picker](https://pub.dev/packages/image_picker):** Chụp ảnh từ camera hoặc chọn ảnh từ thư viện.
* **[image_cropper](https://pub.dev/packages/image_cropper):** Cắt ảnh hóa đơn để loại bỏ các chi tiết thừa, giúp tăng độ chính xác của OCR.

### 2. Giao diện & Biểu đồ
* **[fl_chart](https://pub.dev/packages/fl_chart):** Vẽ biểu đồ trực quan (biểu đồ tròn, biểu đồ cột) để hiển thị thống kê thu chi.
* **[lucide_icons](https://pub.dev/packages/lucide_icons):** Bộ icon hiện đại, đẹp mắt cho các danh mục chi tiêu.

### 3. Hiệu ứng chuyển động
* **[lottie](https://pub.dev/packages/lottie):** Hiển thị các hiệu ứng animation phức tạp (ví dụ: hiệu ứng quét sóng OCR đang xử lý).
* **[animations](https://pub.dev/packages/animations):** Các hiệu ứng chuyển trang mượt mà (như SharedAxisTransition, FadeThroughTransition).

### 4. Tính toán & Định dạng
* **[intl](https://pub.dev/packages/intl):** Định dạng tiền tệ (VND) và ngày tháng (dd/MM/yyyy).

### 5. Lưu trữ & State
* **[hive](https://pub.dev/packages/hive) & [hive_flutter](https://pub.dev/packages/hive_flutter):** Cơ sở dữ liệu NoSQL cục bộ, siêu nhanh, dùng để lưu trữ các giao dịch chi tiêu offline.
* **[flutter_riverpod](https://pub.dev/packages/flutter_riverpod):** Quản lý state (trạng thái) của ứng dụng một cách an toàn và dễ dàng bảo trì.

### 6. Trải nghiệm người dùng (UI/UX)
* **[shimmer](https://pub.dev/packages/shimmer):** Tạo hiệu ứng lấp lánh (bóng ma) khi chờ dữ liệu hoặc đang chờ ML Kit phân tích.
* **[skeletonizer](https://pub.dev/packages/skeletonizer):** Giải pháp tự động bọc UI thật thành giao diện skeleton loading tuyệt đẹp.
* **[sliding_up_panel](https://pub.dev/packages/sliding_up_panel):** Bảng vuốt từ dưới lên (Bottom Sheet) hoàn hảo cho việc hiển thị ảnh hóa đơn ở trên và dữ liệu nhận diện ở dưới.

### 7. Bảo mật & Tiện ích
* **[local_auth](https://pub.dev/packages/local_auth):** Khóa/mở khóa ứng dụng bằng sinh trắc học (vân tay, khuôn mặt) như các ứng dụng ngân hàng.
* **[uuid](https://pub.dev/packages/uuid):** Tạo ID định danh duy nhất cho từng giao dịch hoặc hóa đơn.

## Các Bước Tiếp Theo
1. **Khởi tạo Code Generation (nếu dùng Hive Adapter):**
   ```bash
   flutter pub run build_runner build
   ```
2. **Cài đặt CocoaPods (nếu build iOS):**
   ```bash
   cd ios && pod install
   ```
3. **Chạy ứng dụng:**
   ```bash
   flutter run
   ```
