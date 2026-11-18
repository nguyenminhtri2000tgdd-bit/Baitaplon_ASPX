using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web.UI.WebControls;
using DtRentAspx.BLL;
using DtRentAspx.Models;

namespace DtRentAspx
{
    public partial class LapPhieuThue : System.Web.UI.Page
    {
        private readonly DtRentContext db = new DtRentContext();
        private static readonly CultureInfo Vi = new CultureInfo("vi-VN");

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            NapKhach();
            NapXe();
            NapNhanVien();
            txtHenTra.Text = DateTime.Now.AddDays(1).ToString("yyyy-MM-ddTHH:mm", CultureInfo.InvariantCulture);
            ChonXeTuDuongDan();
            CapNhat();
        }

        protected void Page_Unload(object sender, EventArgs e)
        {
            db.Dispose();
        }

        // ============================ NẠP DANH SÁCH ============================
        private void NapKhach()
        {
            ddlKhach.Items.Clear();
            ddlKhach.Items.Add(new ListItem("-- Chọn khách hàng --", ""));
            var ds = db.khach_hang.OrderBy(k => k.ma_khach)
                       .Select(k => new { k.id, k.ma_khach, k.ho_ten, k.so_dien_thoai }).ToList();
            foreach (var k in ds)
            {
                ddlKhach.Items.Add(new ListItem(k.ma_khach + " \u2013 " + k.ho_ten + " \u2013 " + k.so_dien_thoai, k.id.ToString()));
            }
        }

        // Chỉ liệt kê xe đang SẴN SÀNG
        private void NapXe()
        {
            string dangChon = ddlXe.SelectedValue;
            ddlXe.Items.Clear();
            ddlXe.Items.Add(new ListItem("-- Chọn xe --", ""));
            var ds = db.xes.Where(x => x.trang_thai == "SAN_SANG")
                       .OrderBy(x => x.hang_san_xuat).ThenBy(x => x.dong_xe)
                       .Select(x => new { x.id, x.hang_san_xuat, x.dong_xe, x.bien_so, gia = x.nhom_xe.gia_thue_ngay })
                       .ToList();
            foreach (var x in ds)
            {
                string chu = x.hang_san_xuat + " " + x.dong_xe + " \u2013 " + x.bien_so
                             + " (" + x.gia.ToString("N0", Vi) + " \u20AB/ngày)";
                ddlXe.Items.Add(new ListItem(chu, x.id.ToString()));
            }
            if (ddlXe.Items.FindByValue(dangChon) != null) ddlXe.SelectedValue = dangChon;
        }

        private void NapNhanVien()
        {
            ddlNhanVien.Items.Clear();
            ddlNhanVien.Items.Add(new ListItem("-- Chọn nhân viên --", ""));
            var ds = db.nhan_vien.Where(n => n.dang_hoat_dong).OrderBy(n => n.ma_nhan_vien)
                       .Select(n => new { n.id, n.ma_nhan_vien, n.ho_ten }).ToList();
            foreach (var n in ds)
            {
                ddlNhanVien.Items.Add(new ListItem(n.ma_nhan_vien + " \u2013 " + n.ho_ten, n.id.ToString()));
            }
            if (ddlNhanVien.Items.Count > 1) ddlNhanVien.SelectedIndex = 1;   // tạm chọn sẵn nhân viên đầu tiên
        }

        // Mở từ nút "Thuê xe": LapPhieuThue.aspx?xe=5
        private void ChonXeTuDuongDan()
        {
            int maXe;
            if (!int.TryParse(Request.QueryString["xe"], out maXe)) return;

            ListItem muc = ddlXe.Items.FindByValue(maXe.ToString());
            if (muc != null) ddlXe.SelectedValue = muc.Value;
            else HienLoi(new List<string> { "Xe bạn chọn hiện không sẵn sàng để thuê. Vui lòng chọn xe khác." }, "alert alert-warning");
        }

        // ============================ SỰ KIỆN ============================
        // Dùng chung: đổi khách, xe, hạn trả, phương thức đặt cọc, tiền khách đưa
        protected void ThayDoi(object sender, EventArgs e)
        {
            pnlLoi.Visible = false;
            CapNhat();
        }

        protected void btnLap_Click(object sender, EventArgs e)
        {
            YeuCauLapPhieu yc = DocYeuCau();
            KetQuaLapPhieu kq = PhieuThueService.Lap(db, yc);

            if (kq.ThanhCong)
            {
                pnlForm.Visible = false;
                pnlLoi.Visible = false;
                pnlThanhCong.Visible = true;
                lblMaPhieu.Text = kq.MaPhieu;
                lblKhach.Text = kq.KhachText;
                lblXe.Text = kq.XeText;
                lblNhan.Text = kq.NhanText;
                lblHenTra.Text = kq.HenTraText;
                lblCocDaThu.Text = kq.TienCocText;
                return;
            }

            NapXe();            // xe có thể vừa bị thuê, làm mới danh sách
            CapNhat();
            HienLoi(kq.Loi, "alert alert-danger");
        }

        // ============================ HỖ TRỢ ============================
        private void CapNhat()
        {
            YeuCauLapPhieu yc = DocYeuCau();
            DateTime bayGio = DateTime.Now;
            TamTinhVM tt = PhieuThueService.TamTinh(db, yc.KhachId, yc.XeId, bayGio, yc.HenTra);

            fvTamTinh.DataSource = new List<TamTinhVM> { tt };
            fvTamTinh.DataBind();

            txtNhan.Text = bayGio.ToString("dd/MM/yyyy HH:mm");
            btnLap.Enabled = tt.HopLe;

            // Khu đặt cọc
            bool canCoc = tt.CoXe && tt.tien_coc > 0;
            pnlDatCoc.Visible = true;
            lblCoc.Text = !tt.CoXe ? "Chọn xe để biết số tiền cọc" : (tt.tien_coc > 0 ? tt.TienCocText : "Không yêu cầu đặt cọc");
            pnlPhuongThuc.Visible = canCoc;

            string pt = rblPhuongThuc.SelectedValue;
            pnlTienMat.Visible = canCoc && pt == "TIEN_MAT";
            pnlChuyenKhoan.Visible = canCoc && pt == "CHUYEN_KHOAN";
            pnlViDienTu.Visible = canCoc && pt == "VI_DIEN_TU";

            lblTienThoi.Text = "";
            if (pnlTienMat.Visible && yc.TienKhachDua.HasValue)
            {
                decimal chenh = yc.TienKhachDua.Value - tt.tien_coc;
                lblTienThoi.Text = chenh >= 0
                    ? "Tiền thối lại khách: " + chenh.ToString("N0", Vi) + " \u20AB"
                    : "Còn thiếu: " + (-chenh).ToString("N0", Vi) + " \u20AB";
                lblTienThoi.CssClass = chenh >= 0 ? "small fw-semibold text-success" : "small fw-semibold text-danger";
            }
        }

        private YeuCauLapPhieu DocYeuCau()
        {
            var yc = new YeuCauLapPhieu();

            long khach;
            if (long.TryParse(ddlKhach.SelectedValue, out khach)) yc.KhachId = khach;
            int maXe;
            if (int.TryParse(ddlXe.SelectedValue, out maXe)) yc.XeId = maXe;
            int nv;
            if (int.TryParse(ddlNhanVien.SelectedValue, out nv)) yc.NhanVienId = nv;

            DateTime han;
            if (DateTime.TryParse(txtHenTra.Text, CultureInfo.InvariantCulture, DateTimeStyles.None, out han)) yc.HenTra = han;

            yc.GhiChu = txtGhiChu.Text;
            yc.PhuongThuc = rblPhuongThuc.SelectedValue;
            yc.TienKhachDua = DocTien(txtTienKhachDua.Text);
            yc.NganHang = txtNganHang.Text;
            yc.MaGiaoDich = txtMaGiaoDich.Text;
            yc.TenVi = txtTenVi.Text;
            yc.SoDienThoaiVi = txtSdtVi.Text;
            return yc;
        }

        // Nhận "5.000.000", "5,000,000" hoặc "5000000"
        private static decimal? DocTien(string chu)
        {
            if (string.IsNullOrWhiteSpace(chu)) return null;
            string so = new string(chu.Where(c => char.IsDigit(c)).ToArray());
            decimal v;
            return decimal.TryParse(so, NumberStyles.None, CultureInfo.InvariantCulture, out v) ? (decimal?)v : null;
        }

        private void HienLoi(List<string> ds, string css)
        {
            rpLoi.DataSource = ds;
            rpLoi.DataBind();
            pnlLoi.CssClass = css;
            pnlLoi.Visible = ds != null && ds.Count > 0;
        }
    }
}