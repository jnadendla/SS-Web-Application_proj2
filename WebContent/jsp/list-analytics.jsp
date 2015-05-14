<!-- Put your Project 2 code here -->
<%@page import="java.sql.ResultSet"%>
<%@page
    import="java.util.List"
    import="helpers.*"%>
<%
    List<Sales> sales = AnalyticsHelper.listSales(request);
    List<String> products = AnalyticsHelper.listProductsAlphabetically();
if(!sales.isEmpty() || !products.isEmpty()) {
%>
<table class="table table-striped" align="center">
    <thead>
        <tr align="center">
            <th></th>
            <%
            for(int k=0; k < products.size(); ++k) {
               String product = products.get(k);
            %>
                <th width="50%"><B><%=product %></B></th>
            <%
            }
            %>
        </tr>
        <tr></tr>
        <%
        String currUser = "";
        boolean newrow = false;
        for(int i=0; i < sales.size(); ++i) {
           Sales s = sales.get(i);
           String user = s.getUser();
           double total = s.getPrice();
           String product = s.getProduct();
           if(!currUser.equals(user)) {
              currUser = user;
              newrow = true;
           }   
           if(newrow) {
           %>
               <tr></tr>
               <td><%=user %></td>
           <%
           }
           %>
           <td><%=total %></td>
           <td><%=product %></td>
        <%
           newrow = false;
        }
        %>
    </thead>
</table>
<%
}
%>