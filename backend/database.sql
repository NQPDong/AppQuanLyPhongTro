-- =========================================================================
-- FILE TẠO CƠ SỞ DỮ LIỆU VÀ BẢNG CHO DỰ ÁN QUẢN LÝ PHÒNG TRỌ (SQL SERVER)
-- =========================================================================

-- 1. Tạo cơ sở dữ liệu mới
CREATE DATABASE [QuanLyPhongTro];
GO

USE [QuanLyPhongTro];
GO

-- 2. Tạo bảng Users (Lưu thông tin Chủ trọ)
CREATE TABLE [Users] (
    [Id] NVARCHAR(450) NOT NULL CONSTRAINT [PK_Users] PRIMARY KEY,
    [Email] NVARCHAR(256) NOT NULL,
    [PasswordHash] NVARCHAR(MAX) NOT NULL,
    [FullName] NVARCHAR(256) NOT NULL,
    [Role] NVARCHAR(50) NOT NULL DEFAULT 'admin', -- 'admin' hoặc 'user'
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);
GO

-- Tạo index duy nhất trên cột Email để chống trùng lặp tài khoản
CREATE UNIQUE INDEX [IX_Users_Email] ON [Users] ([Email]);
GO

-- 3. Bảng Properties (Lưu thông tin Cơ sở trọ)
CREATE TABLE [Properties] (
    [Id] NVARCHAR(450) NOT NULL CONSTRAINT [PK_Properties] PRIMARY KEY,
    [OwnerId] NVARCHAR(450) NOT NULL,
    [Name] NVARCHAR(256) NOT NULL,
    [Address] NVARCHAR(MAX) NOT NULL,
    [ImageUrl] NVARCHAR(MAX) NOT NULL,
    [RoomCount] INT NOT NULL DEFAULT 0,
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT [FK_Properties_Users_OwnerId] FOREIGN KEY ([OwnerId]) REFERENCES [Users] ([Id]) ON DELETE CASCADE
);
GO

-- 4. Bảng Rooms (Lưu thông tin Phòng trọ)
CREATE TABLE [Rooms] (
    [Id] NVARCHAR(450) NOT NULL CONSTRAINT [PK_Rooms] PRIMARY KEY,
    [PropertyId] NVARCHAR(450) NOT NULL,
    [OwnerId] NVARCHAR(450) NOT NULL,
    [RoomNumber] NVARCHAR(50) NOT NULL,
    [Floor] INT NOT NULL DEFAULT 1,
    [Area] FLOAT NOT NULL,
    [Price] FLOAT NOT NULL,
    [Description] NVARCHAR(MAX) NOT NULL,
    [Status] NVARCHAR(50) NOT NULL DEFAULT 'available', -- Trạng thái: available, rented, maintenance
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT [FK_Rooms_Properties_PropertyId] FOREIGN KEY ([PropertyId]) REFERENCES [Properties] ([Id]) ON DELETE NO ACTION,
    CONSTRAINT [FK_Rooms_Users_OwnerId] FOREIGN KEY ([OwnerId]) REFERENCES [Users] ([Id]) ON DELETE NO ACTION
);
GO

-- 5. Bảng Tenants (Lưu thông tin Khách thuê)
CREATE TABLE [Tenants] (
    [Id] NVARCHAR(450) NOT NULL CONSTRAINT [PK_Tenants] PRIMARY KEY,
    [OwnerId] NVARCHAR(450) NOT NULL,
    [FullName] NVARCHAR(256) NOT NULL,
    [Phone] NVARCHAR(50) NOT NULL,
    [IdCard] NVARCHAR(50) NOT NULL,
    [Address] NVARCHAR(MAX) NOT NULL,
    [Notes] NVARCHAR(MAX) NOT NULL,
    [Code] NVARCHAR(50) NOT NULL, -- Mã khách thuê (vd: KH001, KH002)
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT [FK_Tenants_Users_OwnerId] FOREIGN KEY ([OwnerId]) REFERENCES [Users] ([Id]) ON DELETE CASCADE
);
GO

-- 6. Bảng Contracts (Lưu thông tin Hợp đồng)
CREATE TABLE [Contracts] (
    [Id] NVARCHAR(450) NOT NULL CONSTRAINT [PK_Contracts] PRIMARY KEY,
    [OwnerId] NVARCHAR(450) NOT NULL,
    [PropertyId] NVARCHAR(450) NOT NULL,
    [RoomId] NVARCHAR(450) NOT NULL,
    [TenantId] NVARCHAR(450) NOT NULL,
    [StartDate] DATETIME2 NOT NULL,
    [EndDate] DATETIME2 NOT NULL,
    [DepositAmount] FLOAT NOT NULL,
    [Status] NVARCHAR(50) NOT NULL DEFAULT 'active', -- Trạng thái hợp đồng: active, expired, terminated
    [Code] NVARCHAR(50) NOT NULL, -- Mã hợp đồng (vd: HD001, HD002)
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT [FK_Contracts_Users_OwnerId] FOREIGN KEY ([OwnerId]) REFERENCES [Users] ([Id]) ON DELETE NO ACTION,
    CONSTRAINT [FK_Contracts_Properties_PropertyId] FOREIGN KEY ([PropertyId]) REFERENCES [Properties] ([Id]) ON DELETE NO ACTION,
    CONSTRAINT [FK_Contracts_Rooms_RoomId] FOREIGN KEY ([RoomId]) REFERENCES [Rooms] ([Id]) ON DELETE NO ACTION,
    CONSTRAINT [FK_Contracts_Tenants_TenantId] FOREIGN KEY ([TenantId]) REFERENCES [Tenants] ([Id]) ON DELETE NO ACTION
);
GO

-- 7. Bảng Invoices (Lưu thông tin Hóa đơn phát sinh hàng tháng)
CREATE TABLE [Invoices] (
    [Id] NVARCHAR(450) NOT NULL CONSTRAINT [PK_Invoices] PRIMARY KEY,
    [OwnerId] NVARCHAR(450) NOT NULL,
    [ContractId] NVARCHAR(450) NOT NULL,
    [RoomId] NVARCHAR(450) NOT NULL,
    [TenantId] NVARCHAR(450) NOT NULL,
    [Month] INT NOT NULL,
    [Year] INT NOT NULL,
    [OldElec] FLOAT NOT NULL,
    [NewElec] FLOAT NOT NULL,
    [ElecPrice] FLOAT NOT NULL,
    [OldWater] FLOAT NOT NULL,
    [NewWater] FLOAT NOT NULL,
    [WaterPrice] FLOAT NOT NULL,
    [ServiceFee] FLOAT NOT NULL DEFAULT 0,
    [TotalAmount] FLOAT NOT NULL,
    [IsPaid] BIT NOT NULL DEFAULT 0, -- 0: Chưa thanh toán, 1: Đã thanh toán
    [PaidDate] DATETIME2 NULL, -- Ngày nộp tiền
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT [FK_Invoices_Users_OwnerId] FOREIGN KEY ([OwnerId]) REFERENCES [Users] ([Id]) ON DELETE NO ACTION,
    CONSTRAINT [FK_Invoices_Contracts_ContractId] FOREIGN KEY ([ContractId]) REFERENCES [Contracts] ([Id]) ON DELETE NO ACTION,
    CONSTRAINT [FK_Invoices_Rooms_RoomId] FOREIGN KEY ([RoomId]) REFERENCES [Rooms] ([Id]) ON DELETE NO ACTION,
    CONSTRAINT [FK_Invoices_Tenants_TenantId] FOREIGN KEY ([TenantId]) REFERENCES [Tenants] ([Id]) ON DELETE NO ACTION
);
GO

-- 8. Thêm dữ liệu mẫu (2 Users)
INSERT INTO [Users] ([Id], [Email], [PasswordHash], [FullName], [Role], [CreatedAt])
VALUES 
('d0a92b23-1d4e-4fdf-9759-99447477c7f1', 'admin@gmail.com', '$2a$11$WzNzqt2VZCd4ednXZmNRbu3aZvTC5eWVuPUBghb3.NhNY22fiEywS', N'Nguyễn Văn A', 'admin', GETUTCDATE()),
('39c7e098-b8bc-4676-96b3-ec4d420f5c8a', 'user@gmail.com', '$2a$11$WzNzqt2VZCd4ednXZmNRbu3aZvTC5eWVuPUBghb3.NhNY22fiEywS', N'Trần Thị B', 'user', GETUTCDATE());
GO

-- 9. Thêm dữ liệu mẫu 10 Khách thuê (thuộc sở hữu của Nguyễn Văn A)
INSERT INTO [Tenants] ([Id], [OwnerId], [FullName], [Phone], [IdCard], [Address], [Notes], [Code], [CreatedAt])
VALUES 
('b036573c-f4e9-4e0f-90e8-0b5c1a89c9df', 'd0a92b23-1d4e-4fdf-9759-99447477c7f1', N'Nguyễn Văn Nam', '0912345678', '123456789', N'Hà Nội', N'Sinh viên Bách Khoa', 'KH001', GETUTCDATE()),
('a4fe83cd-f446-4cb4-a1b4-2e912445fb9f', 'd0a92b23-1d4e-4fdf-9759-99447477c7f1', N'Trần Thị Hoa', '0987654321', '987654321', N'Hải Phòng', N'Nhân viên văn phòng', 'KH002', GETUTCDATE()),
('f648e89c-ff7b-402a-a92c-6119934177de', 'd0a92b23-1d4e-4fdf-9759-99447477c7f1', N'Lê Minh Tuấn', '0905123456', '012345678901', N'Đà Nẵng', N'Khách thuê lâu dài', 'KH003', GETUTCDATE()),
('c36a4b12-9cbb-46f3-8f0a-a035a92a54ff', 'd0a92b23-1d4e-4fdf-9759-99447477c7f1', N'Phạm Thu Thủy', '0934567890', '023456789012', N'TP Hồ Chí Minh', N'Sinh viên Y Dược', 'KH004', GETUTCDATE()),
('d9f4c3a2-2b36-4c48-8df0-e66b4458bcfd', 'd0a92b23-1d4e-4fdf-9759-99447477c7f1', N'Hoàng Anh Dũng', '0388776655', '388776655', N'Nghệ An', N'Người đi làm', 'KH005', GETUTCDATE()),
('7c4e512c-473d-4c3d-80f3-b9df56012cc4', 'd0a92b23-1d4e-4fdf-9759-99447477c7f1', N'Vũ Thị Lan', '0776543210', '776543210', N'Thanh Hóa', N'Kế toán', 'KH006', GETUTCDATE()),
('eb4e8c56-fbb2-402c-a23e-0c0ef1ad7de1', 'd0a92b23-1d4e-4fdf-9759-99447477c7f1', N'Đặng Quốc Việt', '0567890123', '056789012345', N'Quảng Ninh', N'Kỹ sư phần mềm', 'KH007', GETUTCDATE()),
('2b4c12ef-dd89-4e78-bc5a-e7c61bf968fd', 'd0a92b23-1d4e-4fdf-9759-99447477c7f1', N'Đỗ Mai Phương', '0965432198', '965432198', N'Nam Định', N'Sinh viên Ngoại Thương', 'KH008', GETUTCDATE()),
('3a4b98dc-ee78-4cf8-bd5f-e2c7a52f86ad', 'd0a92b23-1d4e-4fdf-9759-99447477c7f1', N'Bùi Xuân Trường', '0898765432', '898765432', N'Thái Bình', N'Kỹ thuật viên', 'KH009', GETUTCDATE()),
('8d7c49ea-f678-4cf8-b35e-c12e8bcf6d34', 'd0a92b23-1d4e-4fdf-9759-99447477c7f1', N'Phan Thanh Hà', '0356789123', '035678912345', N'Lâm Đồng', N'Nhân viên ngân hàng', 'KH010', GETUTCDATE());
GO

-- 10. Thêm 1 Cơ sở trọ (thuộc sở hữu của Nguyễn Văn A, có 10 phòng)
INSERT INTO [Properties] ([Id], [OwnerId], [Name], [Address], [ImageUrl], [RoomCount], [CreatedAt])
VALUES 
('75fbde67-1111-477c-bf87-6e65b43dcd71', 'd0a92b23-1d4e-4fdf-9759-99447477c7f1', N'Nhà trọ Cầu Giấy', N'Số 12 Ngõ 102 Cầu Giấy, Hà Nội', '', 10, GETUTCDATE());
GO

-- 11. Thêm 10 Phòng trọ thuộc Cơ sở trọ Cầu Giấy vừa tạo
INSERT INTO [Rooms] ([Id], [PropertyId], [OwnerId], [RoomNumber], [Floor], [Area], [Price], [Description], [Status], [CreatedAt])
VALUES 
('d0e8fc72-0101-4477-90bc-23ff1a600001', '75fbde67-1111-477c-bf87-6e65b43dcd71', 'd0a92b23-1d4e-4fdf-9759-99447477c7f1', '101', 1, 20.0, 2500000, N'Phòng tầng 1, vệ sinh khép kín, tiện đi lại', 'available', GETUTCDATE()),
('d0e8fc72-0102-4477-90bc-23ff1a600002', '75fbde67-1111-477c-bf87-6e65b43dcd71', 'd0a92b23-1d4e-4fdf-9759-99447477c7f1', '102', 1, 20.0, 2500000, N'Phòng tầng 1, thoáng mát, vệ sinh khép kín', 'available', GETUTCDATE()),
('d0e8fc72-0103-4477-90bc-23ff1a600003', '75fbde67-1111-477c-bf87-6e65b43dcd71', 'd0a92b23-1d4e-4fdf-9759-99447477c7f1', '103', 1, 20.0, 2500000, N'Phòng tầng 1 bên góc, yên tĩnh', 'available', GETUTCDATE()),
('d0e8fc72-0201-4477-90bc-23ff1a600004', '75fbde67-1111-477c-bf87-6e65b43dcd71', 'd0a92b23-1d4e-4fdf-9759-99447477c7f1', '201', 2, 22.0, 2800000, N'Phòng tầng 2, có ban công rộng rãi, sạch sẽ', 'available', GETUTCDATE()),
('d0e8fc72-0202-4477-90bc-23ff1a600005', '75fbde67-1111-477c-bf87-6e65b43dcd71', 'd0a92b23-1d4e-4fdf-9759-99447477c7f1', '202', 2, 22.0, 2800000, N'Phòng tầng 2 ở giữa, thiết kế hiện đại', 'available', GETUTCDATE()),
('d0e8fc72-0203-4477-90bc-23ff1a600006', '75fbde67-1111-477c-bf87-6e65b43dcd71', 'd0a92b23-1d4e-4fdf-9759-99447477c7f1', '203', 2, 22.0, 2800000, N'Phòng tầng 2, đầy đủ ánh sáng tự nhiên', 'available', GETUTCDATE()),
('d0e8fc72-0301-4477-90bc-23ff1a600007', '75fbde67-1111-477c-bf87-6e65b43dcd71', 'd0a92b23-1d4e-4fdf-9759-99447477c7f1', '301', 3, 22.0, 2800000, N'Phòng tầng 3, ban công rộng, view đẹp', 'available', GETUTCDATE()),
('d0e8fc72-0302-4477-90bc-23ff1a600008', '75fbde67-1111-477c-bf87-6e65b43dcd71', 'd0a92b23-1d4e-4fdf-9759-99447477c7f1', '302', 3, 22.0, 2800000, N'Phòng tầng 3 ở giữa, ấm cúng', 'available', GETUTCDATE()),
('d0e8fc72-0303-4477-90bc-23ff1a600009', '75fbde67-1111-477c-bf87-6e65b43dcd71', 'd0a92b23-1d4e-4fdf-9759-99447477c7f1', '303', 3, 22.0, 2800000, N'Phòng tầng 3, đang sửa chữa điều hòa', 'maintenance', GETUTCDATE()),
('d0e8fc72-0401-4477-90bc-23ff1a600100', '75fbde67-1111-477c-bf87-6e65b43dcd71', 'd0a92b23-1d4e-4fdf-9759-99447477c7f1', '401', 4, 25.0, 3200000, N'Phòng tầng 4, diện tích lớn, có cửa sổ lớn', 'available', GETUTCDATE());
GO


CREATE PROCEDURE [dbo].[sp_GetRevenueAndRoomStats]
    @OwnerId NVARCHAR(450),
    @Year    INT
AS
BEGIN
    SET NOCOUNT ON;

    -- ResultSet 1: Tong doanh thu hoa don DA THANH TOAN, nhom theo tung thang
    SELECT
        i.[Month]             AS [Month],
        SUM(i.[TotalAmount])  AS [Revenue]
    FROM [dbo].[Invoices] i
    WHERE
        i.[OwnerId] = @OwnerId
        AND i.[Year]   = @Year
        AND i.[IsPaid] = 1
    GROUP BY i.[Month]
    ORDER BY i.[Month];

    -- ResultSet 2: So phong dang cho thue va so phong dang trong
    SELECT
        SUM(CASE WHEN r.[Status] = 'rented'    THEN 1 ELSE 0 END) AS [RentedCount],
        SUM(CASE WHEN r.[Status] = 'available' THEN 1 ELSE 0 END) AS [AvailableCount]
    FROM [dbo].[Rooms] r
    WHERE r.[OwnerId] = @OwnerId;
END;
GO
