using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System;
using System.Linq;
using DtRentAspx.Models;
namespace DtRentAspx
{
    public partial class KiemTraKetNoi : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        private readonly DtRentContext db = new DtRentContext();

        public IQueryable<xe> GetXe()
        {
            return db.xes.Include("nhom_xe").OrderBy(x => x.id);
        }

        protected void Page_Unload(object sender, EventArgs e)
        {
            db.Dispose();
        }
    }
}