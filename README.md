# 🏠 Ứng dụng Quản lý Phòng trọ (Boarding House Management App)

Ứng dụng di động được xây dựng bằng Flutter và Firebase, hỗ trợ các chủ trọ quản lý vận hành phòng trọ một cách hiện đại, tối ưu hóa việc lưu trữ và truy xuất dữ liệu khách thuê trên nền tảng đám mây.

## 🌟 Tính năng nổi bật
- **Xác thực người dùng**: Hệ thống đăng nhập và phân quyền bảo mật thông qua Firebase Authentication.
- **Quản lý dữ liệu thời gian thực**: Sử dụng Cloud Firestore để đồng bộ hóa danh sách phòng, dịch vụ và thông tin khách hàng ngay lập tức.
- **Hệ thống ổn định**: Tích hợp Firebase Core giúp ứng dụng kết nối mượt mà và tin cậy với các dịch vụ backend.
- **Giao diện hiện đại**: Sử dụng Material Design và các icon tinh tế từ Cupertino Icons.

## 🛠 Tech Stack
- **Ngôn ngữ**: Dart.
- **Framework**: Flutter (v3.10.7+).
- **Backend**: Firebase (Firestore, Auth, Core).
- **Công cụ phát triển**: Android Studio / VS Code.

## 📂 Cấu trúc thư mục
```plaintext
app_quanly_phong/
├── lib/ 
│   ├── main.dart         # Điểm khởi đầu của ứng dụng
│   ├── models/           # Định nghĩa các đối tượng dữ liệu
│   ├── screens/          # Giao diện các màn hình chức năng
│   ├── services/         # Xử lý logic Firebase (Auth, Firestore)
│   └── widgets/          # Các thành phần giao diện dùng chung
├── android/              # Cấu hình cho nền tảng Android
├── ios/                  # Cấu hình cho nền tảng iOS
└── pubspec.yaml          # Quản lý thư viện và phân phiên bản
```

---

## 🚀 Hướng dẫn cài đặt và khởi chạy dự án

Tài liệu này hướng dẫn cách cấu hình và chạy mã nguồn dự án Flutter này trên một máy tính mới.

### 1. Yêu cầu hệ thống (Prerequisites)
Để chạy được dự án, máy tính của bạn cần cài đặt sẵn các phần mềm sau:
- **[Flutter SDK](https://docs.flutter.dev/get-started/install)** (Đảm bảo đã thêm đường dẫn `flutter\bin` vào biến môi trường `Path`).
- Trình soạn thảo mã: **[Visual Studio Code](https://code.visualstudio.com/)** hoặc **[Android Studio](https://developer.android.com/studio)** (nên cài thêm các extension/plugin cho Flutter và Dart).
- Để chạy ứng dụng như một phần mềm Windows Desktop, máy tính phải được bật **Developer Mode**.

### 2. Các bước khởi chạy dự án

**Bước 1: Clone repository**
```bash
git clone https://github.com/NQPDong/AppQuanLyPhongTro.git
```

**Bước 2: Cập nhật thư viện (Dependencies)**
Mở thư mục `quan_ly_phong_tro` bằng VS Code hoặc Android Studio. Mở Terminal tại thư mục gốc và chạy các lệnh sau:
```bash
flutter clean
flutter pub get
```
*Lưu ý: Nếu bị lỗi "Building with plugins requires symlink support. Please enable Developer Mode...", bạn hãy chạy lệnh `start ms-settings:developers` trên cmd và BẬT DEVELOPER MODE lên.*

**Bước 3: Cấu hình Firebase**
- Tải file `google-services.json` từ Firebase Console và đặt vào thư mục `android/app/`.
- Tải file `GoogleService-Info.plist` và đặt vào thư mục `ios/Runner/`.

**Bước 4: Chạy ứng dụng**
Để chạy ứng dụng, bạn có thể nhấn `F5` trên VS Code hoặc gõ lệnh sau vào Terminal:
```bash
flutter run
```
*Hệ thống sẽ liệt kê các thiết bị khả dụng (Chrome, Windows, Android Emulator...). Nhấn phím số tương ứng với thiết bị bạn muốn chạy.*

---

## 🛠 Khắc phục các lỗi thường gặp (Troubleshooting)

### 1. Lỗi Developer Mode trên Windows
Khi build ứng dụng cho Windows, bạn có thể gặp thông báo:
> *Please enable Developer Mode in your system settings. Run start ms-settings:developers to open settings.*

**Cách sửa lỗi:**
1. Mở **Command Prompt (CMD)** hoặc hộp thoại **Run** (`Win + R`), chạy lệnh:
   ```cmd
   start ms-settings:developers
   ```
2. Tại cửa sổ Settings vừa mở, bật công tắc **Developer Mode** (Chế độ nhà phát triển) sang trạng thái **On**.
3. Quay lại Terminal và chạy lại `flutter run`.

### 2. Lỗi liên quan đến Firebase & Môi trường
Dự án này sử dụng Firebase. Thông thường cấu hình đã nằm sẵn trong `lib/firebase_options.dart`. Nếu bạn cần kết nối sang một project Firebase khác hoặc môi trường bị thiếu, thực hiện các bước sau:

**1. Đăng nhập Firebase CLI:**
```bash
npm install -g firebase-tools
firebase login
```

**2. Cài đặt và khắc phục lỗi không nhận diện FlutterFire:**
Nếu bạn gặp lỗi không chạy được lệnh `flutterfire configure`, nguyên nhân là do thiếu biến môi trường.
- Cài đặt công cụ: `dart pub global activate flutterfire_cli`
- **Sửa lỗi Path:** Mở cài đặt **Environment Variables** của Windows, thêm đường dẫn sau vào biến `Path` của tài khoản:
  `C:\Users\<Tên_User_Của_Bạn>\AppData\Local\Pub\Cache\bin`
  *(Ví dụ của máy cũ là: `C:\Users\Admin\AppData\Local\Pub\Cache\bin`)*

**3. Kết nối lại Firebase:**
Mở lại Terminal mới cho nhận biến môi trường và chạy:
```bash
flutterfire configure
```
*(Lưu ý: Để cài đặt thư viện core của Firebase trong Flutter nếu chưa có, dùng lệnh: `flutter pub add firebase_core`)*
