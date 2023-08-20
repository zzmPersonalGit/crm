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
            sendContactsRequestForPage(1, 10)

            // TODO 点击查询，发送携带查询参数的分页请求
            $("#queryContactsForPage").click(function () {
                sendContactsRequestForPage(1, $("#contactsDivForPage").bs_pagination('getOption', 'rowsPerPage'));
                $("#allCheckRemark").prop("checked", false)
            })

            // TODO 创建新的联系人
            $("#saveContacts").click(function () {
                var owner = $("#create-contactsOwner").val();
                var source = $("#create-contactssource").val();
                var fullname = $("#create-contactsname").val().trim();
                var appellation = $("#create-contactscall").val();
                var job = $("#create-contactsjob").val().trim();
                var mphone = $("#create-contactsmphone").val().trim();
                var email = $("#create-contactsemail").val().trim();
                var customerId = $("#create-customerId").val().trim();
                var description = $("#create-contactsdescribe").val().trim();
                var contactSummary = $("#create-contactsSummary").val().trim();
                var nextContactTime = $("#create-nextContactTime").val().trim();
                var address = $("#create-contactsaddress").val().trim();

                // 参数校验
                if (fullname == '') {
                    alert("联系人姓名不能为空");
                    return;
                }
                if (appellation == '') {
                    alert("称呼不能为空");
                    return;
                }
                if (owner == '') {
                    alert("所有者不能为空");
                    return;
                }
                if (source == '') {
                    alert("线索来源不能为空");
                    return;
                }
                if (customerId == '') {
                    alert("所属公司不能为空");
                    return;
                }
                if (mphone == '') {
                    alert("手机号不能为空");
                    return;
                }
                if (!/^1[3-9]\d{9}$/.test(mphone)) {
                    alert("手机不合法");
                    return;
                }
                if (email != '' && !/^\w{3,}(\.\w+)*@[A-z0-9]+(\.[A-z]{2,5}){1,2}$/.test(email)) {
                    alert("邮箱不合法");
                    return;
                }
                if(nextContactTime==''){
                    alert("下次联系时间不能为空");
                    return;
                }

                // 发送ajax请求
                $.ajax({
                    url: "workbench/contacts/saveContacts",
                    type: "POST",
                    data: {
                        "owner": owner,
                        "source": source,
                        "fullname": fullname,
                        "appellation": appellation,
                        "job": job,
                        "mphone": mphone,
                        "email": email,
                        "customerId": customerId,
                        "description": description,
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
                            $("#createContactsModal").modal("hide");

                            // 发送分页请求
                            sendContactsRequestForPage(1, $("#contactsDivForPage").bs_pagination('getOption', 'rowsPerPage'))
                            $("#createContactsForm")[0].reset();
                        }
                    }
                })
            })

            // TODO 删除联系人信息
            $("#deleteContactsBtn").click(function () {
                var idsCheckbox = $("#contactsBodyForPage input[type='checkbox']:checked");
                if (idsCheckbox.size() <= 0) {
                    alert("每次至少删除一条联系人信息");
                    return;
                }

                if (!window.confirm("谨慎操作，删除联系人会清空该联系人下的所有交易信息")) {
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
                    url: 'workbench/contacts/deleteContactsByIds',
                    type: 'POST',
                    data: ids,
                    dataType: 'json',
                    success: function (data) {
                        if (data.code == 0) {
                            alert(data.message)
                        } else {
                            sendContactsRequestForPage(1, $("#contactsDivForPage").bs_pagination('getOption', 'rowsPerPage'))
                            $("#allCheckRemark").prop("checked", false)
                        }
                    }
                })
            })

            // TODO 联系人信息修改前先获取数据并渲染
            $("#editContactsInformationBtn").click(function () {
                var editCheckbox = $("#contactsBodyForPage input[type='checkbox']:checked");
                if (editCheckbox.size() == 0) {
                    alert("你还没有选中要修改的数据")
                    return;
                }
                if (editCheckbox.size() != 1) {
                    alert("每次只能修改一条联系人信息")
                    return;
                }
                var id = editCheckbox[0].value;

                $.ajax({
                    url: 'workbench/contacts/queryContactsById',
                    type: 'POST',
                    data: {"id": id},
                    dataType: "json",
                    success: function (data) {
                        //修改文本参数
                        $("#edit-id").val(data.id)
                        $("#edit-contactsOwner").val(data.owner);
                        $("#edit-contactssource").val(data.source);
                        $("#edit-contactsname").val(data.fullname);
                        $("#edit-contactscall").val(data.appellation);
                        $("#edit-contactsjob").val(data.job);
                        $("#edit-contactsmphone").val(data.mphone);
                        $("#edit-contactsemail").val(data.email);
                        $("#edit-customerId").val(data.customerId);
                        $("#edit-contactsdescribe").val(data.description);
                        $("#edit-contactsSummary").val(data.contactSummary);
                        $("#edit-nextContactTime").val(data.nextContactTime);
                        $("#edit-contactsaddress").val(data.address);

                        //打开修改的模块窗口
                        $("#editContactsModal").modal("show");
                    }
                })
            })

            // TODO 更新联系人信息,成功之后关闭模态窗口,然后发送分页请求
            $("#editContactsBtn").click(function () {
                //获取文本参数
                var id = $("#edit-id").val()
                var owner = $("#edit-contactsOwner").val();
                var source = $("#edit-contactssource").val();
                var fullname = $("#edit-contactsname").val().trim();
                var appellation = $("#edit-contactscall").val();
                var job = $("#edit-contactsjob").val().trim();
                var mphone = $("#edit-contactsmphone").val().trim();
                var email = $("#edit-contactsemail").val().trim();
                var customerId = $("#edit-customerId").val().trim();
                var description = $("#edit-contactsdescribe").val().trim();
                var contactSummary = $("#edit-contactsSummary").val().trim();
                var nextContactTime = $("#edit-nextContactTime").val().trim();
                var address = $("#edit-contactsaddress").val().trim();

                //检验参数是否合法
                if (fullname == '') {
                    alert("联系人姓名不能为空");
                    return;
                }
                if (appellation == '') {
                    alert("称呼不能为空");
                    return;
                }
                if (owner == '') {
                    alert("所有者不能为空");
                    return;
                }
                if (source == '') {
                    alert("线索来源不能为空");
                    return;
                }
                if (customerId == '') {
                    alert("所属公司不能为空");
                    return;
                }
                if (mphone == '') {
                    alert("手机号不能为空");
                    return;
                }
                if (!/^1[3-9]\d{9}$/.test(mphone)) {
                    alert("手机不合法");
                    return;
                }
                if (email != '' && !/^\w{3,}(\.\w+)*@[A-z0-9]+(\.[A-z]{2,5}){1,2}$/.test(email)) {
                    alert("邮箱不合法");
                    return;
                }
                if(nextContactTime==''){
                    alert("下次联系时间不能为空");
                    return;
                }
                //发送请求
                $.ajax({
                    url: "workbench/contacts/editContacts",
                    type: "POST",
                    data: {
                        "id": id,
                        "owner": owner,
                        "source": source,
                        "fullname": fullname,
                        "appellation": appellation,
                        "job": job,
                        "mphone": mphone,
                        "email": email,
                        "customerId": customerId,
                        "description": description,
                        "contactSummary": contactSummary,
                        "nextContactTime": nextContactTime,
                        "address": address
                    },
                    dataType: "json",
                    success: function (data) {
                        if (data.code == 0) {
                            alert(data.message)
                        } else {
                            $("#editContactsModal").modal("hide");
                            sendContactsRequestForPage(
                                $("#contactsDivForPage").bs_pagination('getOption', 'currentPage'),
                                $("#contactsDivForPage").bs_pagination('getOption', 'rowsPerPage'))
                        }
                    }
                })
            })

            // TODO 点击创建按钮弹出模态窗口
            $("#managerModalCreateBtn").click(function () {
                $("#createContactsModal").modal("show")
            })

            // TODO 给全选的checked框按钮绑定相对应的事件
            $("#allCheckRemark").click(function () {
                $("#contactsBodyForPage input[type='checkbox']").prop("checked", this.checked)
            })

            // TODO 给动态生成的checked框绑定单击事件
            $("#contactsBodyForPage").on("click", "input[type='checkbox']", function () {
                if ($("#contactsBodyForPage input[type='checkbox']").size()
                    == $("#contactsBodyForPage input[type='checkbox']:checked").size()) {
                    $("#allCheckRemark").prop("checked", true)
                } else {
                    $("#allCheckRemark").prop("checked", false)
                }
            })

            // TODO 给文本框加上日历插件功能
            $(".datetimepicker-createContactsFrom").datetimepicker({
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
        sendContactsRequestForPage = function (pageNo, pageSize) {
            var owner = $("#contactsOwnerForPage").val();
            var name = $("#contactsNameForPage").val().trim();
            var customerId = $("#contactCustomerIdForPage").val();
            var source = $("#contactsSourceForPage").val();

            console.log(customerId);

            $.ajax({
                url: 'workbench/contacts/queryByConditionForPage',
                type: 'POST',
                data: {
                    "fullname": name,
                    "owner": owner,
                    "customerId": customerId,
                    "source": source,
                    "pageNo": pageNo,
                    "pageSize": pageSize
                },
                dataType: 'json',
                success: function (data) {
                    var htmlStr = "";
                    $.each(data.contacts, function (index, item) {
                        htmlStr += "<tr class=\"active\">";
                        htmlStr += "	<td><input type=\"checkbox\" value='" + item.id + "'/></td>";
                        htmlStr += "	<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='workbench/contacts/toDetail?id=" + item.id + "';\">" + item.fullname + "</a></td>";
                        htmlStr += "	<td>" + item.appellation + "</td>";
                        htmlStr += "	<td>" + item.customerId + "</td>";
                        htmlStr += "	<td>" + item.nextContactTime + "</td>";
                        htmlStr += "	<td>" + item.mphone + "</td>";
                        htmlStr += "	<td>" + item.owner + "</td>";
                        htmlStr += "	<td>" + item.source + "</td>";
                        htmlStr += "</tr>";
                    })

                    // 给装分页查询容器值的body赋值
                    $("#contactsBodyForPage").html(htmlStr);

                    //计算有多少页
                    var totalPages = 1;
                    if (data.totalRows % pageSize == 0) {
                        totalPages = data.totalRows / pageSize
                    } else {
                        totalPages = parseInt(data.totalRows / pageSize) + 1
                    }

                    //给分页插件准备的容器赋值
                    $("#contactsDivForPage").bs_pagination({
                        currentPage: pageNo,
                        rowsPerPage: pageSize,
                        totalPages: totalPages,
                        totalRows: data.totalRows,
                        visiblePageLinks: 5,
                        showGoToPage: true,
                        showRowsPerPage: true,
                        showRowsInfo: true,
                        onChangePage: function (event, pageObj) {
                            sendContactsRequestForPage(pageObj.currentPage, pageObj.rowsPerPage);
                            $("#allCheckRemark").prop("checked", false);
                        }
                    });
                }
            })
        }
    </script>
</head>
<body>

<!-- 创建联系人的模态窗口 -->
<div class="modal fade" id="createContactsModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" onclick="$('#createContactsModal').modal('hide');">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabelx">创建联系人</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form" id="createContactsForm">

                    <div class="form-group">
                        <!-- 1.1:所属公司 -->
                        <label for="create-customerId" class="col-sm-2 control-label">所属公司<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-customerId">
                                <option></option>
                                <c:forEach items="${customers}" var="app">
                                    <option value="${app.id}">${app.name}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <!-- 1.2:所有者 -->
                        <label for="create-contactsOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-contactsOwner">
                                <option></option>
                                <c:forEach items="${users}" var="u">
                                    <option value="${u.id}">${u.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <!-- 2.1:姓名 -->
                        <label for="create-contactsname" class="col-sm-2 control-label">联系人姓名<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-contactsname">
                        </div>

                        <!-- 2.2:称呼 -->
                        <label for="create-contactscall" class="col-sm-2 control-label">称呼<span
                                style="font-size: 15px; color: red;">*</span></label>

                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-contactscall">
                                <option></option>
                                <c:forEach items="${appellation}" var="app">
                                    <option value="${app.id}">${app.value}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <!-- 3.1:来源 -->
                        <label for="create-contactssource" class="col-sm-2 control-label">线索来源<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-contactssource">
                                <option></option>
                                <c:forEach items="${source}" var="s">
                                    <option value="${s.id}">${s.value}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <!-- 3.2:手机 -->
                        <label for="create-contactsmphone" class="col-sm-2 control-label">手机<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-contactsmphone">
                        </div>

                    </div>

                    <div class="form-group" style="position: relative;">
                        <!-- 4.1:职位 -->
                        <label for="create-contactsjob" class="col-sm-2 control-label">职位&nbsp;&nbsp;</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-contactsjob">
                        </div>

                        <!-- 4.1:邮箱 -->
                        <label for="create-contactsemail" class="col-sm-2 control-label">邮箱&nbsp;&nbsp;</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-contactsemail">
                        </div>

                    </div>

                    <div class="form-group" style="position: relative;">
                        <label for="create-contactsdescribe" class="col-sm-2 control-label">描述&nbsp;&nbsp;</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="create-contactsdescribe"></textarea>
                        </div>
                    </div>

                    <div style="position: relative;top: 15px;">
                        <div class="form-group">
                            <label for="create-contactsSummary" class="col-sm-2 control-label">联系纪要&nbsp;&nbsp;</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="create-contactsSummary"></textarea>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间<span
                                    style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control datetimepicker-createContactsFrom"
                                       id="create-nextContactTime" readonly>
                            </div>
                        </div>
                    </div>


                    <div style="position: relative;top: 20px;">
                        <div class="form-group">
                            <label for="create-contactsaddress" class="col-sm-2 control-label">详细地址&nbsp;&nbsp;</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="1" id="create-contactsaddress"></textarea>
                            </div>
                        </div>
                    </div>
                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="saveContacts">保存</button>
            </div>
        </div>
    </div>
</div>

<!-- 修改联系人的模态窗口 -->
<div class="modal fade" id="editContactsModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel1">修改联系人</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form">
                    <input type="hidden" id="edit-id"/>

                    <div class="form-group">
                        <!-- 1.1:公司 -->
                        <label for="edit-customerId" class="col-sm-2 control-label">所属公司<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-customerId">
                                <option></option>
                                <c:forEach items="${customers}" var="app">
                                    <option value="${app.id}">${app.name}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <!-- 1.2:所有者 -->
                        <label for="edit-contactsOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-contactsOwner">
                                <option></option>
                                <c:forEach items="${users}" var="u">
                                    <option value="${u.id}">${u.name}</option>
                                </c:forEach>
                            </select>
                        </div>

                    </div>

                    <div class="form-group">
                        <!-- 2.1:姓名 -->
                        <label for="edit-contactsname" class="col-sm-2 control-label">联系人姓名<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-contactsname">
                        </div>
                        <!-- 2.2:称呼 -->
                        <label for="edit-contactscall" class="col-sm-2 control-label">称呼<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-contactscall">
                                <option></option>
                                <c:forEach items="${appellation}" var="app">
                                    <option value="${app.id}">${app.value}</option>
                                </c:forEach>
                            </select>
                        </div>

                    </div>

                    <div class="form-group">

                        <!-- 3.1：线索来源 -->
                        <label for="edit-contactssource" class="col-sm-2 control-label">线索来源<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-contactssource">
                                <option></option>
                                <c:forEach items="${source}" var="s">
                                    <option value="${s.id}">${s.value}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <!-- 3.2:手机 -->
                        <label for="edit-contactsmphone" class="col-sm-2 control-label">手机<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-contactsmphone">
                        </div>

                    </div>

                    <div class="form-group">
                        <!-- 4.1:职位 -->
                        <label for="edit-contactsjob" class="col-sm-2 control-label">职位&nbsp;&nbsp;</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-contactsjob">
                        </div>

                        <!-- 4.2:邮箱 -->
                        <label for="edit-contactsemail" class="col-sm-2 control-label">邮箱&nbsp;&nbsp;</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-contactsemail">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-contactsdescribe" class="col-sm-2 control-label">描述&nbsp;&nbsp;</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="edit-contactsdescribe"></textarea>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-contactsSummary" class="col-sm-2 control-label">联系纪要&nbsp;&nbsp;</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="edit-contactsSummary"></textarea>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control datetimepicker-createContactsFrom"
                                   id="edit-nextContactTime" readonly>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-contactsaddress" class="col-sm-2 control-label">详细地址&nbsp;&nbsp;</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="1" id="edit-contactsaddress"></textarea>
                        </div>
                    </div>
                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="editContactsBtn">更新</button>
            </div>
        </div>
    </div>
</div>

<div>
    <div style="position: relative; left: 10px; top: -10px;">
        <div class="page-header">
            <h3>联系人列表</h3>
        </div>
    </div>
</div>

<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">

    <div style="width: 100%; position: absolute;top: 5px; left: 10px;">

        <div class="btn-toolbar" role="toolbar" style="height: 80px;">

            <!-- 顶部搜索栏 -->
            <form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">

                <!-- 所有者 -->
                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">所有者</div>
                        <select class="form-control" id="contactsOwnerForPage">
                            <option></option>
                            <c:forEach items="${users}" var="u">
                                <option value="${u.id}">${u.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <!-- 姓名 -->
                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">姓名</div>
                        <input class="form-control" type="text" id="contactsNameForPage">
                    </div>
                </div>

                <!-- 客户名称 -->
                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">客户名称</div>
                        <select class="form-control" id="contactCustomerIdForPage">
                            <option></option>
                            <c:forEach items="${customers}" var="app">
                                <option value="${app.id}">${app.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <!-- 来源 -->
                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">来源</div>
                        <select class="form-control" id="contactsSourceForPage">
                            <option></option>
                            <c:forEach items="${source}" var="s">
                                <option value="${s.id}">${s.value}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>


                <button type="button" class="btn btn-default" id="queryContactsForPage">查询</button>

            </form>
        </div>
        <div class="btn-toolbar" role="toolbar"
             style="background-color: #F7F7F7; height: 50px; position: relative;top: 10px;">
            <div class="btn-group" style="position: relative; top: 18%;">
                <button type="button" class="btn btn-primary" id="managerModalCreateBtn">
                    <span class="glyphicon glyphicon-plus"></span> 创建
                </button>
                <button type="button" class="btn btn-default" id="editContactsInformationBtn"><span
                        class="glyphicon glyphicon-pencil"></span> 修改
                </button>
                <button type="button" class="btn btn-danger" id="deleteContactsBtn">
                    <span class="glyphicon glyphicon-minus"></span> 删除
                </button>
            </div>


        </div>
        <div style="position: relative;top: 20px;">
            <table class="table table-hover">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td><input type="checkbox" id="allCheckRemark"/></td>
                    <td>姓名</td>
                    <td>称呼</td>
                    <td>所属客户</td>
                    <td>下次联系时间</td>
                    <td>联系手机号</td>
                    <td>所有者</td>
                    <td>来源</td>
                </tr>
                </thead>

                <tbody id="contactsBodyForPage">

                </tbody>
            </table>

            <!-- 分页插件 -->
            <div id="contactsDivForPage"></div>

        </div>
    </div>

</div>
</body>
</html>
