using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace QuanLyPhongTroAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class RoomsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public RoomsController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetRooms(
            [FromQuery] string? propertyId = null, 
            [FromQuery] string? ownerId = null,
            [FromQuery] string? status = null, 
            [FromQuery] string? query = null, 
            [FromQuery] double? minPrice = null, 
            [FromQuery] double? maxPrice = null)
        {
            if (string.IsNullOrEmpty(propertyId) && string.IsNullOrEmpty(ownerId))
            {
                return BadRequest(new { message = "propertyId hoặc ownerId không được để trống!" });
            }

            if (!string.IsNullOrEmpty(ownerId))
            {

            }

            IQueryable<Room> q = _context.Rooms;
            if (!string.IsNullOrEmpty(propertyId))
            {
                q = q.Where(r => r.PropertyId == propertyId);
            }
            else if (!string.IsNullOrEmpty(ownerId))
            {
                q = q.Where(r => r.OwnerId == ownerId);
            }

            if (!string.IsNullOrEmpty(status) && status != "all")
            {
                q = q.Where(r => r.Status == status);
            }

            var rooms = await q.ToListAsync();

            // Lọc thêm client-side/in-memory giống Firestore service hoặc viết query trực tiếp
            if (minPrice.HasValue)
            {
                rooms = rooms.Where(r => r.Price >= minPrice.Value).ToList();
            }
            if (maxPrice.HasValue)
            {
                rooms = rooms.Where(r => r.Price <= maxPrice.Value).ToList();
            }
            if (!string.IsNullOrEmpty(query))
            {
                rooms = rooms.Where(r => r.RoomNumber.Contains(query, StringComparison.OrdinalIgnoreCase)).ToList();
            }

            var orderedRooms = rooms.OrderBy(r => r.RoomNumber).ToList();

            return Ok(orderedRooms);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetRoom(string id)
        {
            var room = await _context.Rooms.FindAsync(id);
            if (room == null) return NotFound();
            return Ok(room);
        }

        [HttpPost]
        public async Task<IActionResult> AddRoom([FromBody] Room room)
        {
            if (room == null) return BadRequest();

            // Kiểm tra trùng số phòng
            var exists = await _context.Rooms.AnyAsync(r => r.PropertyId == room.PropertyId && r.RoomNumber == room.RoomNumber);
            if (exists)
            {
                return BadRequest(new { message = "Số phòng này đã tồn tại!" });
            }

            room.Id = Guid.NewGuid().ToString();
            room.CreatedAt = DateTime.UtcNow;
            room.Status = "available";

            _context.Rooms.Add(room);

            // Cập nhật số lượng phòng của Cơ sở
            var property = await _context.Properties.FindAsync(room.PropertyId);
            if (property != null)
            {
                property.RoomCount += 1;
            }

            await _context.SaveChangesAsync();

            return Ok(room);
        }

        public class UpdateRoomRequest
        {
            public string RoomNumber { get; set; } = string.Empty;
            public int Floor { get; set; }
            public double Area { get; set; }
            public double Price { get; set; }
            public string Description { get; set; } = string.Empty;
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateRoom(string id, [FromBody] UpdateRoomRequest updatedRoom)
        {
            var room = await _context.Rooms.FindAsync(id);
            if (room == null) return NotFound();

            room.RoomNumber = (updatedRoom.RoomNumber ?? string.Empty).Trim();
            room.Floor = updatedRoom.Floor;
            room.Area = updatedRoom.Area;
            room.Price = updatedRoom.Price;
            room.Description = (updatedRoom.Description ?? string.Empty).Trim();

            await _context.SaveChangesAsync();
            return Ok(room);
        }

        [HttpPut("{id}/status")]
        public async Task<IActionResult> UpdateStatus(string id, [FromBody] StatusUpdateRequest request)
        {
            var room = await _context.Rooms.FindAsync(id);
            if (room == null) return NotFound();

            room.Status = request.Status;
            await _context.SaveChangesAsync();
            return Ok(room);
        }

        public class StatusUpdateRequest
        {
            public string Status { get; set; } = string.Empty;
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteRoom(string id)
        {
            var room = await _context.Rooms.FindAsync(id);
            if (room == null) return NotFound();

            var propertyId = room.PropertyId;

            // Xóa các hợp đồng và hóa đơn liên quan để tránh lỗi FK
            var contracts = await _context.Contracts.Where(c => c.RoomId == id).ToListAsync();
            _context.Contracts.RemoveRange(contracts);

            var invoices = await _context.Invoices.Where(i => i.RoomId == id).ToListAsync();
            _context.Invoices.RemoveRange(invoices);

            _context.Rooms.Remove(room);

            // Giảm số lượng phòng của Cơ sở
            var property = await _context.Properties.FindAsync(propertyId);
            if (property != null)
            {
                property.RoomCount = Math.Max(0, property.RoomCount - 1);
            }

            await _context.SaveChangesAsync();
            return Ok(new { message = "Xóa phòng thành công!" });
        }
    }
}
