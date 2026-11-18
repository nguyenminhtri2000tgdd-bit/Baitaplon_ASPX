namespace DtRentAspx.Models
{
    using System;
    using System.Collections.Generic;
    using System.ComponentModel.DataAnnotations;
    using System.ComponentModel.DataAnnotations.Schema;
    using System.Data.Entity.Spatial;

    public partial class hang_gplx
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public hang_gplx()
        {
            gplx_khach_hang = new HashSet<gplx_khach_hang>();
            nhom_xe = new HashSet<nhom_xe>();
        }

        [Key]
        [StringLength(10)]
        public string ma { get; set; }

        [Required]
        [StringLength(150)]
        public string mo_ta { get; set; }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<gplx_khach_hang> gplx_khach_hang { get; set; }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<nhom_xe> nhom_xe { get; set; }
    }
}
