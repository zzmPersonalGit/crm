<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String url = "" + request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()
            + request.getContextPath() + "/";
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

        // TODO 页面加载完毕执行
        $(function () {

            // TODO 页面加载完成，发送请求查询分页数据
            sendClueRequestForPage(1, 10);

            // TODO 点击创建按钮弹出模态窗口
            $("#managerModalCreateBtn").click(function () {
                $("#createClueModal").modal("show")
            })

            // TODO 添加线索，成功后调用分页
            $("#saveClueBtn").click(function () {
                var owner = $("#create-clueOwner").val();
                var fullname = $("#create-surname").val().trim();
                var appellation = $("#create-call").val().trim();
                var company = $("#create-company").val().trim();
                var job = $("#create-job").val().trim();
                var email = $("#create-email").val().trim();
                var phone = $("#create-phone").val().trim();
                var website = $("#create-website").val().trim();
                var mphone = $("#create-mphone").val().trim();
                var state = $("#create-status").val().trim();
                var source = $("#create-source").val().trim();
                var description = $("#create-describe").val().trim();
                var contact_summary = $("#create-contactSummary").val().trim();
                var next_contact_time = $("#create-nextContactTime").val().trim();
                var address = $("#create-address").val().trim();

                if (fullname == '') {
                    alert("姓名不能为空");
                    return;
                }
                if (appellation == '') {
                    alert("称呼不能为空");
                    return;
                }
                if (company == '') {
                    alert("公司信息不能为空");
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
                if (owner == '') {
                    alert("所有者不能为空");
                    return;
                }
                if (email == '') {
                    alert("邮箱不能为空");
                    return;
                }
                if (!/^\w{3,}(\.\w+)*@[A-z0-9]+(\.[A-z]{2,5}){1,2}$/.test(email)) {
                    alert("邮箱不合法");
                    return;
                }
                if (source == '') {
                    alert("线索来源不能为空");
                    return;
                }
                if (state == '') {
                    alert("线索状态不能为空");
                    return;
                }
                if (website == '') {
                    alert("公司网站不能为空");
                    return;
                }
                if (phone == '') {
                    alert("座机信息不能为空");
                    return;
                }
                if (!/0\d{2,3}-\d{7,8}/.test(phone)) {
                    alert("座机信息不合法");
                    return;
                }
                if (next_contact_time == '') {
                    alert("下次联系时间不能为空");
                    return;
                }

                //发送请求
                $.ajax({
                    url: 'workbench/clue/saveClue',
                    type: 'POST',
                    data: {
                        'fullname': fullname,
                        'appellation': appellation,
                        'owner': owner,
                        'company': company,
                        'job': job,
                        'email': email,
                        'phone': phone,
                        'website': website,
                        'mphone': mphone,
                        'state': state,
                        'source': source,
                        'description': description,
                        'contactSummary': contact_summary,
                        'nextContactTime': next_contact_time,
                        'address': address
                    },
                    dataType: 'json',
                    success: function (data) {
                        if (data.code == "1") {
                            $("#createClueModal").modal("hide");
                            sendClueRequestForPage(1,
                                $("#clueDivForPage").bs_pagination('getOption', 'rowsPerPage'));
                            // 清空表单
                            $("#createClueForm")[0].reset();
                            $("#allCheckRemark").prop("checked", false)
                        } else {
                            alert("保存失败...")
                        }
                    }
                })
            })

            // TODO 给删除线索的按钮添加点击事件函数
            $("#deleteClueRemarkBtn").click(function () {
                var idsCheckbox = $("#clueBodyForPage input[type='checkbox']:checked");
                if (idsCheckbox.size() <= 0) {
                    alert("每次至少删除一条线索");
                    return;
                }

                if (!window.confirm("是否确认删除")) {
                    return;
                }

                var ids = ""
                $.each(idsCheckbox, function () {
                    ids += "id=" + this.value + "&"
                })

                ids = ids.substr(0, ids.length - 1);
                //发送请求
                $.ajax({
                    url: 'workbench/clue/deleteclueByIds',
                    type: 'POST',
                    data: ids,
                    dataType: 'json',
                    success: function (data) {
                        if (data.code == 0) {
                            alert(data.message)
                        } else {
                            $("#allCheckRemark").prop("checked", false)
                            sendClueRequestForPage(1, $("#clueDivForPage").bs_pagination('getOption', 'rowsPerPage'))
                            $("#allCheckRemark").prop("checked", false)
                        }
                    }
                })
            })

            // TODO 给搜索查询按钮添加一个绑定事件,携带参数发送分页请求
            $("#queryclueForPage").click(function () {
                sendClueRequestForPage(1, $("#clueDivForPage").bs_pagination('getOption', 'rowsPerPage'));
                $("#allCheckRemark").prop("checked", false)
            })

            // TODO 给线索修改按钮添加点击事件函数，先获取数据并渲染
            $("#managerModalUpdateBtn").click(function () {
                var editCheckbox = $("#clueBodyForPage input[type='checkbox']:checked");
                if (editCheckbox.size() == 0) {
                    alert("你还没有选中要修改的数据");
                    return;
                }
                if (editCheckbox.size() != 1) {
                    alert("每次只能修改一条线索信息");
                    return;
                }
                var id = editCheckbox[0].value;

                $.ajax({
                    url: 'workbench/clue/queryClueById',
                    type: 'POST',
                    data: {"id": id},
                    dataType: "json",
                    success: function (data) {
                        //修改文本参数
                        $("#edit-id").val(data.id)
                        $("#edit-clueOwner").val(data.owner)
                        $("#edit-surname").val(data.fullname)
                        $("#edit-call").val(data.appellation)
                        $("#edit-company").val(data.company)
                        $("#edit-job").val(data.job)
                        $("#edit-email").val(data.email)
                        $("#edit-phone").val(data.phone)
                        $("#edit-website").val(data.website)
                        $("#edit-mphone").val(data.mphone)
                        $("#edit-status").val(data.state)
                        $("#edit-source").val(data.source)
                        $("#edit-describe").val(data.description)
                        $("#edit-contactSummary").val(data.contactSummary);
                        $("#edit-nextContactTime").val(data.nextContactTime);
                        $("#edit-address").val(data.address);

                        // 展现模态窗口
                        $("#editClueModal").modal("show")
                    }
                })
            })

            // TODO 填写新数据，校验，更新，更新成功之后关闭模态窗口，然后发送分页请求
            $("#editClueBtn").click(function () {
                // 获取参数
                var id = $("#edit-id").val()
                var owner = $("#edit-clueOwner").val();
                var fullname = $("#edit-surname").val().trim();
                var appellation = $("#edit-call").val().trim();
                var company = $("#edit-company").val().trim();
                var job = $("#edit-job").val().trim();
                var email = $("#edit-email").val().trim();
                var phone = $("#edit-phone").val().trim();
                var website = $("#edit-website").val().trim();
                var mphone = $("#edit-mphone").val().trim();
                var state = $("#edit-status").val().trim();
                var source = $("#edit-source").val().trim();
                var description = $("#edit-describe").val().trim();
                var contact_summary = $("#edit-contactSummary").val().trim();
                var next_contact_time = $("#edit-nextContactTime").val().trim();
                var address = $("#edit-address").val().trim();

                if (fullname == '') {
                    alert("姓名不能为空");
                    return;
                }
                if (appellation == '') {
                    alert("称呼不能为空");
                    return;
                }
                if (company == '') {
                    alert("公司信息不能为空");
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
                if (owner == '') {
                    alert("所有者不能为空");
                    return;
                }
                if (email == '') {
                    alert("邮箱不能为空");
                    return;
                }
                if (!/^\w{3,}(\.\w+)*@[A-z0-9]+(\.[A-z]{2,5}){1,2}$/.test(email)) {
                    alert("邮箱不合法");
                    return;
                }
                if (source == '') {
                    alert("线索来源不能为空");
                    return;
                }
                if (state == '') {
                    alert("线索状态不能为空");
                    return;
                }
                if (website == '') {
                    alert("公司网站不能为空");
                    return;
                }
                if (phone == '') {
                    alert("座机信息不能为空");
                    return;
                }
                if (!/0\d{2,3}-\d{7,8}/.test(phone)) {
                    alert("座机信息不合法");
                    return;
                }
                if (next_contact_time == '') {
                    alert("下次联系时间不能为空");
                    return;
                }

                var jsonParam = JSON.stringify(
                    {
                        "id": id,
                        "owner": owner,
                        "fullname": fullname,
                        "appellation": appellation,
                        "company": company,
                        "job": job,
                        "email": email,
                        "phone": phone,
                        "website": website,
                        "mphone": mphone,
                        "state": state,
                        "source": source,
                        "description": description,
                        "contactSummary": contact_summary,
                        "nextContactTime": next_contact_time,
                        "address": address
                    }
                );

                //发送请求
                $.ajax({
                    url: 'workbench/clue/updateClue',
                    contentType: 'application/json',
                    type: 'POST',
                    data: jsonParam,
                    dataType: "json",
                    success: function (data) {
                        if (data.code == 0) {
                            alert(data.message)
                        } else {
                            $("#editClueModal").modal("hide");
                            sendClueRequestForPage(
                                $("#clueDivForPage").bs_pagination('getOption', 'currentPage'),
                                $("#clueDivForPage").bs_pagination('getOption', 'rowsPerPage'))
                            $("#allCheckRemark").prop("checked", false)
                        }
                    }
                })
            })

            // TODO 给文本框加上日历插件功能
            $(".datetimepicker-createClueFrom").datetimepicker({
                language: 'zh-CN',
                format: 'yyyy-mm-dd',
                minView: 'month',
                initialDate: new Date(),
                autoclose: true,
                todayBtn: true,
                clearBtn: true
            })

            // TODO 给全选的checked框按钮绑定相对应的事件
            $("#allCheckRemark").click(function () {
                $("#clueBodyForPage input[type='checkbox']").prop("checked", this.checked)
            })

            // TODO 给动态生成的checked框绑定单击事件
            $("#clueBodyForPage").on("click", "input[type='checkbox']", function () {
                if ($("#clueBodyForPage input[type='checkbox']").size()
                    == $("#clueBodyForPage input[type='checkbox']:checked").size()) {
                    $("#allCheckRemark").prop("checked", true)
                } else {
                    $("#allCheckRemark").prop("checked", false)
                }
            })
        });

        // TODO 发送线索分页查询的请求的函数
        sendClueRequestForPage = function (pageNo, pageSize) {

            // 参数有名称，所有者，线索来源，线索状态，参数准备后发送请求
            var name = $("#clueNameForPage").val().trim();
            var owner = $("#clueOwnerForPage").val();
            var source = $("#clueSourceForPage").val();
            var state = $("#clueStateForPage").val();

            $.ajax({
                url: 'workbench/clue/queryByConditionForPage',
                type: 'POST',
                data: {
                    "name": name,
                    "owner": owner,
                    "source": source,
                    "state": state,
                    "pageNo": pageNo,
                    "pageSize": pageSize
                },
                dataType: 'json',
                success: function (data) {

                    // TODO 渲染页面
                    var htmlStr = "";
                    $.each(data.clues, function (index, item) {
                        htmlStr += "<tr class=\"active\">";
                        htmlStr += "	<td><input type=\"checkbox\" value='" + item.id + "'/></td>";
                        htmlStr += "	<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='workbench/clue/toDetail?id=" + item.id + "';\">" + item.fullname + "</a></td>";
                        htmlStr += "	<td>" + item.company + "</td>";
                        htmlStr += "	<td>" + item.phone + "</td>";
                        htmlStr += "	<td>" + item.mphone + "</td>";
                        htmlStr += "	<td>" + item.source + "</td>";
                        htmlStr += "	<td>" + item.owner + "</td>";
                        htmlStr += "	<td>" + item.state + "</td>";
                        htmlStr += "</tr>";
                    })

                    //给装分页查询容器值的body赋值
                    $("#clueBodyForPage").html(htmlStr);

                    //计算有多少页
                    var totalPages = 1;
                    if (data.totalRows % pageSize == 0) {
                        totalPages = data.totalRows / pageSize
                    } else {
                        totalPages = parseInt(data.totalRows / pageSize) + 1
                    }

                    //给分页插件准备的容器赋值
                    $("#clueDivForPage").bs_pagination({
                        currentPage: pageNo,
                        rowsPerPage: pageSize,
                        totalPages: totalPages,
                        totalRows: data.totalRows,
                        visiblePageLinks: 5,
                        showGoToPage: true,
                        showRowsPerPage: true,
                        showRowsInfo: true,
                        onChangePage: function (event, pageObj) {
                            sendClueRequestForPage(pageObj.currentPage, pageObj.rowsPerPage);
                            $("#allCheckRemark").prop("checked", false);
                        }
                    });
                }
            })
        }

    </script>
</head>

<body>

<!-- 创建线索的模态窗口 -->
<div class="modal fade" id="createClueModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 90%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel">创建线索</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form" id="createClueForm">

                    <div class="form-group">
                        <!-- 1.1:姓名 -->
                        <label for="create-surname" class="col-sm-2 control-label">客户姓名<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-surname">
                        </div>

                        <!-- 1.2:称呼 -->
                        <label for="create-call" class="col-sm-2 control-label">客户称呼<span
                                style="font-size: 15px; color: red;">*</span></label>

                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-call">
                                <option></option>
                                <c:forEach items="${appellation}" var="app">
                                    <option value="${app.id}">${app.value}</option>
                                </c:forEach>
                            </select>
                        </div>

                    </div>

                    <div class="form-group">

                        <!-- 2.1:公司 -->
                        <label for="create-company" class="col-sm-2 control-label">客户公司<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-company">
                        </div>

                        <!-- 2.1:手机 -->
                        <label for="create-mphone" class="col-sm-2 control-label">客户手机<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-mphone">
                        </div>

                    </div>

                    <div class="form-group">
                        <!-- 3.1:所有者 -->
                        <label for="create-clueOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-clueOwner">
                                <option></option>
                                <c:forEach items="${users}" var="u">
                                    <option value="${u.id}">${u.name}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <!-- 3.2:邮箱 -->
                        <label for="create-email" class="col-sm-2 control-label">客户邮箱<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-email">
                        </div>
                    </div>

                    <div class="form-group">
                        <!-- 4.1:来源 -->
                        <label for="create-source" class="col-sm-2 control-label">线索来源<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-source">
                                <option></option>
                                <c:forEach items="${source}" var="s">
                                    <option value="${s.id}">${s.value}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <!-- 状态 -->
                        <label for="create-status" class="col-sm-2 control-label">线索状态<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-status">
                                <option></option>
                                <c:forEach items="${clueState}" var="state">
                                    <option value="${state.id}">${state.value}</option>
                                </c:forEach>
                            </select>
                        </div>

                    </div>

                    <div class="form-group">
                        <!-- 5.1:网站 -->
                        <label for="create-website" class="col-sm-2 control-label">公司网站<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-website">
                        </div>

                        <!-- 5.2:座机 -->
                        <label for="create-phone" class="col-sm-2 control-label">公司座机<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-phone">
                        </div>
                    </div>

                    <div class="form-group">
                        <!-- 6.1:下次联系时间 -->
                        <label for="create-nextContactTime"
                               class="col-sm-2 control-label">下次联系时间<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control  datetimepicker-createClueFrom"
                                   id="create-nextContactTime" readonly>
                        </div>

                        <!-- 6.2:职位 -->
                        <label for="create-job" class="col-sm-2 control-label">职位&nbsp;&nbsp;</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-job">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-describe" class="col-sm-2 control-label">线索描述&nbsp;&nbsp;</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="create-describe"></textarea>
                        </div>
                    </div>

                    <div style="position: relative;top: 15px;">
                        <div class="form-group">
                            <label for="create-contactSummary" class="col-sm-2 control-label">联系纪要&nbsp;&nbsp;</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="create-contactSummary"></textarea>
                            </div>
                        </div>

                    </div>

                    <div style="position: relative;top: 20px;">
                        <div class="form-group">
                            <label for="create-address" class="col-sm-2 control-label">详细地址&nbsp;&nbsp;</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="1" id="create-address"></textarea>
                            </div>
                        </div>
                    </div>
                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="saveClueBtn">保存</button>
            </div>
        </div>
    </div>
</div>

<!-- 修改线索的模态窗口 -->
<div class="modal fade" id="editClueModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 90%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">修改线索</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form">
                    <input type="hidden" id="edit-id"/>

                    <div class="form-group">
                        <!-- 1.1:姓名 -->
                        <label for="edit-surname" class="col-sm-2 control-label">客户姓名<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-surname">
                        </div>

                        <!-- 1.2:称呼 -->
                        <label for="edit-call" class="col-sm-2 control-label">客户称呼<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-call">
                                <option></option>
                                <c:forEach items="${appellation}" var="app">
                                    <option value="${app.id}">${app.value}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">

                        <!-- 2.1公司 -->
                        <label for="edit-company" class="col-sm-2 control-label">所在公司<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-company">
                        </div>

                        <!-- 2.2:客户手机 -->
                        <label for="edit-mphone" class="col-sm-2 control-label">客户手机<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-mphone">
                        </div>

                    </div>

                    <div class="form-group">

                        <!-- 3.1:所有者 -->
                        <label for="edit-clueOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-clueOwner">
                                <c:forEach items="${users}" var="u">
                                    <option value="${u.id}">${u.name}</option>
                                </c:forEach>
                            </select>
                        </div>

                        <!-- 3.2:邮箱 -->
                        <label for="edit-email" class="col-sm-2 control-label">客户邮箱<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-email">
                        </div>
                    </div>

                    <div class="form-group">

                        <!-- 4.1:线索来源 -->
                        <label for="edit-source" class="col-sm-2 control-label">线索来源<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-source">
                                <option></option>
                                <c:forEach items="${source}" var="s">
                                    <option value="${s.id}">${s.value}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <!-- 4.2:线索状态 -->
                        <label for="edit-status" class="col-sm-2 control-label">线索状态<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-status">
                                <option></option>
                                <c:forEach items="${clueState}" var="state">
                                    <option value="${state.id}">${state.value}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">

                        <!-- 5.1:公司网站 -->
                        <label for="edit-website" class="col-sm-2 control-label">公司网站<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-website">
                        </div>

                        <!-- 5.2:座机 -->
                        <label for="edit-phone" class="col-sm-2 control-label">公司座机<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-phone">
                        </div>

                    </div>

                    <div class="form-group">

                        <!-- 6.1:下次联系时间 -->
                        <label for="edit-nextContactTime"
                               class="col-sm-2 control-label">下次联系时间<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control  datetimepicker-createClueFrom"
                                   id="edit-nextContactTime" readonly>
                        </div>

                        <!-- 6.2:职位 -->
                        <label for="edit-job" class="col-sm-2 control-label">职位&nbsp;&nbsp;</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-job">
                        </div>

                    </div>

                    <div class="form-group">
                        <!-- 7:线索描述 -->
                        <label for="edit-describe" class="col-sm-2 control-label">线索描述&nbsp;&nbsp;</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="edit-describe"></textarea>
                        </div>
                    </div>

                    <div style="position: relative;top: 15px;">
                        <div class="form-group">
                            <label for="edit-contactSummary" class="col-sm-2 control-label">联系纪要&nbsp;&nbsp;</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="edit-contactSummary"></textarea>
                            </div>
                        </div>

                    </div>

                    <div style="position: relative;top: 20px;">
                        <div class="form-group">
                            <!-- 8:详细地址 -->
                            <label for="edit-address" class="col-sm-2 control-label">详细地址&nbsp;&nbsp;</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="1" id="edit-address"></textarea>
                            </div>
                        </div>
                    </div>
                </form>
            </div>


            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="editClueBtn">更新</button>
            </div>
        </div>
    </div>
</div>

<!-- 线索列表 -->
<div>
    <div style="position: relative; left: 10px; top: -10px;">
        <div class="page-header">
            <h3>线索列表</h3>
        </div>
    </div>
</div>

<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">

    <div style="width: 100%; position: absolute;top: 5px; left: 10px;">

        <!-- TODO 顶部搜索框 -->
        <div class="btn-toolbar" role="toolbar" style="height: 45px;">
            <form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
                <!-- 线索名称 -->
                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">名称</div>
                        <input class="form-control" type="text" id="clueNameForPage">
                    </div>
                </div>
                <!-- 所有者 -->
                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">所有者</div>
                        <select class="form-control" id="clueOwnerForPage">
                            <option></option>
                            <c:forEach items="${users}" var="user">
                                <option value="${user.id}">${user.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <!-- 线索来源 -->
                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">线索来源</div>
                        <select class="form-control" id="clueSourceForPage">
                            <option></option>
                            <c:forEach items="${source}" var="s">
                                <option value="${s.id}">${s.value}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <!-- 线索状态 -->
                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">线索状态</div>
                        <select class="form-control" id="clueStateForPage">
                            <option></option>
                            <c:forEach items="${clueState}" var="state">
                                <option value="${state.id}">${state.value}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <button type="button" class="btn btn-default" id="queryclueForPage">查询</button>
            </form>
        </div>

        <!-- TODO 创建，修改，删除按钮 -->
        <div class="btn-toolbar" role="toolbar"
             style="background-color: #F7F7F7; height: 50px; position: relative;top: 40px;">
            <div class="btn-group" style="position: relative; top: 18%;">
                <button type="button"
                        class="btn btn-primary"
                        id="managerModalCreateBtn">
                    <span class="glyphicon glyphicon-plus"></span> 创建
                </button>

                <button type="button"
                        class="btn btn-default"
                        id="managerModalUpdateBtn">
                    <span class="glyphicon glyphicon-pencil"></span> 修改
                </button>

                <button type="button" class="btn btn-danger" id="deleteClueRemarkBtn"><span
                        class="glyphicon glyphicon-minus"></span> 删除
                </button>
            </div>

        </div>
        <div style="position: relative;top: 50px;">

            <!-- 展现数据的部分 -->
            <table class="table table-hover">
                <!-- 头部 -->
                <thead>
                <tr style="color: #B3B3B3;">
                    <td><input type="checkbox" id="allCheckRemark"/></td>
                    <td>客户姓名</td>
                    <td>公司</td>
                    <td>公司座机</td>
                    <td>手机</td>
                    <td>线索来源</td>
                    <td>所有者</td>
                    <td>线索状态</td>
                </tr>
                </thead>

                <!-- 真实的数据，渲染发送请求之后的数据 -->
                <tbody id="clueBodyForPage">
                </tbody>
            </table>

            <!-- 分页插件 -->
            <div id="clueDivForPage"></div>
        </div>
    </div>

</div>

</body>
</html>
