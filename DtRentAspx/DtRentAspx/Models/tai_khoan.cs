namespace DtRentAspx.Models
{
    using System;
    using System.Collections.Generic;
    using System.ComponentModel.DataAnnotations;
    using System.ComponentModel.DataAnnotations.Schema;
    using System.Data.Entity.Spatial;

    public partial class tai_khoan
    {
        public int id { get; set; }

        public int nhan_vien_id { get; set; }

        [Required]
        [StringLength(50)]
        public string ten_dang_nhap { get; set; }

        [Required]
        public string mat_khau_hash { get; set; }

        [Required]
        [StringLength(20)]
        public string vai_tro { get; set; }

        public bool dang_hoat_dong { get; set; }

        [Column(TypeName = "datetime2")]
        public DateTime ngay_tao { get; set; }

        public virtual nhan_vien nhan_vien { get; set; }
    }
}
