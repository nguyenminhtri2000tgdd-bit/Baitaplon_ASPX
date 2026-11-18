<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="KiemTraKetNoi.aspx.cs" Inherits="DtRentAspx.KiemTraKetNoi" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<link href="Content/bootstrap.min.css" rel="stylesheet" />
<body>
    <form id="form1" runat="server">
        <div>
        </div>
        <asp:GridView ID="gvXe" runat="server" AutoGenerateColumns="False" CssClass="table table-striped table-hover" ItemType="DtRentAspx.Models.xe" SelectMethod="GetXe">
             <Columns>
                <asp:BoundField DataField="id" HeaderText="ID" />
                <asp:BoundField DataField="ma_xe" HeaderText="Mã xe" />
                <asp:BoundField DataField="bien_so" HeaderText="Biển số" />
                <asp:BoundField DataField="hang_san_xuat" HeaderText="Hãng" />
                <asp:BoundField DataField="dong_xe" HeaderText="Dòng xe" />
                <asp:TemplateField HeaderText="Nhóm xe">
                    <ItemTemplate><%#: Item.nhom_xe.ten %></ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="trang_thai" HeaderText="Trạng thái" />
            </Columns>
        </asp:GridView>
    </form>
</body>
</html>
