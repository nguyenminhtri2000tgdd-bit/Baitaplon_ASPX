namespace DtRentAspx.Models
{
    using System;
    using System.Collections.Generic;
    using System.ComponentModel.DataAnnotations;
    using System.ComponentModel.DataAnnotations.Schema;
    using System.Data.Entity.Spatial;

    public partial class phieu_thue
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public phieu_thue()
        {
            thanh_toan = new HashSet<thanh_toan>();
            tra_xe = new HashSet<tra_xe>();
        }

        public long id { get; set; }

        [Required]
        [StringLength(20)]
        public string ma_phieu { get; set; }

        public long khach_hang_id { get; set; }

        public int xe_id { get; set; }

        public int nhan_vien_id { get; set; }

        [Column(TypeName = "datetime2")]
        public DateTime thoi_diem_nhan { get; set; }

        [Column(TypeName = "datetime2")]
        public DateTime thoi_diem_hen_tra { get; set; }

        public short so_ngay_thue { get; set; }

        public int so_km_nhan { get; set; }

        public decimal? tinh_trang_pin_nhan { get; set; }

        public decimal don_gia_ngay { get; set; }

        public int? km_toi_da_moi_ngay { get; set; }

        public decimal? phi_vuot_km { get; set; }

        public decimal phi_tre_gio { get; set; }

        public decimal tien_coc { get; set; }

        public decimal phan_tram_giam { get; set; }

        [Required]
        [StringLength(15)]
        public string trang_thai { get; set; }

        public string ghi_chu { get; set; }

        [Column(TypeName = "datetime2")]
        public DateTime ngay_tao { get; set; }

        public virtual khach_hang khach_hang { get; set; }

        public virtual nhan_vien nhan_vien { get; set; }

        public virtual xe xe { get; set; }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<thanh_toan> thanh_toan { get; set; }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<tra_xe> tra_xe { get; set; }
    }
}
