using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BCryptNet = BCrypt.Net.BCrypt;
using System;
using System.Threading.Tasks;

namespace QuanLyPhongTroAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly AppDbContext _context;

        public AuthController(AppDbContext context)
        {
            _context = context;
        }

        public class RegisterRequest
        {
            public string Email { get; set; } = string.Empty;
            public string Password { get; set; } = string.Empty;
            public string FullName { get; set; } = string.Empty;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
            {
                return BadRequest(new { message = "Email và mật khẩu không được trống!" });
            }

            var emailNormalized = request.Email.Trim().ToLower();
            var exists = await _context.Users.AnyAsync(u => u.Email.ToLower() == emailNormalized);
            if (exists)
            {
                return BadRequest(new { message = "Email này đã được sử dụng cho một tài khoản khác." });
            }

            var user = new User
            {
                Id = Guid.NewGuid().ToString(),
                Email = request.Email.Trim(),
                PasswordHash = BCryptNet.HashPassword(request.Password),
                FullName = string.IsNullOrWhiteSpace(request.FullName) ? request.Email.Split('@')[0] : request.FullName.Trim(),
                Role = "user",
                CreatedAt = DateTime.UtcNow
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            return Ok(user);
        }

        public class LoginRequest
        {
            public string Email { get; set; } = string.Empty;
            public string Password { get; set; } = string.Empty;
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
            {
                return BadRequest(new { message = "Email và mật khẩu không được trống!" });
            }

            var emailNormalized = request.Email.Trim().ToLower();
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email.ToLower() == emailNormalized);
            if (user == null || !BCryptNet.Verify(request.Password, user.PasswordHash))
            {
                return BadRequest(new { message = "Không tìm thấy tài khoản hoặc sai mật khẩu." });
            }

            return Ok(user);
        }

        public class UpdateNameRequest
        {
            public string UserId { get; set; } = string.Empty;
            public string FullName { get; set; } = string.Empty;
        }

        [HttpPost("update-name")]
        public async Task<IActionResult> UpdateName([FromBody] UpdateNameRequest request)
        {
            var user = await _context.Users.FindAsync(request.UserId);
            if (user == null)
            {
                return NotFound(new { message = "Không tìm thấy tài khoản." });
            }

            user.FullName = request.FullName.Trim();
            await _context.SaveChangesAsync();

            return Ok(user);
        }

        public class ResetPasswordRequest
        {
            public string Email { get; set; } = string.Empty;
        }

        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequest request)
        {
            var emailNormalized = request.Email.Trim().ToLower();
            var exists = await _context.Users.AnyAsync(u => u.Email.ToLower() == emailNormalized);
            if (!exists)
            {
                return BadRequest(new { message = "Không tìm thấy tài khoản với email này." });
            }

            // Gửi link reset giả định (vì chúng ta không cấu hình SMTP thực sự)
            return Ok(new { message = $"Link đổi mật khẩu đã được gửi tới {request.Email}" });
        }

        public class ChangePasswordRequest
        {
            public string UserId { get; set; } = string.Empty;
            public string OldPassword { get; set; } = string.Empty;
            public string NewPassword { get; set; } = string.Empty;
        }

        [HttpPost("change-password")]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
        {
            var user = await _context.Users.FindAsync(request.UserId);
            if (user == null)
            {
                return BadRequest(new { message = "Không tìm thấy tài khoản." });
            }

            if (user.PasswordHash != request.OldPassword)
            {
                return BadRequest(new { message = "Mật khẩu cũ không chính xác." });
            }

            user.PasswordHash = request.NewPassword;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Đổi mật khẩu thành công." });
        }
    }
}
