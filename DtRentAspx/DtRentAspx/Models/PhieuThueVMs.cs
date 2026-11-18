using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Globalization;

namespace DtRentAspx.Models
{
    public class YeuCauLapPhieu
    {
        public long? KhachId { get; set; }
        public int? XeId { get; set; }
        public int? NhanVienId { get; set; }
        public DateTime? HenTra { get; set; }
        public string GhiChu { get; set; }

        // Đặt cọc
        public string PhuongThuc { get; set; }          // TIEN_MAT | CHUYEN_KHOAN | VI_DIEN_TU
        public decimal? TienKhachDua { get; set; }      // tiền mặt
        public string NganHang { get; set; }            // chuyển khoản
        public string MaGiaoDich { get; set; }
        public string TenVi { get; set; }               // ví điện tử
        public string SoDienThoaiVi { get; set; }
    }

    /// <summary>Kết quả tạm tính và kiểm tra điều kiện (hiển thị ở khung "Tóm tắt phiếu thuê").</summary>
    public class TamTinhVM
    {
        private static readonly CultureInfo Vi = new CultureInfo("vi-VN");

        public bool CoXe { get; set; }
        public bool CoKhach { get; set; }
        public bool CoThoiGian { get; set; }
        public bool HopLe { get; set; }
        public List<string> Loi { get; set; }           // vi phạm điều kiện (màu đỏ)
        public List<string> ChuaDu { get; set; }        // còn thiếu thông tin (màu xám)

        // Xe
        public int XeId { get; set; }
        public string ten_xe { get; set; }
        public string bien_so { get; set; }
        public string ten_nhom { get; set; }
        public int km_nhan { get; set; }
        public decimal? pin_nhan { get; set; }
        public List<string> GplxYeuCau { get; set; }

        // Khách
        public long KhachId { get; set; }
        public string ten_khach { get; set; }
        public string hang_thanh_vien { get; set; }
        public List<string> GplxKhach { get; set; }

        // Thời gian
        public DateTime Nhan { get; set; }
        public DateTime? HenTra { get; set; }
        public int SoNgay { get; set; }

        // Tiền
        public decimal don_gia_ngay { get; set; }
        public decimal phan_tram_giam { get; set; }
        public decimal tien_thue { get; set; }
        public decimal tien_giam { get; set; }
        public decimal tam_tinh { get; set; }
        public decimal tien_coc { get; set; }
        public int? km_toi_da_moi_ngay { get; set; }
        public int? km_toi_da_tong { get; set; }
        public decimal? phi_vuot_km { get; set; }
        public decimal phi_tre_gio { get; set; }

        // ----- hiển thị -----
        public string DonGiaText { get { return Tien(don_gia_ngay); } }
        public string TienThueText { get { return Tien(tien_thue); } }
        public string TienGiamText { get { return "- " + Tien(tien_giam); } }
        public string TamTinhText { get { return Tien(tam_tinh); } }
        public string TienCocText { get { return Tien(tien_coc); } }
        public string PhiTreText { get { return Tien(phi_tre_gio) + " / giờ"; } }
        public string PhiVuotKmText { get { return phi_vuot_km.HasValue ? Tien(phi_vuot_km.Value) + " / km" : "Không áp dụng"; } }
        public string KmTongText
        {
            get { return km_toi_da_tong.HasValue ? km_toi_da_tong.Value.ToString("N0", Vi) + " km" : "Không giới hạn"; }
        }
        public string NhanText { get { return Nhan.ToString("dd/MM/yyyy HH:mm"); } }
        public string HenTraText { get { return HenTra.HasValue ? HenTra.Value.ToString("dd/MM/yyyy HH:mm") : "Chưa chọn"; } }
        public string GplxYeuCauText { get { return GplxYeuCau != null && GplxYeuCau.Count > 0 ? string.Join(", ", GplxYeuCau) : "Không yêu cầu"; } }
        public string GplxKhachText { get { return GplxKhach != null && GplxKhach.Count > 0 ? string.Join(", ", GplxKhach) : "Chưa có"; } }
        public string PinText { get { return pin_nhan.HasValue ? pin_nhan.Value.ToString("0.##", Vi) + "%" : ""; } }
        public bool CoPin { get { return pin_nhan.HasValue; } }
        public bool CoLoi { get { return Loi != null && Loi.Count > 0; } }
        public bool CoChuaDu { get { return ChuaDu != null && ChuaDu.Count > 0; } }
        public bool CoGiamGia { get { return phan_tram_giam > 0; } }
        public string GiamGiaNhan { get { return "Giảm giá hạng " + hang_thanh_vien + " (" + phan_tram_giam.ToString("0.##", Vi) + "%)"; } }

        private static string Tien(decimal v) { return v.ToString("N0", Vi) + " ₫"; }
    }

    /// <summary>Kết quả của thao tác lập phiếu.</summary>
    public class KetQuaLapPhieu
    {
        public bool ThanhCong { get; set; }
        public List<string> Loi { get; set; }
        public long PhieuId { get; set; }
        public string MaPhieu { get; set; }
        public string KhachText { get; set; }
        public string XeText { get; set; }
        public string NhanText { get; set; }
        public string HenTraText { get; set; }
        public string TienCocText { get; set; }
    }
}