# Hướng Dẫn Cài Đặt Và Chạy Dự Án Quản Lý Phòng Trọ

Tài liệu này hướng dẫn cách cấu hình và chạy mã nguồn dự án Flutter này trên một máy tính mới.

## 1. Yêu cầu hệ thống (Prerequisites)

Để chạy được dự án, máy tính của bạn cần cài đặt sẵn các phần mềm sau:
- **[Flutter SDK](https://docs.flutter.dev/get-started/install)** (Đảm bảo đã thêm đường dẫn `flutter\bin` vào biến môi trường `Path`).
- Trình soạn thảo mã: **[Visual Studio Code](https://code.visualstudio.com/)** hoặc **[Android Studio](https://developer.android.com/studio)** (nên cài thêm các extension/plugin cho Flutter và Dart).
- Để chạy ứng dụng như một phần mềm Windows Desktop, máy tính phải được bật **Developer Mode**.

---

## 2. Các bước khởi chạy dự án

**Bước 1: Mở dự án**
Mở thư mục `quan_ly_phong_tro` bằng trình soạn thảo mã (VS Code hoặc Android Studio).

**Bước 2: Cập nhật thư viện (Dependencies)**
Mở Terminal tại thư mục gốc của dự án (trong VS Code nhấn `` Ctrl + ` ``) và chạy lần lượt các lệnh sau:
```bash
flutter clean
flutter pub get

* nếu lỗi "Building with plugins requires symlink support.
Please enable Developer Mode in your system settings. Run
  start ms-settings:developers
to open settings."
 Thì chạy lệnh start ms-settings:developers trên cmd  VÀ BẬT DEVELOPER MODE LÊN
```

**Bước 3: Chạy ứng dụng**
Để chạy ứng dụng, bạn có thể nhấn `F5` trên VS Code hoặc gõ lệnh sau vào Terminal:
```bash
flutter run
```
*Hệ thống sẽ liệt kê các thiết bị khả dụng (Chrome, Windows, Android Emulator...). Nhấn phím số tương ứng với thiết bị bạn muốn chạy.*

---

## 3. Khắc phục các lỗi thường gặp (Troubleshooting)

Dưới đây là một số lỗi bạn có thể gặp trong quá trình cài đặt môi trường mới và cách khắc phục:

### 3.1. Lỗi Developer Mode trên Windows
Khi build ứng dụng cho Windows, bạn có thể gặp thông báo:
> *Please enable Developer Mode in your system settings. Run start ms-settings:developers to open settings.*

**Cách sửa lỗi:**
1. Mở **Command Prompt (CMD)** hoặc hộp thoại **Run** (`Win + R`), chạy lệnh:
   ```cmd
   start ms-settings:developers
   ```
2. Tại cửa sổ Settings vừa mở, bật công tắc **Developer Mode** (Chế độ nhà phát triển) sang trạng thái **On**.
3. Quay lại Terminal và chạy lại `flutter run`.

### 3.2. Lỗi liên quan đến Firebase & Môi trường
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
