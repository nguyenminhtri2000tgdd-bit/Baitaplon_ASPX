namespace DtRentAspx.Models
{
    using System;
    using System.Collections.Generic;
    using System.ComponentModel.DataAnnotations;
    using System.ComponentModel.DataAnnotations.Schema;
    using System.Data.Entity.Spatial;

    public partial class nhom_xe
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public nhom_xe()
        {
            xes = new HashSet<xe>();
            hang_gplx = new HashSet<hang_gplx>();
        }

        public short id { get; set; }

        [Required]
        [StringLength(30)]
        public string ma { get; set; }

        [Required]
        [StringLength(100)]
        public string ten { get; set; }

        [Required]
        [StringLength(10)]
        public string loai_nhien_lieu { get; set; }

        public short so_cho { get; set; }

        [Required]
        [StringLength(40)]
        public string chinh_sach_gia { get; set; }

        public decimal gia_thue_ngay { get; set; }

        public int? km_toi_da_moi_ngay { get; set; }

        public decimal? phi_vuot_km { get; set; }

        public decimal phi_tre_gio { get; set; }

        public decimal tien_coc { get; set; }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<xe> xes { get; set; }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<hang_gplx> hang_gplx { get; set; }
    }
}
