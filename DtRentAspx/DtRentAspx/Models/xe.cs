namespace DtRentAspx.Models
{
    using System;
    using System.Collections.Generic;
    using System.ComponentModel.DataAnnotations;
    using System.ComponentModel.DataAnnotations.Schema;
    using System.Data.Entity.Spatial;

    [Table("xe")]
    public partial class xe
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public xe()
        {
            anh_xe = new HashSet<anh_xe>();
            bao_tri = new HashSet<bao_tri>();
            phieu_thue = new HashSet<phieu_thue>();
        }

        public int id { get; set; }

        [Required]
        [StringLength(20)]
        public string ma_xe { get; set; }

        public short nhom_xe_id { get; set; }

        [Required]
        [StringLength(50)]
        public string hang_san_xuat { get; set; }

        [Required]
        [StringLength(50)]
        public string dong_xe { get; set; }

        public short nam_san_xuat { get; set; }

        [Required]
        [StringLength(15)]
        public string bien_so { get; set; }

        [Required]
        [StringLength(20)]
        public string trang_thai { get; set; }

        public int so_km_hien_tai { get; set; }

        public decimal? tinh_trang_pin { get; set; }

        public string ghi_chu { get; set; }

        [Column(TypeName = "datetime2")]
        public DateTime ngay_tao { get; set; }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<anh_xe> anh_xe { get; set; }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<bao_tri> bao_tri { get; set; }

        public virtual nhom_xe nhom_xe { get; set; }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<phieu_thue> phieu_thue { get; set; }
    }
}
