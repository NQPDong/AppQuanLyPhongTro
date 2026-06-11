using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace QuanLyPhongTroAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class InvoicesController : ControllerBase
    {
        private readonly AppDbContext _context;

        public InvoicesController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetInvoices([FromQuery] string? ownerId = null, [FromQuery] string? contractId = null)
        {
            IQueryable<Invoice> query = _context.Invoices;

            if (!string.IsNullOrEmpty(ownerId))
            {
                query = query.Where(i => i.OwnerId == ownerId);
            }

            if (!string.IsNullOrEmpty(contractId))
            {
                query = query.Where(i => i.ContractId == contractId);
            }

            var invoices = await query
                .OrderByDescending(i => i.CreatedAt)
                .ToListAsync();

            return Ok(invoices);
        }

        [HttpPost]
        public async Task<IActionResult> CreateInvoice([FromBody] Invoice invoice)
        {
            if (invoice == null) return BadRequest();

            // Kiểm tra hóa đơn trùng tháng/năm
            var exists = await _context.Invoices.AnyAsync(i => 
                i.ContractId == invoice.ContractId && 
                i.Month == invoice.Month && 
                i.Year == invoice.Year);

            if (exists)
            {
                return BadRequest(new { message = $"Hóa đơn tháng {invoice.Month}/{invoice.Year} đã tồn tại cho hợp đồng này!" });
            }

            invoice.Id = Guid.NewGuid().ToString();
            invoice.CreatedAt = DateTime.UtcNow;
            invoice.IsPaid = false;
            invoice.PaidDate = null;

            _context.Invoices.Add(invoice);
            await _context.SaveChangesAsync();

            return Ok(invoice);
        }

        [HttpPut("{id}/pay")]
        public async Task<IActionResult> MarkAsPaid(string id)
        {
            var invoice = await _context.Invoices.FindAsync(id);
            if (invoice == null) return NotFound();

            invoice.IsPaid = true;
            invoice.PaidDate = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return Ok(invoice);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteInvoice(string id)
        {
            var invoice = await _context.Invoices.FindAsync(id);
            if (invoice == null) return NotFound();

            _context.Invoices.Remove(invoice);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Xóa hóa đơn thành công!" });
        }
    }
}
