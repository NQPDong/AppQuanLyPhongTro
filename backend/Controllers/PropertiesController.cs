using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace QuanLyPhongTroAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PropertiesController : ControllerBase
    {
        private readonly AppDbContext _context;

        public PropertiesController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetProperties([FromQuery] string ownerId)
        {
            if (string.IsNullOrEmpty(ownerId))
            {
                return BadRequest(new { message = "ownerId không được để trống!" });
            }



            var properties = await _context.Properties
                .Where(p => p.OwnerId == ownerId)
                .OrderByDescending(p => p.CreatedAt)
                .ToListAsync();

            return Ok(properties);
        }

        [HttpPost]
        public async Task<IActionResult> AddProperty([FromBody] Property property)
        {
            if (property == null) return BadRequest();

            property.Id = Guid.NewGuid().ToString();
            property.CreatedAt = DateTime.UtcNow;
            property.RoomCount = 0;

            _context.Properties.Add(property);
            await _context.SaveChangesAsync();

            return Ok(property);
        }

        public class UpdatePropertyRequest
        {
            public string Name { get; set; } = string.Empty;
            public string Address { get; set; } = string.Empty;
            public string ImageUrl { get; set; } = string.Empty;
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateProperty(string id, [FromBody] UpdatePropertyRequest updatedProperty)
        {
            var property = await _context.Properties.FindAsync(id);
            if (property == null) return NotFound();

            property.Name = (updatedProperty.Name ?? string.Empty).Trim();
            property.Address = (updatedProperty.Address ?? string.Empty).Trim();
            property.ImageUrl = updatedProperty.ImageUrl ?? string.Empty;

            await _context.SaveChangesAsync();
            return Ok(property);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteProperty(string id)
        {
            var property = await _context.Properties.FindAsync(id);
            if (property == null) return NotFound();

            // Xóa cascade thủ công để tránh lỗi khóa ngoại (Foreign Key)
            var rooms = await _context.Rooms.Where(r => r.PropertyId == id).ToListAsync();
            foreach (var room in rooms)
            {
                var contracts = await _context.Contracts.Where(c => c.RoomId == room.Id).ToListAsync();
                _context.Contracts.RemoveRange(contracts);

                var invoices = await _context.Invoices.Where(i => i.RoomId == room.Id).ToListAsync();
                _context.Invoices.RemoveRange(invoices);
            }
            _context.Rooms.RemoveRange(rooms);

            _context.Properties.Remove(property);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Xóa cơ sở trọ thành công!" });
        }
    }
}
