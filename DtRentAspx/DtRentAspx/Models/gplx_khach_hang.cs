namespace DtRentAspx.Models
{
    using System;
    using System.Collections.Generic;
    using System.ComponentModel.DataAnnotations;
    using System.ComponentModel.DataAnnotations.Schema;
    using System.Data.Entity.Spatial;

    public partial class gplx_khach_hang
    {
        [Key]
        [Column(Order = 0)]
        [DatabaseGenerated(DatabaseGeneratedOption.None)]
        public long khach_hang_id { get; set; }

        [Key]
        [Column(Order = 1)]
        [StringLength(10)]
        public string hang_gplx_ma { get; set; }

        [Required]
        [StringLength(20)]
        public string so_gplx { get; set; }

        [Column(TypeName = "date")]
        public DateTime? ngay_het_han { get; set; }

        public virtual hang_gplx hang_gplx { get; set; }

        public virtual khach_hang khach_hang { get; set; }
    }
}
