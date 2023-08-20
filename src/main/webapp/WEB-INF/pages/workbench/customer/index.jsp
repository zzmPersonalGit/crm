<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String url = "" + request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
%>
<html>
<head>
    <base href="<%=url%>">
    <meta charset="UTF-8">

    <link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>
    <link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css"
          rel="stylesheet"/>

    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
    <script type="text/javascript"
            src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

    <!--分页插件的配置-->
    <link rel="stylesheet" type="text/css" href="jquery/bs_pagination-master/css/jquery.bs_pagination.min.css">
    <script type="text/javascript" src="jquery/bs_pagination-master/js/jquery.bs_pagination.min.js"></script>
    <script type="text/javascript" src="jquery/bs_pagination-master/localization/en.js"></script>

    <script type="text/javascript">
        $(function () {

            // TODO 页面窗口加载完毕后,打包数据，发送分页查询的请求
            sendCustomerRequestForPage(1, 10)

            // TODO 点击查询，发送携带查询参数的分页请求
            $("#queryCustomerForPage").click(function () {
                sendCustomerRequestForPage(1, $("#customerDivForPage").bs_pagination('getOption', 'rowsPerPage'));
                $("#allCheckRemark").prop("checked", false)
            })

            // TODO 创建新客户
            $("#saveCustomer").click(function () {
                var name = $("#create-customerName").val();
                var owner = $("#create-customerOwner").val();
                var website = $("#create-website").val();
                var phone = $("#create-phone").val();
                var describe = $("#create-describe").val();
                var contactSummary = $("#create-contactSummary").val();
                var nextContactTime = $("#create-nextContactTime").val();
                var address = $("#create-address").val();

                // 参数校验
                if (name == '') {
                    alert("客户名称不能为空");
                    return;
                }
                if (owner == '') {
                    alert("所有者不能为空");
                    return;
                }
                if (website == '') {
                    alert("公司网站不能为空");
                    return;
                }
                if (phone == '') {
                    alert("公司座机不能为空");
                    return;
                }
                if (!/0\d{2,3}-\d{7,8}/.test(phone)) {
                    alert("座机信息不合法");
                    return;
                }
                if (nextContactTime == '') {
                    alert("下次联系时间不能为空");
                    return;
                }

                // 发送ajax请求
                $.ajax({
                    url: "workbench/customer/saveCustomer",
                    type: "POST",
                    data: {
                        "owner": owner,
                        "name": name,
                        "website": website,
                        "phone": phone,
                        "description": describe,
                        "contactSummary": contactSummary,
                        "nextContactTime": nextContactTime,
                        "address": address
                    },
                    dataType: "json",
                    success: function (data) {
                        if ("0" == data.code) {
                            //创建失败,提示信息创建失败,模态窗口不关闭,真实客户列表也不刷新
                            alert(data.message)
                        } else {
                            //创建成功后，关闭模态窗口,刷新市场活动列
                            $("#createCustomerModal").modal("hide");

                            // 发送分页请求
                            sendCustomerRequestForPage(1, $("#customerDivForPage").bs_pagination('getOption', 'rowsPerPage'))
                            $("#createCustomerForm")[0].reset();
                            $("#allCheckRemark").prop("checked", false)
                        }
                    }
                })
            })

            // TODO 删除客户信息
            $("#deleteCustomerBtn").click(function () {

                var idsCheckbox = $("#customerBodyForPage input[type='checkbox']:checked");
                if (idsCheckbox.size() <= 0) {
                    alert("每次至少删除一条客户信息");
                    return;
                }
                if (!window.confirm("谨慎操作，删除客户会清空该公司下的所有联系人和交易信息")) {
                    return;
                }
                if (!window.confirm("你确定要这样做吗？")) {
                    return;
                }
                var ids = ""
                $.each(idsCheckbox, function () {
                    ids += "id=" + this.value + "&"
                })
                ids = ids.substr(0, ids.length - 1);

                //发送请求
                $.ajax({
                    url: 'workbench/customer/deleteCustomerByIds',
                    type: 'POST',
                    data: ids,
                    dataType: 'json',
                    success: function (data) {
                        if (data.code == 0) {
                            alert(data.message)
                        } else {
                            sendCustomerRequestForPage(1, $("#customerDivForPage").bs_pagination('getOption', 'rowsPerPage'))
                            $("#allCheckRemark").prop("checked", false)
                        }
                    }
                })
            })

            // TODO 客户信息修改前先获取数据并渲染
            $("#editCustomerInformationBtn").click(function () {
                var editCheckbox = $("#customerBodyForPage input[type='checkbox']:checked");
                if (editCheckbox.size() == 0) {
                    alert("你还没有选中要修改的数据")
                    return;
                }
                if (editCheckbox.size() != 1) {
                    alert("每次只能修改一条客户信息")
                    return;
                }
                var id = editCheckbox[0].value;
                $.ajax({
                    url: 'workbench/customer/queryCustomerById',
                    type: 'POST',
                    data: {"id": id},
                    dataType: "json",
                    success: function (data) {
                        //修改文本参数
                        $("#edit-id").val(data.id)
                        $("#edit-customerOwner").val(data.owner)
                        $("#edit-customerName").val(data.name)
                        $("#edit-website").val(data.website)
                        $("#edit-phone").val(data.phone)
                        $("#edit-describe").val(data.description)
                        $("#edit-contactSummary").val(data.contactSummary)
                        $("#edit-nextContactTime").val(data.nextContactTime)
                        $("#edit-address").val(data.address)
                        //打开修改的模块窗口
                        $("#editCustomerModal").modal("show");
                    }
                })
            })

            // TODO 更新客户信息,成功之后关闭模态窗口,然后发送分页请求
            $("#editCustomerBtn").click(function () {
                //获取文本参数
                var id = $("#edit-id").val()
                var owner = $("#edit-customerOwner").val();
                var name = $("#edit-customerName").val();
                var website = $("#edit-website").val();
                var phone = $("#edit-phone").val();
                var describe = $("#edit-describe").val();
                var contactSummary = $("#edit-contactSummary").val();
                var nextContactTime = $("#edit-nextContactTime").val();
                var address = $("#edit-address").val();

                //检验参数是否合法
                if (name == '') {
                    alert("客户名称不能为空");
                    return;
                }
                if (owner == '') {
                    alert("所有者不能为空");
                    return;
                }
                if (website == '') {
                    alert("公司网站不能为空");
                    return;
                }
                if (phone == '') {
                    alert("公司座机不能为空");
                    return;
                }
                if (!/0\d{2,3}-\d{7,8}/.test(phone)) {
                    alert("座机信息不合法");
                    return;
                }
                if (nextContactTime == '') {
                    alert("下次联系时间不能为空");
                    return;
                }

                //发送请求
                $.ajax({
                    url: "workbench/customer/editCustomer",
                    type: "POST",
                    data: {
                        "id": id,
                        "owner": owner,
                        "name": name,
                        "website": website,
                        "phone": phone,
                        "description": describe,
                        "contactSummary": contactSummary,
                        "nextContactTime": nextContactTime,
                        "address": address
                    },
                    dataType: "json",
                    success: function (data) {
                        if (data.code == 0) {
                            alert(data.message)
                        } else {
                            $("#editCustomerModal").modal("hide");
                            sendCustomerRequestForPage(
                                $("#customerDivForPage").bs_pagination('getOption', 'currentPage'),
                                $("#customerDivForPage").bs_pagination('getOption', 'rowsPerPage'))
                            $("#allCheckRemark").prop("checked", false)
                        }
                    }
                })
            })

            // TODO 点击创建按钮弹出模态窗口
            $("#managerModalCreateBtn").click(function () {
                $("#createCustomerModal").modal("show")
            })

            // TODO 给全选的checked框按钮绑定相对应的事件
            $("#allCheckRemark").click(function () {
                $("#customerBodyForPage input[type='checkbox']").prop("checked", this.checked)
            })

            // TODO 给动态生成的checked框绑定单击事件
            $("#customerBodyForPage").on("click", "input[type='checkbox']", function () {
                if ($("#customerBodyForPage input[type='checkbox']").size()
                    == $("#customerBodyForPage input[type='checkbox']:checked").size()) {
                    $("#allCheckRemark").prop("checked", true)
                } else {
                    $("#allCheckRemark").prop("checked", false)
                }
            })

            // TODO 给文本框加上日历插件功能
            $(".datetimepicker-createCustomerFrom").datetimepicker({
                language: 'zh-CN',
                format: 'yyyy-mm-dd',
                minView: 'month',
                initialDate: new Date(),
                autoclose: true,
                todayBtn: true,
                clearBtn: true
            })
        });

        // TODO 发送分页请求
        sendCustomerRequestForPage = function (pageNo, pageSize) {
            var name = $("#clustomerNameForPage").val().trim();
            var owner = $("#customerOwnerForPage").val().trim();
            var phone = $("#clustomerPhoneForPage").val().trim();
            var website = $("#clustomerWebsiteForPage").val().trim();

            $.ajax({
                url: 'workbench/customer/queryByConditionForPage',
                type: 'POST',
                data: {
                    "name": name,
                    "owner": owner,
                    "phone": phone,
                    "website": website,
                    "pageNo": pageNo,
                    "pageSize": pageSize
                },
                dataType: 'json',
                success: function (data) {
                    var htmlStr = "";
                    $.each(data.customers, function (index, item) {
                        htmlStr += "<tr class=\"active\">";
                        htmlStr += "	<td><input type=\"checkbox\" value='" + item.id + "'/></td>";
                        htmlStr += "	<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='workbench/customer/toDetail?id=" + item.id + "';\">" + item.name + "</a></td>";
                        htmlStr += "	<td>" + item.owner + "</td>";
                        htmlStr += "	<td>" + item.phone + "</td>";
                        htmlStr += "	<td>" + item.nextContactTime + "</td>";
                        htmlStr += "	<td>" + item.website + "</td>";
                        htmlStr += "	<td>" + item.address + "</td>";
                        htmlStr += "</tr>";
                    })

                    // 给装分页查询容器值的body赋值
                    $("#customerBodyForPage").html(htmlStr);

                    //计算有多少页
                    var totalPages = 1;
                    if (data.totalRows % pageSize == 0) {
                        totalPages = data.totalRows / pageSize
                    } else {
                        totalPages = parseInt(data.totalRows / pageSize) + 1
                    }

                    //给分页插件准备的容器赋值
                    $("#customerDivForPage").bs_pagination({
                        currentPage: pageNo,
                        rowsPerPage: pageSize,
                        totalPages: totalPages,
                        totalRows: data.totalRows,
                        visiblePageLinks: 5,
                        showGoToPage: true,
                        showRowsPerPage: true,
                        showRowsInfo: true,
                        onChangePage: function (event, pageObj) {
                            sendCustomerRequestForPage(pageObj.currentPage, pageObj.rowsPerPage);
                            $("#allCheckRemark").prop("checked", false);
                        }
                    });
                }
            })
        }
    </script>
</head>
<body>

<!-- 创建客户的模态窗口 -->
<div class="modal fade" id="createCustomerModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel1">创建客户</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form" id="createCustomerForm">

                    <div class="form-group">
                        <!-- 1.1:名称 -->
                        <label for="create-customerName" class="col-sm-2 control-label">客户名称<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-customerName">
                        </div>

                        <!-- 1.2:所有者 -->
                        <label for="create-customerOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-customerOwner">
                                <option></option>
                                <c:forEach items="${userList}" var="user">
                                    <option value="${user.id}">${user.name}</option>
                                </c:forEach>
                            </select>
                        </div>


                    </div>

                    <div class="form-group">
                        <!-- 2.1:公司网站 -->
                        <label for="create-website" class="col-sm-2 control-label">公司网站<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-website">
                        </div>

                        <!-- 2.2:公司座机 -->
                        <label for="create-phone" class="col-sm-2 control-label">公司座机<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-phone">
                        </div>
                    </div>

                    <br/>

                    <div class="form-group">
                        <!-- 3.1:联系纪要 -->
                        <label for="create-contactSummary" class="col-sm-2 control-label">联系纪要&nbsp;</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="create-contactSummary"></textarea>
                        </div>
                    </div>

                    <div class="form-group">
                        <!-- 4.1:描述 -->
                        <label for="create-describe" class="col-sm-2 control-label">客户描述&nbsp;</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="create-describe"></textarea>
                        </div>
                    </div>

                    <div style="position: relative;top: 20px;">
                        <div class="form-group">
                            <!-- 5.1:详细地址 -->
                            <label for="create-address" class="col-sm-2 control-label">详细地址&nbsp;</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="1" id="create-address"></textarea>
                            </div>
                        </div>
                    </div>

                    <br/>
                    <div style="position: relative;top: 15px;">
                        <div class="form-group">
                            <!-- 6.1:下次联系时间 -->
                            <label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间<span
                                    style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control datetimepicker-createCustomerFrom"
                                       id="create-nextContactTime" readonly>
                            </div>
                        </div>
                    </div>


                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="saveCustomer">保存</button>
            </div>
        </div>
    </div>
</div>

<!-- 修改客户的模态窗口 -->
<div class="modal fade" id="editCustomerModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel">修改客户</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form" id="createCustomerForm">
                    <input type="hidden" id="edit-id"/>
                    <div class="form-group">
                        <!-- 1.1:名称 -->
                        <label for="edit-customerName" class="col-sm-2 control-label">客户名称<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-customerName">
                        </div>

                        <!-- 1.2:所有者 -->
                        <label for="edit-customerOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-customerOwner">
                                <option></option>
                                <c:forEach items="${userList}" var="user">
                                    <option value="${user.id}">${user.name}</option>
                                </c:forEach>
                            </select>
                        </div>


                    </div>

                    <div class="form-group">
                        <!-- 2.1:公司网站 -->
                        <label for="edit-website" class="col-sm-2 control-label">公司网站<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-website">
                        </div>

                        <!-- 2.2:公司座机 -->
                        <label for="edit-phone" class="col-sm-2 control-label">公司座机<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-phone">
                        </div>
                    </div>

                    <br/>


                    <div class="form-group">
                        <!-- 3.1:联系纪要 -->
                        <label for="edit-contactSummary" class="col-sm-2 control-label">联系纪要&nbsp;</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="edit-contactSummary"></textarea>
                        </div>
                    </div>

                    <div class="form-group">
                        <!-- 4.1:描述 -->
                        <label for="edit-describe" class="col-sm-2 control-label">客户描述&nbsp;</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="edit-describe"></textarea>
                        </div>
                    </div>

                    <div style="position: relative;top: 20px;">
                        <div class="form-group">
                            <!-- 5.1:详细地址 -->
                            <label for="edit-address" class="col-sm-2 control-label">详细地址&nbsp;</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="1" id="edit-address"></textarea>
                            </div>
                        </div>
                    </div>

                    <br/>
                    <div style="position: relative;top: 15px;">
                        <div class="form-group">
                            <!-- 6.1:下次联系时间 -->
                            <label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间<span
                                    style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control datetimepicker-createCustomerFrom"
                                       id="edit-nextContactTime" readonly>
                            </div>
                        </div>
                    </div>


                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="editCustomerBtn">更新</button>
            </div>
        </div>
    </div>
</div>


<div>
    <div style="position: relative; left: 10px; top: -10px;">
        <div class="page-header">
            <h3>客户列表</h3>
        </div>
    </div>
</div>

<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">

    <div style="width: 100%; position: absolute;top: 5px; left: 10px;">

        <!-- 顶部搜索框 -->
        <div class="btn-toolbar" role="toolbar" style="height: 80px;">
            <form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">

                <!-- 客户名称 -->
                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">名称</div>
                        <input class="form-control" type="text" id="clustomerNameForPage">
                    </div>
                </div>

                <!-- 所有者 -->
                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">所有者</div>
                        <select class="form-control" id="customerOwnerForPage">
                            <option></option>
                            <c:forEach items="${userList}" var="user">
                                <option value="${user.id}">${user.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <!-- 公司座机 -->
                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">公司座机</div>
                        <input class="form-control" type="text" id="clustomerPhoneForPage">
                    </div>
                </div>

                <!-- 公司网站 -->
                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">公司网站</div>
                        <input class="form-control" type="text" id="clustomerWebsiteForPage">
                    </div>
                </div>

                <!-- 查询 -->
                <button type="button" class="btn btn-default" id="queryCustomerForPage">查询</button>
            </form>
        </div>

        <!-- 创建和修改按钮 -->
        <div class="btn-toolbar" role="toolbar"
             style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
            <div class="btn-group" style="position: relative; top: 18%;">
                <button type="button" class="btn btn-primary" id="managerModalCreateBtn">
                    <span class="glyphicon glyphicon-plus"></span> 创建
                </button>
                <button type="button" class="btn btn-default" id="editCustomerInformationBtn"><span
                        class="glyphicon glyphicon-pencil"></span> 修改
                </button>
                <button type="button" class="btn btn-danger" id="deleteCustomerBtn">
                    <span class="glyphicon glyphicon-minus"></span> 删除
                </button>
            </div>
        </div>

        <!-- 数据显示 -->
        <div style="position: relative;top: 10px;">
            <table class="table table-hover">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td><input type="checkbox" id="allCheckRemark"/></td>
                    <td>客户名称</td>
                    <td>所有者</td>
                    <td>公司座机</td>
                    <td>下次联系时间</td>
                    <td>公司网站</td>
                    <td>详细地址</td>
                </tr>
                </thead>

                <tbody id="customerBodyForPage">

                </tbody>
            </table>

            <!-- 分页插件 -->
            <div id="customerDivForPage"></div>
        </div>
    </div>
</div>
</body>
</html>
