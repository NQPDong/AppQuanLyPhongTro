using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Data;
using System.Threading.Tasks;

namespace QuanLyPhongTroAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ReportsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public ReportsController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet("statistics")]
        public async Task<IActionResult> GetStatistics([FromQuery] string ownerId, [FromQuery] int year)
        {
            if (string.IsNullOrEmpty(ownerId))
            {
                return BadRequest(new { message = "ownerId không được để trống!" });
            }

            var monthlyRevenue = new double[12];
            int rentedCount = 0;
            int availableCount = 0;

            try
            {
                var connection = _context.Database.GetDbConnection();
                using (var command = connection.CreateCommand())
                {
                    command.CommandText = "sp_GetRevenueAndRoomStats";
                    command.CommandType = CommandType.StoredProcedure;
                    
                    var paramOwner = command.CreateParameter();
                    paramOwner.ParameterName = "@OwnerId";
                    paramOwner.Value = ownerId;
                    command.Parameters.Add(paramOwner);

                    var paramYear = command.CreateParameter();
                    paramYear.ParameterName = "@Year";
                    paramYear.Value = year;
                    command.Parameters.Add(paramYear);

                    await _context.Database.OpenConnectionAsync();

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        // Đọc kết quả 1: Doanh thu 12 tháng
                        while (await reader.ReadAsync())
                        {
                            int month = reader.GetInt32(0);
                            double revenue = reader.GetDouble(1);
                            if (month >= 1 && month <= 12)
                            {
                                monthlyRevenue[month - 1] = revenue;
                            }
                        }

                        // Chuyển sang kết quả 2: Trạng thái phòng
                        if (await reader.NextResultAsync())
                        {
                            if (await reader.ReadAsync())
                            {
                                rentedCount = reader.IsDBNull(0) ? 0 : reader.GetInt32(0);
                                availableCount = reader.IsDBNull(1) ? 0 : reader.GetInt32(1);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = $"Lỗi thực thi Stored Procedure: {ex.Message}" });
            }
            finally
            {
                await _context.Database.CloseConnectionAsync();
            }

            return Ok(new
            {
                monthlyRevenue = monthlyRevenue,
                rentedCount = rentedCount,
                availableCount = availableCount
            });
        }
    }
}
