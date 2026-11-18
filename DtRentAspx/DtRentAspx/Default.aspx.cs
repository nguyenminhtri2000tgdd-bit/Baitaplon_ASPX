using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DtRentAspx.Models;
using System.Web.ModelBinding;

namespace DtRentAspx
{
    public partial class Default : System.Web.UI.Page
    {
        private const int SoXeMoiTrang = 5;
        private readonly DtRentContext db = new DtRentContext();
        protected void Page_Load(object sender, EventArgs e)
        {
           
        }
        protected void Page_Unload(object sender, EventArgs e)
        {
            db.Dispose();
        }

        // Đổ danh sách nhóm xe vào ô lọc
        public IQueryable<nhom_xe> GetNhomXe()
        {
            return db.nhom_xe.OrderBy(n => n.ten);
        }

        // Lấy danh sách xe theo bộ lọc, đã sắp xếp và phân trang.
        // Các tham số có [Control(...)] tự lấy giá trị từ các ô lọc trên trang.
        public IEnumerable<XeNoiBatVM> GetXeNoiBat(
            int maximumRows, int startRowIndex, out int totalRowCount,
            [Control("txtTuKhoa")] string tuKhoa,
            [Control("ddlSapXep")] string sapXep,
            [Control("ddlNhomXe")] int nhomXeId,
            [Control("ddlNhienLieu")] string nhienLieu,
            [Control("chkSanSang")] bool chiSanSang)
        {
            IQueryable<xe> q = db.xes;

            // ----- Lọc -----
            tuKhoa = (tuKhoa ?? "").Trim();
            if (tuKhoa.Length > 0)
            {
                q = q.Where(x => x.hang_san_xuat.Contains(tuKhoa)
                              || x.dong_xe.Contains(tuKhoa)
                              || x.bien_so.Contains(tuKhoa));
            }
            if (nhomXeId > 0)
            {
                short maNhom = (short)nhomXeId;
                q = q.Where(x => x.nhom_xe_id == maNhom);
            }
            if (!string.IsNullOrEmpty(nhienLieu))
            {
                q = q.Where(x => x.nhom_xe.loai_nhien_lieu == nhienLieu);
            }
            if (chiSanSang)
            {
                q = q.Where(x => x.trang_thai == "SAN_SANG");
            }

            // ----- Chuyển sang đối tượng hiển thị -----
            var rows = q.Select(x => new XeNoiBatVM
            {
                id = x.id,
                ten_xe = x.hang_san_xuat + " " + x.dong_xe,
                nam_san_xuat = x.nam_san_xuat,
                bien_so = x.bien_so,
                ten_nhom = x.nhom_xe.ten,
                so_cho = x.nhom_xe.so_cho,
                loai_nhien_lieu = x.nhom_xe.loai_nhien_lieu,
                gia_thue_ngay = x.nhom_xe.gia_thue_ngay,
                km_toi_da_moi_ngay = x.nhom_xe.km_toi_da_moi_ngay,
                so_km_hien_tai = x.so_km_hien_tai,
                trang_thai = x.trang_thai,
                duong_dan_anh = x.anh_xe
                                 .OrderByDescending(a => a.la_anh_chinh)
                                 .Select(a => a.duong_dan)
                                 .FirstOrDefault(),
                luot_thue = x.phieu_thue.Count(p => p.trang_thai != "DA_HUY")
            });

            // ----- Sắp xếp (luôn thêm id để thứ tự ổn định khi phân trang) -----
            switch (sapXep)
            {
                case "gia_giam":
                    rows = rows.OrderByDescending(v => v.gia_thue_ngay).ThenBy(v => v.id); break;
                case "gia_tang":
                    rows = rows.OrderBy(v => v.gia_thue_ngay).ThenBy(v => v.id); break;
                case "moi_nhat":
                    rows = rows.OrderByDescending(v => v.nam_san_xuat).ThenBy(v => v.id); break;
                case "it_km":
                    rows = rows.OrderBy(v => v.so_km_hien_tai).ThenBy(v => v.id); break;
                default: // thue_nhieu
                    rows = rows.OrderByDescending(v => v.luot_thue).ThenBy(v => v.id); break;
            }

            // ----- Phân trang -----
            totalRowCount = rows.Count();
            lblKetQua.Text = "Tìm thấy " + totalRowCount + " xe";
            return rows.Skip(startRowIndex).Take(maximumRows).ToList();
        }

        // Khi người dùng đổi bộ lọc: quay về trang 1 rồi tải lại danh sách
        protected void LocThayDoi(object sender, EventArgs e)
        {
            dpXe.SetPageProperties(0, SoXeMoiTrang, false);
            lvXe.DataBind();
        }

        protected void btnDatLai_Click(object sender, EventArgs e)
        {
            txtTuKhoa.Text = "";
            ddlSapXep.SelectedIndex = 0;
            ddlNhomXe.SelectedIndex = 0;
            ddlNhienLieu.SelectedIndex = 0;
            chkSanSang.Checked = false;
            LocThayDoi(sender, e);
        }

        // Chỉ hiện thanh phân trang khi có nhiều hơn một trang
        protected void lvXe_DataBound(object sender, EventArgs e)
        {
            bool coNhieuTrang = dpXe.TotalRowCount > SoXeMoiTrang;
            pagerWrap.Attributes["class"] = coNhieuTrang ? "mt-3" : "d-none";
        }

        protected void lvXe_PagePropertiesChanged(object sender, EventArgs e)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "cuonLenDanhSach",
                "document.getElementById('khuDanhSachXe').scrollIntoView({ behavior: 'smooth' });", true);
        }

        protected void lvXe_ItemCommand(object sender, ListViewCommandEventArgs e)
        {
            if (e.CommandName == "XemChiTiet")
            {
                Master.HienChiTietXe(Convert.ToInt32(e.CommandArgument));
            }
        }
    }
}