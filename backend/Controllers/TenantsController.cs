using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace QuanLyPhongTroAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class TenantsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public TenantsController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetTenants([FromQuery] string ownerId)
        {
            if (string.IsNullOrEmpty(ownerId))
            {
                return BadRequest(new { message = "ownerId không được để trống!" });
            }



            var tenants = await _context.Tenants
                .Where(t => t.OwnerId == ownerId)
                .OrderBy(t => t.FullName)
                .ToListAsync();

            return Ok(tenants);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetTenant(string id)
        {
            var tenant = await _context.Tenants.FindAsync(id);
            if (tenant == null) return NotFound();
            return Ok(tenant);
        }

        [HttpPost]
        public async Task<IActionResult> AddTenant([FromBody] Tenant tenant)
        {
            if (tenant == null) return BadRequest();

            // Kiểm tra trùng CMND/CCCD
            var exists = await _context.Tenants.AnyAsync(t => t.OwnerId == tenant.OwnerId && t.IdCard == tenant.IdCard);
            if (exists)
            {
                return BadRequest(new { message = "Khách hàng với số CMND/CCCD này đã tồn tại!" });
            }

            tenant.Id = Guid.NewGuid().ToString();
            tenant.CreatedAt = DateTime.UtcNow;
            tenant.Code = await GenerateCode(tenant.OwnerId);

            _context.Tenants.Add(tenant);
            await _context.SaveChangesAsync();

            return Ok(tenant);
        }

        public class UpdateTenantRequest
        {
            public string FullName { get; set; } = string.Empty;
            public string Phone { get; set; } = string.Empty;
            public string IdCard { get; set; } = string.Empty;
            public string Address { get; set; } = string.Empty;
            public string Notes { get; set; } = string.Empty;
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateTenant(string id, [FromBody] UpdateTenantRequest updatedTenant)
        {
            var tenant = await _context.Tenants.FindAsync(id);
            if (tenant == null) return NotFound();

            tenant.FullName = (updatedTenant.FullName ?? string.Empty).Trim();
            tenant.Phone = (updatedTenant.Phone ?? string.Empty).Trim();
            tenant.IdCard = (updatedTenant.IdCard ?? string.Empty).Trim();
            tenant.Address = (updatedTenant.Address ?? string.Empty).Trim();
            tenant.Notes = (updatedTenant.Notes ?? string.Empty).Trim();

            await _context.SaveChangesAsync();
            return Ok(tenant);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteTenant(string id)
        {
            var tenant = await _context.Tenants.FindAsync(id);
            if (tenant == null) return NotFound();

            // Xóa các hợp đồng và hóa đơn liên quan để tránh lỗi khóa ngoại
            var contracts = await _context.Contracts.Where(c => c.TenantId == id).ToListAsync();
            _context.Contracts.RemoveRange(contracts);

            var invoices = await _context.Invoices.Where(i => i.TenantId == id).ToListAsync();
            _context.Invoices.RemoveRange(invoices);

            _context.Tenants.Remove(tenant);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Xóa khách thuê thành công!" });
        }

        private async Task<string> GenerateCode(string ownerId)
        {
            var codes = await _context.Tenants
                .Where(t => t.OwnerId == ownerId && t.Code.StartsWith("KH"))
                .Select(t => t.Code)
                .ToListAsync();

            int maxNumber = 0;
            foreach (var code in codes)
            {
                if (code.Length > 2)
                {
                    var numberPart = code.Substring(2);
                    if (int.TryParse(numberPart, out int number))
                    {
                        if (number > maxNumber) maxNumber = number;
                    }
                }
            }
            return $"KH{(maxNumber + 1).ToString().PadLeft(3, '0')}";
        }
    }
}
