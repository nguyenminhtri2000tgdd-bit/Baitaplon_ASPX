using System;
using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity;
using System.Linq;

namespace DtRentAspx.Models
{
    public partial class DtRentContext : DbContext
    {
        public DtRentContext()
            : base("name=DtRentContext")
        {
            Database.SetInitializer<DtRentContext>(null);
        }

        public virtual DbSet<anh_xe> anh_xe { get; set; }
        public virtual DbSet<bao_tri> bao_tri { get; set; }
        public virtual DbSet<gplx_khach_hang> gplx_khach_hang { get; set; }
        public virtual DbSet<hang_gplx> hang_gplx { get; set; }
        public virtual DbSet<hang_thanh_vien> hang_thanh_vien { get; set; }
        public virtual DbSet<khach_hang> khach_hang { get; set; }
        public virtual DbSet<nhan_vien> nhan_vien { get; set; }
        public virtual DbSet<nhom_xe> nhom_xe { get; set; }
        public virtual DbSet<phieu_thue> phieu_thue { get; set; }
        public virtual DbSet<tai_khoan> tai_khoan { get; set; }
        public virtual DbSet<thanh_toan> thanh_toan { get; set; }
        public virtual DbSet<tra_xe> tra_xe { get; set; }
        public virtual DbSet<xe> xes { get; set; }

        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            modelBuilder.Entity<bao_tri>()
                .Property(e => e.loai)
                .IsUnicode(false);

            modelBuilder.Entity<bao_tri>()
                .Property(e => e.chi_phi)
                .HasPrecision(14, 0);

            modelBuilder.Entity<bao_tri>()
                .Property(e => e.trang_thai)
                .IsUnicode(false);

            modelBuilder.Entity<gplx_khach_hang>()
                .Property(e => e.hang_gplx_ma)
                .IsUnicode(false);

            modelBuilder.Entity<gplx_khach_hang>()
                .Property(e => e.so_gplx)
                .IsUnicode(false);

            modelBuilder.Entity<hang_gplx>()
                .Property(e => e.ma)
                .IsUnicode(false);

            modelBuilder.Entity<hang_gplx>()
                .HasMany(e => e.gplx_khach_hang)
                .WithRequired(e => e.hang_gplx)
                .HasForeignKey(e => e.hang_gplx_ma)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<hang_gplx>()
                .HasMany(e => e.nhom_xe)
                .WithMany(e => e.hang_gplx)
                .Map(m => m.ToTable("nhom_xe_gplx"));

            modelBuilder.Entity<hang_thanh_vien>()
                .Property(e => e.ma)
                .IsUnicode(false);

            modelBuilder.Entity<hang_thanh_vien>()
                .Property(e => e.phan_tram_giam)
                .HasPrecision(5, 2);

            modelBuilder.Entity<hang_thanh_vien>()
                .HasMany(e => e.khach_hang)
                .WithRequired(e => e.hang_thanh_vien)
                .HasForeignKey(e => e.hang_thanh_vien_id)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<khach_hang>()
                .Property(e => e.ma_khach)
                .IsUnicode(false);

            modelBuilder.Entity<khach_hang>()
                .Property(e => e.so_dien_thoai)
                .IsFixedLength()
                .IsUnicode(false);

            modelBuilder.Entity<khach_hang>()
                .Property(e => e.so_cccd)
                .IsUnicode(false);

            modelBuilder.Entity<khach_hang>()
                .Property(e => e.ngay_tao)
                .HasPrecision(0);

            modelBuilder.Entity<khach_hang>()
                .HasMany(e => e.gplx_khach_hang)
                .WithRequired(e => e.khach_hang)
                .HasForeignKey(e => e.khach_hang_id);

            modelBuilder.Entity<khach_hang>()
                .HasMany(e => e.phieu_thue)
                .WithRequired(e => e.khach_hang)
                .HasForeignKey(e => e.khach_hang_id)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<nhan_vien>()
                .Property(e => e.ma_nhan_vien)
                .IsUnicode(false);

            modelBuilder.Entity<nhan_vien>()
                .Property(e => e.so_dien_thoai)
                .IsFixedLength()
                .IsUnicode(false);

            modelBuilder.Entity<nhan_vien>()
                .Property(e => e.ngay_tao)
                .HasPrecision(0);

            modelBuilder.Entity<nhan_vien>()
                .HasMany(e => e.bao_tri)
                .WithRequired(e => e.nhan_vien)
                .HasForeignKey(e => e.nhan_vien_id)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<nhan_vien>()
                .HasMany(e => e.phieu_thue)
                .WithRequired(e => e.nhan_vien)
                .HasForeignKey(e => e.nhan_vien_id)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<nhan_vien>()
                .HasMany(e => e.tai_khoan)
                .WithRequired(e => e.nhan_vien)
                .HasForeignKey(e => e.nhan_vien_id)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<nhan_vien>()
                .HasMany(e => e.thanh_toan)
                .WithRequired(e => e.nhan_vien)
                .HasForeignKey(e => e.nhan_vien_id)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<nhan_vien>()
                .HasMany(e => e.tra_xe)
                .WithRequired(e => e.nhan_vien)
                .HasForeignKey(e => e.nhan_vien_id)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<nhom_xe>()
                .Property(e => e.ma)
                .IsUnicode(false);

            modelBuilder.Entity<nhom_xe>()
                .Property(e => e.loai_nhien_lieu)
                .IsUnicode(false);

            modelBuilder.Entity<nhom_xe>()
                .Property(e => e.chinh_sach_gia)
                .IsUnicode(false);

            modelBuilder.Entity<nhom_xe>()
                .Property(e => e.gia_thue_ngay)
                .HasPrecision(14, 0);

            modelBuilder.Entity<nhom_xe>()
                .Property(e => e.phi_vuot_km)
                .HasPrecision(14, 0);

            modelBuilder.Entity<nhom_xe>()
                .Property(e => e.phi_tre_gio)
                .HasPrecision(14, 0);

            modelBuilder.Entity<nhom_xe>()
                .Property(e => e.tien_coc)
                .HasPrecision(14, 0);

            modelBuilder.Entity<nhom_xe>()
                .HasMany(e => e.xes)
                .WithRequired(e => e.nhom_xe)
                .HasForeignKey(e => e.nhom_xe_id)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<phieu_thue>()
                .Property(e => e.ma_phieu)
                .IsUnicode(false);

            modelBuilder.Entity<phieu_thue>()
                .Property(e => e.thoi_diem_nhan)
                .HasPrecision(0);

            modelBuilder.Entity<phieu_thue>()
                .Property(e => e.thoi_diem_hen_tra)
                .HasPrecision(0);

            modelBuilder.Entity<phieu_thue>()
                .Property(e => e.tinh_trang_pin_nhan)
                .HasPrecision(5, 2);

            modelBuilder.Entity<phieu_thue>()
                .Property(e => e.don_gia_ngay)
                .HasPrecision(14, 0);

            modelBuilder.Entity<phieu_thue>()
                .Property(e => e.phi_vuot_km)
                .HasPrecision(14, 0);

            modelBuilder.Entity<phieu_thue>()
                .Property(e => e.phi_tre_gio)
                .HasPrecision(14, 0);

            modelBuilder.Entity<phieu_thue>()
                .Property(e => e.tien_coc)
                .HasPrecision(14, 0);

            modelBuilder.Entity<phieu_thue>()
                .Property(e => e.phan_tram_giam)
                .HasPrecision(5, 2);

            modelBuilder.Entity<phieu_thue>()
                .Property(e => e.trang_thai)
                .IsUnicode(false);

            modelBuilder.Entity<phieu_thue>()
                .Property(e => e.ngay_tao)
                .HasPrecision(0);

            modelBuilder.Entity<phieu_thue>()
                .HasMany(e => e.thanh_toan)
                .WithRequired(e => e.phieu_thue)
                .HasForeignKey(e => e.phieu_thue_id)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<phieu_thue>()
                .HasMany(e => e.tra_xe)
                .WithRequired(e => e.phieu_thue)
                .HasForeignKey(e => e.phieu_thue_id)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<tai_khoan>()
                .Property(e => e.ten_dang_nhap)
                .IsUnicode(false);

            modelBuilder.Entity<tai_khoan>()
                .Property(e => e.vai_tro)
                .IsUnicode(false);

            modelBuilder.Entity<tai_khoan>()
                .Property(e => e.ngay_tao)
                .HasPrecision(0);

            modelBuilder.Entity<thanh_toan>()
                .Property(e => e.loai_giao_dich)
                .IsUnicode(false);

            modelBuilder.Entity<thanh_toan>()
                .Property(e => e.phuong_thuc)
                .IsUnicode(false);

            modelBuilder.Entity<thanh_toan>()
                .Property(e => e.so_tien)
                .HasPrecision(14, 0);

            modelBuilder.Entity<thanh_toan>()
                .Property(e => e.thoi_diem)
                .HasPrecision(0);

            modelBuilder.Entity<tra_xe>()
                .Property(e => e.thoi_diem_tra_thuc_te)
                .HasPrecision(0);

            modelBuilder.Entity<tra_xe>()
                .Property(e => e.tien_thue)
                .HasPrecision(14, 0);

            modelBuilder.Entity<tra_xe>()
                .Property(e => e.phi_vuot_km)
                .HasPrecision(14, 0);

            modelBuilder.Entity<tra_xe>()
                .Property(e => e.phi_tre)
                .HasPrecision(14, 0);

            modelBuilder.Entity<tra_xe>()
                .Property(e => e.tong_truoc_giam)
                .HasPrecision(14, 0);

            modelBuilder.Entity<tra_xe>()
                .Property(e => e.tien_giam)
                .HasPrecision(14, 0);

            modelBuilder.Entity<tra_xe>()
                .Property(e => e.tong_phai_tra)
                .HasPrecision(14, 0);

            modelBuilder.Entity<tra_xe>()
                .Property(e => e.tinh_trang_pin_tra)
                .HasPrecision(5, 2);

            modelBuilder.Entity<tra_xe>()
                .Property(e => e.ngay_tao)
                .HasPrecision(0);

            modelBuilder.Entity<xe>()
                .Property(e => e.ma_xe)
                .IsUnicode(false);

            modelBuilder.Entity<xe>()
                .Property(e => e.bien_so)
                .IsUnicode(false);

            modelBuilder.Entity<xe>()
                .Property(e => e.trang_thai)
                .IsUnicode(false);

            modelBuilder.Entity<xe>()
                .Property(e => e.tinh_trang_pin)
                .HasPrecision(5, 2);

            modelBuilder.Entity<xe>()
                .Property(e => e.ngay_tao)
                .HasPrecision(0);

            modelBuilder.Entity<xe>()
                .HasMany(e => e.anh_xe)
                .WithRequired(e => e.xe)
                .HasForeignKey(e => e.xe_id);

            modelBuilder.Entity<xe>()
                .HasMany(e => e.bao_tri)
                .WithRequired(e => e.xe)
                .HasForeignKey(e => e.xe_id)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<xe>()
                .HasMany(e => e.phieu_thue)
                .WithRequired(e => e.xe)
                .HasForeignKey(e => e.xe_id)
                .WillCascadeOnDelete(false);
        }
    }
}
