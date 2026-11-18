using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Web.Script.Serialization;
using DtRentAspx.Models;

namespace DtRentAspx.BLL
{
    /// <summary>Nghiệp vụ lập phiếu thuê: kiểm tra điều kiện, tính tiền, lưu phiếu và đặt cọc.</summary>
    public static class PhieuThueService
    {
        private static readonly CultureInfo Vi = new CultureInfo("vi-VN");

        /// <summary>Quy ước: mỗi 24 giờ tính 1 ngày, phần lẻ làm tròn lên, tối thiểu 1 ngày.</summary>
        public static int TinhSoNgay(DateTime nhan, DateTime henTra)
        {
            int ngay = (int)Math.Ceiling((henTra - nhan).TotalHours / 24.0);
            return ngay < 1 ? 1 : ngay;
        }

        // =====================================================================
        //  TẠM TÍNH + KIỂM TRA ĐIỀU KIỆN
        // =====================================================================
        public static TamTinhVM TamTinh(DtRentContext db, long? khachId, int? xeId, DateTime nhan, DateTime? henTra)
        {
            var kq = new TamTinhVM
            {
                Nhan = nhan,
                HenTra = henTra,
                Loi = new List<string>(),
                ChuaDu = new List<string>(),
                GplxYeuCau = new List<string>(),
                GplxKhach = new List<string>()
            };

            // ----- Xe -----
            xe x = null;
            if (xeId.HasValue)
            {
                int maXe = xeId.Value;
                x = db.xes.FirstOrDefault(e => e.id == maXe);
            }
            if (x == null) kq.ChuaDu.Add("Chọn xe cần thuê");

            if (x != null)
            {
                var nhom = x.nhom_xe;
                kq.CoXe = true;
                kq.XeId = x.id;
                kq.ten_xe = x.hang_san_xuat + " " + x.dong_xe;
                kq.bien_so = x.bien_so;
                kq.ten_nhom = nhom.ten;
                kq.km_nhan = x.so_km_hien_tai;
                kq.pin_nhan = nhom.loai_nhien_lieu == "DIEN" ? x.tinh_trang_pin : null;
                kq.don_gia_ngay = nhom.gia_thue_ngay;
                kq.tien_coc = nhom.tien_coc;
                kq.km_toi_da_moi_ngay = nhom.km_toi_da_moi_ngay;
                kq.phi_vuot_km = nhom.phi_vuot_km;
                kq.phi_tre_gio = nhom.phi_tre_gio;
                kq.GplxYeuCau = nhom.hang_gplx.Select(h => h.ma).OrderBy(m => m).ToList();

                if (x.trang_thai == "DANG_BAO_TRI") kq.Loi.Add("Xe đang bảo trì, không thể cho thuê.");
                else if (x.trang_thai != "SAN_SANG") kq.Loi.Add("Xe hiện không sẵn sàng (đang được cho thuê).");
            }

            // ----- Khách hàng -----
            khach_hang k = null;
            if (khachId.HasValue)
            {
                long maKhach = khachId.Value;
                k = db.khach_hang.FirstOrDefault(e => e.id == maKhach);
            }
            if (k == null) kq.ChuaDu.Add("Chọn khách hàng");

            if (k != null)
            {
                long kid = k.id;
                kq.CoKhach = true;
                kq.KhachId = kid;
                kq.ten_khach = k.ho_ten;
                var hang = db.hang_thanh_vien.Find(k.hang_thanh_vien_id);
                if (hang != null)
                {
                    kq.hang_thanh_vien = hang.ten;
                    kq.phan_tram_giam = hang.phan_tram_giam;
                }
                kq.GplxKhach = db.gplx_khach_hang.Where(g => g.khach_hang_id == kid)
                                 .Select(g => g.hang_gplx_ma).OrderBy(m => m).ToList();
            }

            // ----- Thời gian -----
            if (!henTra.HasValue)
            {
                kq.ChuaDu.Add("Chọn thời điểm hẹn trả xe");
            }
            else if (henTra.Value <= nhan)
            {
                kq.Loi.Add("Thời điểm hẹn trả phải sau thời điểm nhận xe.");
            }
            else
            {
                kq.CoThoiGian = true;
                kq.SoNgay = TinhSoNgay(nhan, henTra.Value);
            }

            // ----- Giấy phép lái xe -----
            if (x != null && k != null && kq.GplxYeuCau.Count > 0)
            {
                long kid2 = k.id;
                DateTime han = (henTra.HasValue ? henTra.Value : nhan).Date;
                List<string> yeuCau = kq.GplxYeuCau;
                bool coGplx = db.gplx_khach_hang.Any(g => g.khach_hang_id == kid2
                                                          && yeuCau.Contains(g.hang_gplx_ma)
                                                          && (g.ngay_het_han == null || g.ngay_het_han >= han));
                if (!coGplx)
                {
                    kq.Loi.Add("Khách chưa có giấy phép lái xe phù hợp còn hạn (cần một trong các hạng: "
                               + string.Join(", ", kq.GplxYeuCau) + ").");
                }
            }

            // ----- Trùng lịch thuê -----
            if (x != null && kq.CoThoiGian)
            {
                int xid = x.id;
                DateTime hen = henTra.Value;
                bool trung = db.phieu_thue.Any(p => p.xe_id == xid && p.trang_thai == "DANG_THUE"
                                                    && p.thoi_diem_nhan < hen && nhan < p.thoi_diem_hen_tra);
                if (trung) kq.Loi.Add("Xe đã có phiếu thuê trùng thời gian này.");
            }

            // ----- Tiền -----
            if (kq.CoXe && kq.CoThoiGian)
            {
                kq.tien_thue = kq.don_gia_ngay * kq.SoNgay;
                kq.tien_giam = Math.Round(kq.tien_thue * kq.phan_tram_giam / 100m, 0, MidpointRounding.AwayFromZero);
                kq.tam_tinh = kq.tien_thue - kq.tien_giam;
                if (kq.km_toi_da_moi_ngay.HasValue) kq.km_toi_da_tong = kq.km_toi_da_moi_ngay.Value * kq.SoNgay;
            }

            kq.HopLe = kq.CoXe && kq.CoKhach && kq.CoThoiGian && kq.Loi.Count == 0;
            return kq;
        }

        // =====================================================================
        //  LẬP PHIẾU (một giao dịch: đổi trạng thái xe + tạo phiếu + ghi đặt cọc)
        // =====================================================================
        public static KetQuaLapPhieu Lap(DtRentContext db, YeuCauLapPhieu yc)
        {
            DateTime bayGio = DateTime.Now;
            DateTime nhan = new DateTime(bayGio.Ticks - (bayGio.Ticks % TimeSpan.TicksPerSecond));

            TamTinhVM tt = TamTinh(db, yc.KhachId, yc.XeId, nhan, yc.HenTra);
            var loi = new List<string>();
            loi.AddRange(tt.ChuaDu);
            loi.AddRange(tt.Loi);

            // Nhân viên lập phiếu
            if (!yc.NhanVienId.HasValue) loi.Add("Chọn nhân viên lập phiếu");
            else
            {
                int nv = yc.NhanVienId.Value;
                if (!db.nhan_vien.Any(n => n.id == nv && n.dang_hoat_dong)) loi.Add("Nhân viên lập phiếu không hợp lệ.");
            }

            // Thông tin đặt cọc
            decimal coc = tt.tien_coc;
            if (tt.CoXe && coc > 0)
            {
                switch (yc.PhuongThuc)
                {
                    case "TIEN_MAT":
                        if (!yc.TienKhachDua.HasValue || yc.TienKhachDua.Value < coc)
                            loi.Add("Tiền khách đưa chưa đủ tiền cọc (" + coc.ToString("N0", Vi) + " ₫).");
                        break;
                    case "CHUYEN_KHOAN":
                        if (string.IsNullOrWhiteSpace(yc.NganHang) || string.IsNullOrWhiteSpace(yc.MaGiaoDich))
                            loi.Add("Nhập ngân hàng và mã giao dịch chuyển khoản.");
                        break;
                    case "VI_DIEN_TU":
                        if (string.IsNullOrWhiteSpace(yc.TenVi) || string.IsNullOrWhiteSpace(yc.SoDienThoaiVi))
                            loi.Add("Nhập tên ví và số điện thoại ví điện tử.");
                        break;
                    default:
                        loi.Add("Chọn phương thức đặt cọc.");
                        break;
                }
            }

            if (loi.Count > 0 || !tt.HopLe) return new KetQuaLapPhieu { ThanhCong = false, Loi = loi };

            // ----- Tạo mã phiếu theo dạng PT20261028-143656 (không trùng) -----
            DateTime moc = nhan;
            string maPhieu = "PT" + moc.ToString("yyyyMMdd-HHmmss");
            while (db.phieu_thue.Any(p => p.ma_phieu == maPhieu))
            {
                moc = moc.AddSeconds(1);
                maPhieu = "PT" + moc.ToString("yyyyMMdd-HHmmss");
            }

            int xeId = yc.XeId.Value;

            using (var giaoDich = db.Database.BeginTransaction())
            {
                try
                {
                    // Chỉ đổi được khi xe còn SẵN SÀNG: chặn hai người cùng thuê một xe
                    int daDoi = db.Database.ExecuteSqlCommand(
                        "UPDATE xe SET trang_thai = 'DANG_CHO_THUE' WHERE id = @p0 AND trang_thai = 'SAN_SANG'", xeId);
                    if (daDoi == 0)
                    {
                        giaoDich.Rollback();
                        return Loi("Xe vừa được cho thuê hoặc không còn sẵn sàng. Vui lòng chọn xe khác.");
                    }

                    var phieu = new phieu_thue
                    {
                        ma_phieu = maPhieu,
                        khach_hang_id = tt.KhachId,
                        xe_id = xeId,
                        nhan_vien_id = yc.NhanVienId.Value,
                        thoi_diem_nhan = nhan,
                        thoi_diem_hen_tra = yc.HenTra.Value,
                        so_ngay_thue = (short)tt.SoNgay,
                        so_km_nhan = tt.km_nhan,
                        tinh_trang_pin_nhan = tt.pin_nhan,
                        don_gia_ngay = tt.don_gia_ngay,
                        km_toi_da_moi_ngay = tt.km_toi_da_moi_ngay,
                        phi_vuot_km = tt.phi_vuot_km,
                        phi_tre_gio = tt.phi_tre_gio,
                        tien_coc = tt.tien_coc,
                        phan_tram_giam = tt.phan_tram_giam,
                        trang_thai = "DANG_THUE",
                        ghi_chu = string.IsNullOrWhiteSpace(yc.GhiChu) ? null : yc.GhiChu.Trim(),
                        ngay_tao = bayGio
                    };
                    db.phieu_thue.Add(phieu);
                    db.SaveChanges();

                    if (coc > 0)
                    {
                        db.thanh_toan.Add(new thanh_toan
                        {
                            phieu_thue_id = phieu.id,
                            nhan_vien_id = yc.NhanVienId.Value,
                            loai_giao_dich = "DAT_COC",
                            phuong_thuc = yc.PhuongThuc,
                            so_tien = coc,
                            chi_tiet = TaoChiTiet(yc, coc),
                            thoi_diem = bayGio
                        });
                        db.SaveChanges();
                    }

                    giaoDich.Commit();

                    return new KetQuaLapPhieu
                    {
                        ThanhCong = true,
                        PhieuId = phieu.id,
                        MaPhieu = maPhieu,
                        KhachText = tt.ten_khach,
                        XeText = tt.ten_xe + " (" + tt.bien_so + ")",
                        NhanText = nhan.ToString("dd/MM/yyyy HH:mm"),
                        HenTraText = yc.HenTra.Value.ToString("dd/MM/yyyy HH:mm"),
                        TienCocText = coc.ToString("N0", Vi) + " ₫"
                    };
                }
                catch (Exception ex)
                {
                    try { giaoDich.Rollback(); } catch { /* giao dịch đã bị trigger hủy */ }
                    if (CoLoiTrungLich(ex)) return Loi("Xe đã có phiếu thuê trùng thời gian.");
                    return Loi("Không lưu được phiếu thuê: " + LoiGoc(ex));
                }
            }
        }

        // ---------------------------------------------------------------------
        private static KetQuaLapPhieu Loi(string thongBao)
        {
            return new KetQuaLapPhieu { ThanhCong = false, Loi = new List<string> { thongBao } };
        }

        /// <summary>Chi tiết đặt cọc (cột chi_tiet kiểu JSON, bắt buộc có khóa theo từng phương thức).</summary>
        private static string TaoChiTiet(YeuCauLapPhieu yc, decimal coc)
        {
            var d = new Dictionary<string, object>();
            switch (yc.PhuongThuc)
            {
                case "TIEN_MAT":
                    d["tien_khach_dua"] = yc.TienKhachDua.Value;
                    d["tien_thoi"] = yc.TienKhachDua.Value - coc;
                    break;
                case "CHUYEN_KHOAN":
                    d["ngan_hang"] = yc.NganHang.Trim();
                    d["ma_giao_dich"] = yc.MaGiaoDich.Trim();
                    break;
                case "VI_DIEN_TU":
                    d["ten_vi"] = yc.TenVi.Trim();
                    d["so_dien_thoai"] = yc.SoDienThoaiVi.Trim();
                    break;
            }
            return new JavaScriptSerializer().Serialize(d);
        }

        /// <summary>Trigger chống trùng lịch báo lỗi số 50001.</summary>
        private static bool CoLoiTrungLich(Exception ex)
        {
            for (Exception e = ex; e != null; e = e.InnerException)
            {
                var sql = e as SqlException;
                if (sql == null) continue;
                foreach (SqlError loi in sql.Errors)
                {
                    if (loi.Number == 50001) return true;
                }
            }
            return false;
        }

        private static string LoiGoc(Exception ex)
        {
            while (ex.InnerException != null) ex = ex.InnerException;
            return ex.Message;
        }
    }
}