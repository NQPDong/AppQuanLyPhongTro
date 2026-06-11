using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace QuanLyPhongTroAPI
{
    public class User
    {
        [Key]
        [StringLength(450)]
        public string Id { get; set; } = string.Empty;

        [Required]
        [StringLength(256)]
        public string Email { get; set; } = string.Empty;

        [Required]
        public string PasswordHash { get; set; } = string.Empty;

        [Required]
        [StringLength(256)]
        public string FullName { get; set; } = string.Empty;

        [Required]
        [StringLength(50)]
        public string Role { get; set; } = "admin"; // admin or user

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }

    public class Property
    {
        [Key]
        [StringLength(450)]
        public string Id { get; set; } = string.Empty;

        [Required]
        [StringLength(450)]
        public string OwnerId { get; set; } = string.Empty;

        [Required]
        [StringLength(256)]
        public string Name { get; set; } = string.Empty;

        [Required]
        public string Address { get; set; } = string.Empty;

        public string ImageUrl { get; set; } = string.Empty;

        public int RoomCount { get; set; } = 0;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }

    public class Room
    {
        [Key]
        [StringLength(450)]
        public string Id { get; set; } = string.Empty;

        [Required]
        [StringLength(450)]
        public string PropertyId { get; set; } = string.Empty;

        [Required]
        [StringLength(450)]
        public string OwnerId { get; set; } = string.Empty;

        [Required]
        [StringLength(50)]
        public string RoomNumber { get; set; } = string.Empty;

        public int Floor { get; set; } = 1;

        public double Area { get; set; } = 0;

        public double Price { get; set; } = 0;

        public string Description { get; set; } = string.Empty;

        [Required]
        [StringLength(50)]
        public string Status { get; set; } = "available"; // available, rented, maintenance

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }

    public class Tenant
    {
        [Key]
        [StringLength(450)]
        public string Id { get; set; } = string.Empty;

        [Required]
        [StringLength(450)]
        public string OwnerId { get; set; } = string.Empty;

        [Required]
        [StringLength(256)]
        public string FullName { get; set; } = string.Empty;

        [Required]
        [StringLength(50)]
        public string Phone { get; set; } = string.Empty;

        [Required]
        [StringLength(50)]
        public string IdCard { get; set; } = string.Empty;

        public string Address { get; set; } = string.Empty;

        public string Notes { get; set; } = string.Empty;

        [StringLength(50)]
        public string Code { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }

    public class Contract
    {
        [Key]
        [StringLength(450)]
        public string Id { get; set; } = string.Empty;

        [Required]
        [StringLength(450)]
        public string OwnerId { get; set; } = string.Empty;

        [Required]
        [StringLength(450)]
        public string PropertyId { get; set; } = string.Empty;

        [Required]
        [StringLength(450)]
        public string RoomId { get; set; } = string.Empty;

        [Required]
        [StringLength(450)]
        public string TenantId { get; set; } = string.Empty;

        public DateTime StartDate { get; set; }

        public DateTime EndDate { get; set; }

        public double DepositAmount { get; set; }

        [Required]
        [StringLength(50)]
        public string Status { get; set; } = "active"; // active, expired, terminated

        [StringLength(50)]
        public string Code { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }

    public class Invoice
    {
        [Key]
        [StringLength(450)]
        public string Id { get; set; } = string.Empty;

        [Required]
        [StringLength(450)]
        public string OwnerId { get; set; } = string.Empty;

        [Required]
        [StringLength(450)]
        public string ContractId { get; set; } = string.Empty;

        [Required]
        [StringLength(450)]
        public string RoomId { get; set; } = string.Empty;

        [Required]
        [StringLength(450)]
        public string TenantId { get; set; } = string.Empty;

        public int Month { get; set; }

        public int Year { get; set; }

        public double OldElec { get; set; }

        public double NewElec { get; set; }

        public double ElecPrice { get; set; }

        public double OldWater { get; set; }

        public double NewWater { get; set; }

        public double WaterPrice { get; set; }

        public double ServiceFee { get; set; } = 0;

        public double TotalAmount { get; set; }

        public bool IsPaid { get; set; } = false;

        public DateTime? PaidDate { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
