namespace DtRentAspx.Models
{
    using System;
    using System.Collections.Generic;
    using System.ComponentModel.DataAnnotations;
    using System.ComponentModel.DataAnnotations.Schema;
    using System.Data.Entity.Spatial;

    public partial class thanh_toan
    {
        public long id { get; set; }

        public long phieu_thue_id { get; set; }

        public int nhan_vien_id { get; set; }

        [Required]
        [StringLength(15)]
        public string loai_giao_dich { get; set; }

        [Required]
        [StringLength(15)]
        public string phuong_thuc { get; set; }

        public decimal so_tien { get; set; }

        [Required]
        public string chi_tiet { get; set; }

        [Column(TypeName = "datetime2")]
        public DateTime thoi_diem { get; set; }

        public virtual nhan_vien nhan_vien { get; set; }

        public virtual phieu_thue phieu_thue { get; set; }
    }
}
