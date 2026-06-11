using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using QuanLyPhongTroAPI;

var builder = WebApplication.CreateBuilder(args);

// Cấu hình Kestrel để chạy cổng HTTP 5276 trên mọi card mạng (cho phép máy ảo/thiết bị ngoài kết nối)
builder.WebHost.ConfigureKestrel(options =>
{
    options.ListenAnyIP(5276);
});

// Thêm dịch vụ DbContext kết nối SQL Server
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Thêm dịch vụ Controllers
builder.Services.AddControllers();

// Thêm cấu hình CORS cho phép mọi nguồn kết nối
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// Tự động khởi tạo database và các bảng trong SQL Server khi chạy ứng dụng
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    context.Database.EnsureCreated();

}

app.UseCors("AllowAll");

app.MapControllers();

app.Run();
