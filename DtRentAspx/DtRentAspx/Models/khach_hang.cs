namespace DtRentAspx.Models
{
    using System;
    using System.Collections.Generic;
    using System.ComponentModel.DataAnnotations;
    using System.ComponentModel.DataAnnotations.Schema;
    using System.Data.Entity.Spatial;

    public partial class khach_hang
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public khach_hang()
        {
            gplx_khach_hang = new HashSet<gplx_khach_hang>();
            phieu_thue = new HashSet<phieu_thue>();
        }

        public long id { get; set; }

        [Required]
        [StringLength(20)]
        public string ma_khach { get; set; }

        [Required]
        [StringLength(100)]
        public string ho_ten { get; set; }

        [Required]
        [StringLength(10)]
        public string so_dien_thoai { get; set; }

        [StringLength(12)]
        public string so_cccd { get; set; }

        [StringLength(255)]
        public string dia_chi { get; set; }

        public short hang_thanh_vien_id { get; set; }

        [Column(TypeName = "datetime2")]
        public DateTime ngay_tao { get; set; }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<gplx_khach_hang> gplx_khach_hang { get; set; }

        public virtual hang_thanh_vien hang_thanh_vien { get; set; }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<phieu_thue> phieu_thue { get; set; }
    }
}
