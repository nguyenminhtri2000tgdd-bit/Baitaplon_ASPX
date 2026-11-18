namespace DtRentAspx.Models
{
    using System;
    using System.Collections.Generic;
    using System.ComponentModel.DataAnnotations;
    using System.ComponentModel.DataAnnotations.Schema;
    using System.Data.Entity.Spatial;

    public partial class nhan_vien
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public nhan_vien()
        {
            bao_tri = new HashSet<bao_tri>();
            phieu_thue = new HashSet<phieu_thue>();
            tai_khoan = new HashSet<tai_khoan>();
            thanh_toan = new HashSet<thanh_toan>();
            tra_xe = new HashSet<tra_xe>();
        }

        public int id { get; set; }

        [Required]
        [StringLength(20)]
        public string ma_nhan_vien { get; set; }

        [Required]
        [StringLength(100)]
        public string ho_ten { get; set; }

        [Required]
        [StringLength(10)]
        public string so_dien_thoai { get; set; }

        public bool dang_hoat_dong { get; set; }

        [Column(TypeName = "datetime2")]
        public DateTime ngay_tao { get; set; }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<bao_tri> bao_tri { get; set; }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<phieu_thue> phieu_thue { get; set; }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<tai_khoan> tai_khoan { get; set; }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<thanh_toan> thanh_toan { get; set; }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<tra_xe> tra_xe { get; set; }
    }
}
