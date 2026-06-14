using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace QuanLyPhongTroAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ContractsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public ContractsController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetContracts([FromQuery] string ownerId)
        {
            if (string.IsNullOrEmpty(ownerId))
            {
                return BadRequest(new { message = "ownerId không được để trống!" });
            }



            var contracts = await _context.Contracts
                .Where(c => c.OwnerId == ownerId)
                .OrderByDescending(c => c.CreatedAt)
                .ToListAsync();

            return Ok(contracts);
        }

        [HttpGet("active/{roomId}")]
        public async Task<IActionResult> GetActiveContract(string roomId)
        {
            var contract = await _context.Contracts
                .Where(c => c.RoomId == roomId && c.Status == "active")
                .FirstOrDefaultAsync();

            if (contract == null) return NotFound();
            return Ok(contract);
        }

        [HttpPost]
        public async Task<IActionResult> CreateContract([FromBody] Contract contract)
        {
            if (contract == null) return BadRequest();

            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                contract.Id = Guid.NewGuid().ToString();
                contract.CreatedAt = DateTime.UtcNow;
                contract.Status = "active";
                contract.Code = await GenerateCode(contract.OwnerId);

                _context.Contracts.Add(contract);

                // Cập nhật trạng thái phòng thành 'rented'
                var room = await _context.Rooms.FindAsync(contract.RoomId);
                if (room != null)
                {
                    room.Status = "rented";
                }

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                return Ok(contract);
            }
            catch (Exception)
            {
                await transaction.RollbackAsync();
                throw;
            }
        }

        [HttpPost("terminate/{id}")]
        public async Task<IActionResult> TerminateContract(string id)
        {
            var contract = await _context.Contracts.FindAsync(id);
            if (contract == null) return NotFound();

            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                contract.Status = "terminated";

                // Cập nhật trạng thái phòng thành 'available'
                var room = await _context.Rooms.FindAsync(contract.RoomId);
                if (room != null)
                {
                    room.Status = "available";
                }

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                return Ok(contract);
            }
            catch (Exception)
            {
                await transaction.RollbackAsync();
                throw;
            }
        }

        private async Task<string> GenerateCode(string ownerId)
        {
            var codes = await _context.Contracts
                .Where(c => c.OwnerId == ownerId && c.Code.StartsWith("HD"))
                .Select(c => c.Code)
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
            return $"HD{(maxNumber + 1).ToString().PadLeft(3, '0')}";
        }
    }
}
