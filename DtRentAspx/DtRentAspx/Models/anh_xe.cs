namespace DtRentAspx.Models
{
    using System;
    using System.Collections.Generic;
    using System.ComponentModel.DataAnnotations;
    using System.ComponentModel.DataAnnotations.Schema;
    using System.Data.Entity.Spatial;

    public partial class anh_xe
    {
        public int id { get; set; }

        public int xe_id { get; set; }

        [Required]
        [StringLength(500)]
        public string duong_dan { get; set; }

        public bool la_anh_chinh { get; set; }

        public virtual xe xe { get; set; }
    }
}
