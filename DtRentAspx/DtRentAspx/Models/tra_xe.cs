namespace DtRentAspx.Models
{
    using System;
    using System.Collections.Generic;
    using System.ComponentModel.DataAnnotations;
    using System.ComponentModel.DataAnnotations.Schema;
    using System.Data.Entity.Spatial;

    public partial class tra_xe
    {
        public long id { get; set; }

        public long phieu_thue_id { get; set; }

        public int nhan_vien_id { get; set; }

        [Column(TypeName = "datetime2")]
        public DateTime thoi_diem_tra_thuc_te { get; set; }

        public int so_km_tra { get; set; }

        public int km_da_di { get; set; }

        public int so_gio_tre { get; set; }

        public int km_vuot { get; set; }

        public decimal tien_thue { get; set; }

        public decimal phi_vuot_km { get; set; }

        public decimal phi_tre { get; set; }

        public decimal tong_truoc_giam { get; set; }

        public decimal tien_giam { get; set; }

        public decimal tong_phai_tra { get; set; }

        public bool xe_hu_hong { get; set; }

        public decimal? tinh_trang_pin_tra { get; set; }

        public string ghi_chu { get; set; }

        [Column(TypeName = "datetime2")]
        public DateTime ngay_tao { get; set; }

        public virtual nhan_vien nhan_vien { get; set; }

        public virtual phieu_thue phieu_thue { get; set; }
    }
}
