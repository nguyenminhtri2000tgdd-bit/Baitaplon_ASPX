namespace DtRentAspx.Models
{
    using System;
    using System.Collections.Generic;
    using System.ComponentModel.DataAnnotations;
    using System.ComponentModel.DataAnnotations.Schema;
    using System.Data.Entity.Spatial;

    public partial class bao_tri
    {
        public int id { get; set; }

        public int xe_id { get; set; }

        public int nhan_vien_id { get; set; }

        [Required]
        [StringLength(15)]
        public string loai { get; set; }

        [Required]
        public string mo_ta { get; set; }

        [Column(TypeName = "date")]
        public DateTime ngay_bat_dau { get; set; }

        [Column(TypeName = "date")]
        public DateTime? ngay_ket_thuc { get; set; }

        public decimal chi_phi { get; set; }

        [Required]
        [StringLength(15)]
        public string trang_thai { get; set; }

        public virtual nhan_vien nhan_vien { get; set; }

        public virtual xe xe { get; set; }
    }
}
