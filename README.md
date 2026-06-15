# 🏠 Ứng Dụng Quản Lý Phòng Trọ (Boarding House Management App)
Ứng dụng di động quản lý vận hành phòng trọ được xây dựng bằng **Flutter**, kết nối với cơ sở dữ liệu **Microsoft SQL Server** thông qua **ASP.NET Core Web API (C#)**. Dự án hỗ trợ các chủ trọ dễ dàng quản lý thông tin phòng trọ, hợp đồng thuê, khách thuê, hóa đơn và theo dõi doanh thu theo thời gian thực.

---

## 🛠 Công Nghệ Sử Dụng (Tech Stack)

- **Frontend:** Flutter SDK (Dart)
- **Backend API:** ASP.NET Core Web API (.NET 8.0)
- **Database:** Microsoft SQL Server
- **IDE hỗ trợ:** VS Code, Visual Studio hoặc Android Studio

---

## 📂 Cấu Trúc Dự Án

```plaintext
AppQLPhongTro/
├── backend/                       # Source code ASP.NET Core C# API
│   ├── Controllers/               # Bộ xử lý các API endpoint
│   ├── AppDbContext.cs            # Kết nối EF Core với SQL Server
│   ├── Models.cs                  # Định nghĩa các Model dữ liệu
│   ├── Program.cs                 # Cấu hình khởi chạy API & Kestrel Port 5276
│   ├── appsettings.json           # Cấu hình Connection String tới SQL Server
│   └── database.sql               # Script khởi tạo Database và dữ liệu mẫu
│
└── quan_ly_phong_tro/             # Source code Flutter Client
    ├── assets/                    # Hình ảnh, font chữ dùng trong app
    ├── lib/
    │   ├── models/                # Lớp ánh xạ dữ liệu từ API
    │   ├── providers/             # Quản lý trạng thái (State Management)
    │   ├── screens/               # Giao diện màn hình ứng dụng
    │   └── services/              # Xử lý các yêu cầu HTTP gọi lên API backend
    ├── pubspec.yaml               # Cấu hình thư viện phụ thuộc
    └── .gitignore                 # Bỏ qua các file build và các cấu hình riêng tư
```

---

## 🚀 Hướng Dẫn Cài Đặt Và Khởi Chạy Dự Án

### Bước 1: Thiết lập Cơ sở dữ liệu (Microsoft SQL Server)

1. Mở **SQL Server Management Studio (SSMS)** và kết nối với Server của bạn.
2. Mở và chạy toàn bộ nội dung file SQL script nằm ở địa chỉ `backend/database.sql` để:
   - Tạo cơ sở dữ liệu `QuanLyPhongTro`.
   - Tạo các bảng: `Users`, `Properties`, `Rooms`, `Tenants`, `Contracts`, `Invoices`.
   - Chèn các bản ghi dữ liệu mẫu (1 chủ trọ mặc định `admin@gmail.com` mật khẩu `123456`, 10 khách thuê mẫu, 1 cơ sở trọ mẫu, và 10 phòng trọ mẫu).

---

### Bước 2: Cấu hình và Chạy Backend API (ASP.NET Core)

1. Đi đến thư mục chứa backend:
   ```bash
   cd backend
   ```
2. Mở file `appsettings.json` và cấu hình lại đường dẫn **ConnectionStrings** khớp với SQL Server của máy bạn:
   ```json
   "ConnectionStrings": {
     "DefaultConnection": "Server=<TÊN_SQL_SERVER_CỦA_BẠN>;Database=QuanLyPhongTro;Trusted_Connection=True;TrustServerCertificate=True;"
   }
   ```
   *(Ví dụ: `Server=Dong05;Database=QuanLyPhongTro;...`)*
3. Chạy API Server thông qua dòng lệnh dotnet:
   ```bash
   dotnet run
   ```
   *Mặc định, Kestrel server được cấu hình lắng nghe trên cổng **5276** (`http://localhost:5276` hoặc `http://10.0.2.2:5276` trên Android).*

---

### Bước 3: Cấu hình và Chạy ứng dụng Flutter

1. Đi đến thư mục dự án Flutter:
   ```bash
   cd quan_ly_phong_tro
   ```
2. Cài đặt các thư viện phụ thuộc:
   ```bash
   flutter pub get
   ```
3. Cấu hình địa chỉ IP máy chủ API:
   - Mở file `lib/services/api_config.dart`.
   - Hàm `baseUrl` đã được cấu hình tự động nhận diện thiết bị chạy:
     - Trên **Android Emulator**: Kết nối qua IP giả lập `http://10.0.2.2:5276/api`.
     - Trên **iOS / Web / Windows Desktop**: Kết nối qua `http://localhost:5276/api`.
     - *Lưu ý:* Nếu chạy trên **Thiết bị thật (Physical Device)**, hãy thay đổi IP `localhost` thành IP nội bộ WiFi của máy tính đang chạy backend (ví dụ: `http://192.168.1.5:5276/api`).
4. Khởi chạy ứng dụng:
   ```bash
   flutter run
   ```

---

## 🛠 Khắc phục lỗi thường gặp

### 1. Lỗi Developer Mode trên Windows
Khi build/run ứng dụng trên nền tảng Windows Desktop, nếu gặp lỗi yêu cầu Developer Mode:
1. Nhấn tổ hợp phím `Win + R`, nhập `start ms-settings:developers` và nhấn Enter.
2. Bật chế độ **Developer Mode** (Chế độ nhà phát triển) sang **On**.

### 2. Lỗi Kết Nối API (SocketException / Connection Refused)
- Đảm bảo backend API ở Bước 2 đang chạy và hiển thị cổng `5276`.
- Đảm bảo kết nối mạng giữa điện thoại/máy ảo và máy tính chạy server chung một đường truyền mạng.
- Tạm thời tắt Windows Defender Firewall nếu thiết bị thật không thể gọi API trên máy tính.

---

## Tài khoản Đăng nhập Mẫu
- **Email:** `admin@gmail.com`
- **Mật khẩu:** `123456`
