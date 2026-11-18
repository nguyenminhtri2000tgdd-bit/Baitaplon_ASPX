using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DtRentAspx.BLL;
using DtRentAspx.Models;

namespace DtRentAspx
{
    public partial class Site : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        /// <summary>
        /// Mở panel chi tiết xe bên phải màn hình.
        /// Trang nào cũng gọi được:  Master.HienChiTietXe(maXe);
        /// </summary>
        public void HienChiTietXe(int maXe)
        {
            var ds = new List<XeChiTietVM>();
            using (var db = new DtRentContext())
            {
                XeChiTietVM vm = XeService.LayChiTiet(db, maXe);
                if (vm != null) ds.Add(vm);
            }

            fvXe.DataSource = ds;       // danh sách rỗng -> FormView hiện thông báo "Không tìm thấy xe"
            fvXe.DataBind();
            upXe.Update();              // đưa panel vào lần cập nhật một phần hiện tại

            ScriptManager.RegisterStartupScript(upXe, upXe.GetType(),
                "moPanelXe", "moOffcanvas('ocXe');", true);
        }
    }
}