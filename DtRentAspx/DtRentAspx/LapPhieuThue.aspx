<%@ Page Title="Lập phiếu thuê" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="LapPhieuThue.aspx.cs" Inherits="DtRentAspx.LapPhieuThue" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
 
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
 
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a runat="server" href="~/Default.aspx">Trang chủ</a></li>
            <li class="breadcrumb-item active" aria-current="page">Lập phiếu thuê</li>
        </ol>
    </nav>
    <h1 class="h3 fw-bold mb-4">Lập phiếu thuê xe</h1>
 
    <asp:UpdatePanel ID="upLap" runat="server">
        <ContentTemplate>
 
            <%-- ============ THÔNG BÁO LỖI ============ --%>
            <asp:Panel ID="pnlLoi" runat="server" Visible="false" CssClass="alert alert-danger" role="alert">
                <asp:Repeater ID="rpLoi" runat="server" ItemType="System.String">
                    <HeaderTemplate><ul class="mb-0"></HeaderTemplate>
                    <ItemTemplate><li><%#: Item %></li></ItemTemplate>
                    <FooterTemplate></ul></FooterTemplate>
                </asp:Repeater>
            </asp:Panel>
 
            <%-- ============ BIỂU MẪU LẬP PHIẾU ============ --%>
            <asp:Panel ID="pnlForm" runat="server">
                <div class="row g-4">
 
                    <%-- ---------- Cột trái: nhập liệu ---------- --%>
                    <div class="col-lg-7">
 
                        <div class="card dt-card mb-4">
                            <div class="card-header">1. Khách hàng và xe</div>
                            <div class="card-body">
                                <div class="mb-3">
                                    <asp:Label runat="server" AssociatedControlID="ddlKhach" CssClass="form-label fw-semibold">Khách hàng</asp:Label>
                                    <asp:DropDownList ID="ddlKhach" runat="server" CssClass="form-select"
                                                      AutoPostBack="true" OnSelectedIndexChanged="ThayDoi" />
                                </div>
                                <div>
                                    <asp:Label runat="server" AssociatedControlID="ddlXe" CssClass="form-label fw-semibold">Xe thuê (chỉ hiện xe sẵn sàng)</asp:Label>
                                    <asp:DropDownList ID="ddlXe" runat="server" CssClass="form-select"
                                                      AutoPostBack="true" OnSelectedIndexChanged="ThayDoi" />
                                </div>
                            </div>
                        </div>
 
                        <div class="card dt-card mb-4">
                            <div class="card-header">2. Thời gian thuê</div>
                            <div class="card-body">
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <asp:Label runat="server" AssociatedControlID="txtNhan" CssClass="form-label fw-semibold">Nhận xe</asp:Label>
                                        <asp:TextBox ID="txtNhan" runat="server" CssClass="form-control" ReadOnly="true" />
                                        <div class="form-text">Là thời điểm bạn bấm "Lập phiếu thuê" (giao xe ngay tại quầy).</div>
                                    </div>
                                    <div class="col-md-6">
                                        <asp:Label runat="server" AssociatedControlID="txtHenTra" CssClass="form-label fw-semibold">Hẹn trả xe</asp:Label>
                                        <asp:TextBox ID="txtHenTra" runat="server" CssClass="form-control" TextMode="DateTimeLocal"
                                                     AutoPostBack="true" OnTextChanged="ThayDoi" />
                                        <div class="form-text">Mỗi 24 giờ tính 1 ngày, phần lẻ làm tròn lên.</div>
                                    </div>
                                    <div class="col-md-6">
                                        <asp:Label runat="server" AssociatedControlID="ddlNhanVien" CssClass="form-label fw-semibold">Nhân viên lập phiếu</asp:Label>
                                        <asp:DropDownList ID="ddlNhanVien" runat="server" CssClass="form-select" />
                                    </div>
                                    <div class="col-12">
                                        <asp:Label runat="server" AssociatedControlID="txtGhiChu" CssClass="form-label fw-semibold">Ghi chú</asp:Label>
                                        <asp:TextBox ID="txtGhiChu" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2"
                                                     placeholder="Tình trạng xe khi giao, yêu cầu của khách..." />
                                    </div>
                                </div>
                            </div>
                        </div>
 
                        <asp:Panel ID="pnlDatCoc" runat="server" CssClass="card dt-card mb-4">
                            <div class="card-header">3. Đặt cọc</div>
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <span class="fw-semibold">Số tiền cọc</span>
                                    <span class="xe-price"><asp:Label ID="lblCoc" runat="server" /></span>
                                </div>
 
                                <asp:Panel ID="pnlPhuongThuc" runat="server">
                                    <div class="fw-semibold mb-2">Phương thức thanh toán</div>
                                    <asp:RadioButtonList ID="rblPhuongThuc" runat="server" RepeatDirection="Horizontal" RepeatLayout="Flow"
                                                         CssClass="dt-radio mb-3" AutoPostBack="true" OnSelectedIndexChanged="ThayDoi">
                                        <asp:ListItem Value="TIEN_MAT" Selected="True">Tiền mặt</asp:ListItem>
                                        <asp:ListItem Value="CHUYEN_KHOAN">Chuyển khoản</asp:ListItem>
                                        <asp:ListItem Value="VI_DIEN_TU">Ví điện tử</asp:ListItem>
                                    </asp:RadioButtonList>
 
                                    <asp:Panel ID="pnlTienMat" runat="server">
                                        <asp:Label runat="server" AssociatedControlID="txtTienKhachDua" CssClass="form-label">Tiền khách đưa (₫)</asp:Label>
                                        <asp:TextBox ID="txtTienKhachDua" runat="server" CssClass="form-control" placeholder="Ví dụ: 5000000"
                                                     AutoPostBack="true" OnTextChanged="ThayDoi" />
                                        <div class="mt-2"><asp:Label ID="lblTienThoi" runat="server" /></div>
                                    </asp:Panel>
 
                                    <asp:Panel ID="pnlChuyenKhoan" runat="server">
                                        <div class="row g-3">
                                            <div class="col-md-6">
                                                <asp:Label runat="server" AssociatedControlID="txtNganHang" CssClass="form-label">Ngân hàng</asp:Label>
                                                <asp:TextBox ID="txtNganHang" runat="server" CssClass="form-control" placeholder="Vietcombank, MB..." />
                                            </div>
                                            <div class="col-md-6">
                                                <asp:Label runat="server" AssociatedControlID="txtMaGiaoDich" CssClass="form-label">Mã giao dịch</asp:Label>
                                                <asp:TextBox ID="txtMaGiaoDich" runat="server" CssClass="form-control" />
                                            </div>
                                        </div>
                                    </asp:Panel>
 
                                    <asp:Panel ID="pnlViDienTu" runat="server">
                                        <div class="row g-3">
                                            <div class="col-md-6">
                                                <asp:Label runat="server" AssociatedControlID="txtTenVi" CssClass="form-label">Tên ví</asp:Label>
                                                <asp:TextBox ID="txtTenVi" runat="server" CssClass="form-control" placeholder="MoMo, ZaloPay..." />
                                            </div>
                                            <div class="col-md-6">
                                                <asp:Label runat="server" AssociatedControlID="txtSdtVi" CssClass="form-label">Số điện thoại ví</asp:Label>
                                                <asp:TextBox ID="txtSdtVi" runat="server" CssClass="form-control" />
                                            </div>
                                        </div>
                                    </asp:Panel>
                                </asp:Panel>
                            </div>
                        </asp:Panel>
                    </div>
 
                    <%-- ---------- Cột phải: tóm tắt và nút lập phiếu ---------- --%>
                    <div class="col-lg-5">
                        <div class="position-sticky" style="top: 1rem;">
 
                            <asp:FormView ID="fvTamTinh" runat="server" RenderOuterTable="false" EnableViewState="false"
                                          ItemType="DtRentAspx.Models.TamTinhVM">
                                <ItemTemplate>
                                    <div class="card dt-card">
                                        <div class="card-header">Tóm tắt phiếu thuê</div>
                                        <div class="card-body">
 
                                            <div class="small text-muted fw-semibold mb-1">XE</div>
                                            <asp:PlaceHolder runat="server" Visible='<%# Item.CoXe %>'>
                                                <div class="fw-bold"><%#: Item.ten_xe %></div>
                                                <div class="small text-muted mb-3">
                                                    <%#: Item.ten_nhom %> &middot; Biển số <%#: Item.bien_so %> &middot; <%#: Item.km_nhan %> km
                                                    <asp:PlaceHolder runat="server" Visible='<%# Item.CoPin %>'> &middot; Pin <%#: Item.PinText %></asp:PlaceHolder>
                                                </div>
                                            </asp:PlaceHolder>
                                            <asp:PlaceHolder runat="server" Visible='<%# !Item.CoXe %>'>
                                                <div class="text-muted mb-3">Chưa chọn xe.</div>
                                            </asp:PlaceHolder>
 
                                            <div class="small text-muted fw-semibold mb-1">KHÁCH HÀNG</div>
                                            <asp:PlaceHolder runat="server" Visible='<%# Item.CoKhach %>'>
                                                <div class="fw-bold"><%#: Item.ten_khach %></div>
                                                <div class="small text-muted mb-3">
                                                    Hạng thành viên <%#: Item.hang_thanh_vien %> &middot; Giấy phép: <%#: Item.GplxKhachText %>
                                                </div>
                                            </asp:PlaceHolder>
                                            <asp:PlaceHolder runat="server" Visible='<%# !Item.CoKhach %>'>
                                                <div class="text-muted mb-3">Chưa chọn khách hàng.</div>
                                            </asp:PlaceHolder>
 
                                            <div class="small text-muted fw-semibold mb-1">THỜI GIAN</div>
                                            <div class="d-flex justify-content-between"><span>Nhận xe</span><strong><%#: Item.NhanText %></strong></div>
                                            <div class="d-flex justify-content-between"><span>Hẹn trả</span><strong><%#: Item.HenTraText %></strong></div>
                                            <asp:PlaceHolder runat="server" Visible='<%# Item.CoThoiGian %>'>
                                                <div class="d-flex justify-content-between"><span>Số ngày thuê</span><strong><%#: Item.SoNgay %> ngày</strong></div>
                                            </asp:PlaceHolder>
 
                                            <asp:PlaceHolder runat="server" Visible='<%# Item.CoXe && Item.CoThoiGian %>'>
                                                <hr />
                                                <div class="small text-muted fw-semibold mb-1">CHI PHÍ DỰ KIẾN</div>
                                                <div class="d-flex justify-content-between"><span><%#: Item.SoNgay %> ngày &times; <%#: Item.DonGiaText %></span><span><%#: Item.TienThueText %></span></div>
                                                <asp:PlaceHolder runat="server" Visible='<%# Item.CoGiamGia %>'>
                                                    <div class="d-flex justify-content-between text-success"><span><%#: Item.GiamGiaNhan %></span><span><%#: Item.TienGiamText %></span></div>
                                                </asp:PlaceHolder>
                                                <div class="d-flex justify-content-between fw-bold fs-5 mt-1"><span>Tiền thuê tạm tính</span><span><%#: Item.TamTinhText %></span></div>
                                                <div class="d-flex justify-content-between mt-2"><span>Tiền cọc thu khi giao xe</span><strong><%#: Item.TienCocText %></strong></div>
                                                <div class="small text-muted mt-3">
                                                    Giới hạn km: <%#: Item.KmTongText %><br />
                                                    Phí vượt km: <%#: Item.PhiVuotKmText %><br />
                                                    Phí trả xe trễ: <%#: Item.PhiTreText %><br />
                                                    Tiền thuê thực tế được tính khi trả xe.
                                                </div>
                                            </asp:PlaceHolder>
 
                                            <%-- Trạng thái kiểm tra điều kiện --%>
                                            <asp:PlaceHolder runat="server" Visible='<%# Item.CoLoi %>'>
                                                <asp:Repeater runat="server" ItemType="System.String" DataSource='<%# Item.Loi %>'>
                                                    <HeaderTemplate><div class="alert alert-danger small mt-3 mb-0"><ul class="mb-0 ps-3"></HeaderTemplate>
                                                    <ItemTemplate><li><%#: Item %></li></ItemTemplate>
                                                    <FooterTemplate></ul></div></FooterTemplate>
                                                </asp:Repeater>
                                            </asp:PlaceHolder>
                                            <asp:Panel runat="server" CssClass="alert alert-secondary small mt-3 mb-0" Visible='<%# !Item.CoLoi && Item.CoChuaDu %>'>
                                                Còn thiếu: <%#: string.Join("; ", Item.ChuaDu) %>.
                                            </asp:Panel>
                                            <asp:Panel runat="server" CssClass="alert alert-success small mt-3 mb-0" Visible='<%# Item.HopLe %>'>
                                                &#10003; Đủ điều kiện lập phiếu thuê.
                                            </asp:Panel>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:FormView>
 
                            <asp:Button ID="btnLap" runat="server" Text="Lập phiếu thuê" CssClass="btn btn-primary btn-lg w-100 mt-3"
                                        OnClick="btnLap_Click" />
                            <a runat="server" href="~/Default.aspx" class="btn btn-outline-dark w-100 mt-2">Hủy</a>
                        </div>
                    </div>
                </div>
            </asp:Panel>
 
            <%-- ============ THÀNH CÔNG ============ --%>
            <asp:Panel ID="pnlThanhCong" runat="server" Visible="false">
                <div class="card dt-card">
                    <div class="card-header">Đã lập phiếu thuê thành công</div>
                    <div class="card-body p-4">
                        <div class="text-muted small">Mã phiếu</div>
                        <div class="display-6 fw-bold mb-4"><asp:Label ID="lblMaPhieu" runat="server" /></div>
                        <dl class="row xe-spec mb-4">
                            <dt class="col-sm-4">Khách hàng</dt><dd class="col-sm-8"><asp:Label ID="lblKhach" runat="server" /></dd>
                            <dt class="col-sm-4">Xe</dt><dd class="col-sm-8"><asp:Label ID="lblXe" runat="server" /></dd>
                            <dt class="col-sm-4">Nhận xe</dt><dd class="col-sm-8"><asp:Label ID="lblNhan" runat="server" /></dd>
                            <dt class="col-sm-4">Hẹn trả xe</dt><dd class="col-sm-8"><asp:Label ID="lblHenTra" runat="server" /></dd>
                            <dt class="col-sm-4">Tiền cọc đã thu</dt><dd class="col-sm-8"><asp:Label ID="lblCocDaThu" runat="server" /></dd>
                        </dl>
                        <a runat="server" href="~/LapPhieuThue.aspx" class="btn btn-primary me-2">Lập phiếu mới</a>
                        <a runat="server" href="~/Default.aspx" class="btn btn-outline-dark">Về trang chủ</a>
                    </div>
                </div>
            </asp:Panel>
 
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
