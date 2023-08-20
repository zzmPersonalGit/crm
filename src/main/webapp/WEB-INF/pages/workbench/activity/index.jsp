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

        // TODO 加载完成之后执行
        $(function () {
            // TODO 页面窗口加载完毕后,打包数据，发送分页查询的请求
            sendActivityRequestForPage(1, 10)

            // TODO 创建市场活动的按钮，创建按完成之后调用分页
            $("#saveActivityBtn").click(function () {

                // 保证数据的合法以及获取数据
                var owner = $("#create-marketActivityOwner").val();
                var name = $("#create-marketActivityName").val().trim();
                var startDate = $("#create-startTime").val();
                var endDate = $("#create-endTime").val();
                var cost = $("#create-cost").val().trim();
                var description = $("#create-describe").val().trim();
                // 检验数据
                if (owner == '') {
                    alert("所有者不能为空");
                    return;
                }
                if (name == '') {
                    alert("名字不可为空");
                    return;
                }
                if (startDate == '') {
                    alert("开始日期不能为空");
                    return;
                }
                if (endDate == '') {
                    alert("结束日期不能为空");
                    return;
                }
                // 检验时间是否合法
                if (startDate != "" || endDate != "") {
                    var regularExp = /^\d{4}-\d{1,2}-\d{1,2}$/
                    if (!regularExp.test(startDate)) {
                        alert("日期格式不合法，例:2021-12-21")
                        return;
                    } else if (!regularExp.test(endDate)) {
                        alert("日期格式不合法，例:2021-12-21")
                        return;
                    }
                    if (startDate != "" && endDate != "") {
                        if (startDate > endDate) {
                            alert("日期的顺序不合法")
                            return;
                        }
                    }
                }

                if (cost == '') {
                    alert("金额成本不能为空");
                    return;
                }
                // 正则表达式指定字符串的格式，成本只能为非负整数
                var regExp = /^(([1-9]\d*)|0)$/
                if (!regExp.test(cost)) {
                    alert("金额成本只能为非负整数")
                    return;
                }

                // 发送ajax请求
                $.ajax({
                    url: "workbench/activity/saveActivity",
                    type: "POST",
                    data: {
                        "owner": owner,
                        "name": name,
                        "startDate": startDate,
                        "endDate": endDate,
                        "cost": cost,
                        "description": description,
                    },
                    dataType: "json",
                    success: function (data) {
                        if ("0" == data.code) {
                            //创建失败,提示信息创建失败,模态窗口不关闭,市场活动列表也不刷新
                            alert(data.message)
                        } else {
                            //创建成功后，关闭模态窗口,刷新市场活动列
                            $("#createActivityModal").modal("hide");

                            // 发送分页请求，创建完成之后回到第一页
                            sendActivityRequestForPage(1, $("#activityDivForPage").bs_pagination('getOption', 'rowsPerPage'))
                            $("#createActivityForm")[0].reset();
                            $("#allCheckRemark").prop("checked", false)
                        }
                    }
                })
            })

            // TODO 给搜索查询按钮添加一个绑定事件,携带参数发送分页请求
            $("#queryActivityForPage").click(function () {
                // 搜索默认展示第一页
                sendActivityRequestForPage(1, $("#activityDivForPage").bs_pagination('getOption', 'rowsPerPage'));
                $("#allCheckRemark").prop("checked", false);
            })

            // TODO 给市场活动删除按钮添加点击事件函数
            $("#deleteActivityBtn").click(function () {

                var idsCheckbox = $("#activityBodyForPage input[type='checkbox']:checked");
                if (idsCheckbox.size() <= 0) {
                    alert("每次至少删除一条市场活动");
                    return;
                }
                if (!window.confirm("是否删除所选市场活动")) {
                    return;
                }
                var ids = ""
                $.each(idsCheckbox, function () {
                    ids += "id=" + this.value + "&"
                })
                ids = ids.substr(0, ids.length - 1);

                //发送请求
                $.ajax({
                    url: 'workbench/activity/deleteActivityByIds',
                    type: 'POST',
                    data: ids,
                    dataType: 'json',
                    success: function (data) {
                        if (data.code == 0) {
                            alert(data.message)
                        } else {
                            // 删除之后到第一页
                            sendActivityRequestForPage(1, $("#activityDivForPage").bs_pagination('getOption', 'rowsPerPage'));
                            $("#allCheckRemark").prop("checked", false)
                        }
                    }
                })
            })

            // TODO 市场活动修改前先获取数据并渲染
            $("#editActivityInformationBtn").click(function () {
                var editCheckbox = $("#activityBodyForPage input[type='checkbox']:checked");
                if (editCheckbox.size() == 0) {
                    alert("你还没有选中要修改的数据")
                    return;
                }
                if (editCheckbox.size() != 1) {
                    alert("每次只能修改一条市场活动")
                    return;
                }
                var id = editCheckbox[0].value;
                $.ajax({
                    url: 'workbench/activity/queryActivityById',
                    type: 'POST',
                    data: {"id": id},
                    dataType: "json",
                    success: function (data) {
                        //修改文本参数
                        $("#edit-id").val(data.id)
                        $("#edit-marketActivityOwner").val(data.owner)
                        $("#edit-marketActivityName").val(data.name)
                        $("#edit-startTime").val(data.startDate)
                        $("#edit-endTime").val(data.endDate)
                        $("#edit-cost").val(data.cost)
                        $("#edit-describe").val(data.description)
                        //打开修改的模块窗口
                        $("#editActivityModal").modal("show");
                    }
                })
            })

            // TODO 更新市场活动信息,成功之后关闭模态窗口,然后发送分页请求
            $("#editActivityBtn").click(function () {
                //获取文本参数
                var id = $("#edit-id").val()
                var owner = $("#edit-marketActivityOwner").val()
                var name = $("#edit-marketActivityName").val().trim()
                var startDate = $("#edit-startTime").val()
                var endDate = $("#edit-endTime").val()
                var cost = $("#edit-cost").val().trim();
                var description = $("#edit-describe").val().trim()
                //检验参数是否合法
                if (owner == '') {
                    alert("所有者不能为空");
                    return;
                }
                if (name == '') {
                    alert("名字不可为空");
                    return;
                }
                if (startDate == '') {
                    alert("开始日期不能为空");
                    return;
                }
                if (endDate == '') {
                    alert("结束日期不能为空");
                    return;
                }

                if (startDate != "" || endDate != "") {
                    var regularExp = /^\d{4}-\d{1,2}-\d{1,2}$/
                    if (!regularExp.test(startDate)) {
                        alert("日期格式不合法，例：2021-12-21")
                        return;
                    } else if (!regularExp.test(endDate)) {
                        alert("日期格式不合法，例：2021-12-21")
                        return;
                    }
                    if (startDate != "" && endDate != "") {
                        if (startDate > endDate) {
                            alert("日期的顺序不合法")
                            return;
                        }
                    }
                }
                if (cost == '') {
                    alert("金额成本不能为空");
                    return;
                }
                // 正则表达式指定字符串的格式，成本只能为非负整数
                var regExp = /^(([1-9]\d*)|0)$/
                if (!regExp.test(cost)) {
                    alert("金额成本只能为非负整数")
                    return;
                }

                //发送请求
                $.ajax({
                    url: "workbench/activity/editActivity",
                    type: "POST",
                    data: {
                        "id": id,
                        "owner": owner,
                        "name": name,
                        "startDate": startDate,
                        "endDate": endDate,
                        "cost": cost,
                        "description": description,
                    },
                    dataType: "json",
                    success: function (data) {
                        if (data.code == 0) {
                            alert(data.message)
                        } else {
                            $("#editActivityModal").modal("hide");
                            // 更新之后就展示这一页的内容
                            sendActivityRequestForPage(
                                $("#activityDivForPage").bs_pagination('getOption', 'currentPage'),
                                $("#activityDivForPage").bs_pagination('getOption', 'rowsPerPage'))
                            $("#allCheckRemark").prop("checked", false)
                        }
                    }
                })
            })

            // TODO 给批量导出按钮添加事件函数
            $("#exportActivityAllBtn").click(function () {
                if (!window.confirm("是否全部下载")) {
                    return;
                }
                window.location.href = "workbench/activity/fileDownload";
            })

            // TODO 给选择导出按钮添加事件函数
            $("#exportActivityXzBtn").click(function () {
                var checkedBoxes = $("#activityBodyForPage input[type='checkbox']:checked");

                if (checkedBoxes.length == 0) {
                    alert("暂未选择要下载的数据")
                    return;
                }

                if (!window.confirm("是否下载所选数据")) {
                    return;
                }

                var ids = "";
                $.each(checkedBoxes, function () {
                    ids += "id=" + this.value + "&";
                })
                ids = ids.substr(0, ids.length - 1);
                var url = "workbench/activity/fileDownload?" + ids;
                window.location.href = url;
            })

            // TODO 文件导入的模板
            $("#importActivityModel").click(function () {
                window.location.href = "workbench/activity/importActivityModel";
            })

            // TODO 导入数据的按钮添加事件
            $("#importActivityBtn").click(function () {
                // 拿到文件的名字
                var fileName = $("#activityFile").val();
                var lastSuffix = fileName.substr(fileName.lastIndexOf(".") + 1).toUpperCase();
                if (lastSuffix != "XLS") {
                    alert("仅支持xls格式的文件")
                    return;
                }
                var file = $("#activityFile")[0].files[0];
                if (file.size > 1024 * 1024 * 5) {
                    alert("文件最大导入为5M")
                    return;
                }
                var formData = new FormData();
                // 文件上传必须使用multipartFile类型
                formData.append("multipartFile", file)

                $.ajax({
                    url: "workbench/activity/importActivityRowsByFile",
                    data: formData,
                    type: "POST",
                    dataType: "json",
                    processData: false,
                    contentType: false,
                    success: function (data) {
                        if (data.code == "1") {
                            alert(data.message)
                            $("#importActivityModal").modal("hide")
                            // 导入数据之后加载第一页
                            sendActivityRequestForPage(1, $("#activityDivForPage").bs_pagination('getOption', 'rowsPerPage'))
                            $("#activityFile").val('');
                        } else {
                            alert(data.message)
                            $("#importActivityModal").modal("show")
                        }
                    }
                })
            })

            // TODO 点击创建按钮弹出模态窗口
            $("#managerModalCreateBtn").click(function () {
                $("#createActivityModal").modal("show")
            })

            // TODO 给文本框加上日历插件功能
            $(".datetimepicker-createActivityFrom").datetimepicker({
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
                $("#activityBodyForPage input[type='checkbox']").prop("checked", this.checked)
            })

            // TODO 给动态生成的checked框绑定单击事件
            $("#activityBodyForPage").on("click", "input[type='checkbox']", function () {
                if ($("#activityBodyForPage input[type='checkbox']").size()
                    == $("#activityBodyForPage input[type='checkbox']:checked").size()) {
                    $("#allCheckRemark").prop("checked", true)
                } else {
                    $("#allCheckRemark").prop("checked", false)
                }
            })
        });

        // TODO 发送分页查询的请求的函数
        sendActivityRequestForPage = function (pageNo, pageSize) {
            var name = $("#ActivityNameForPage").val();
            var owner = $("#ActivityOwnerForPage").val();
            var start_date = $("#ActivityStartTimeForPage").val();
            var end_date = $("#ActivityEndTimeForPage").val();
            $.ajax({
                url: 'workbench/activity/queryByConditionForPage',
                type: 'POST',
                data: {
                    "name": name,
                    "owner": owner,
                    "start_date": start_date,
                    "end_date": end_date,
                    "pageNo": pageNo,
                    "pageSize": pageSize
                },
                dataType: 'json',
                success: function (data) {
                    var htmlStr = "";
                    $.each(data.activities, function (index, item) {
                        htmlStr += "<tr class=\"active\">";
                        htmlStr += "	<td><input type=\"checkbox\" value='" + item.id + "'/></td>";
                        htmlStr += "	<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='workbench/activity/toDetail?id=" + item.id + "';\">" + item.name + "</a></td>";
                        htmlStr += "	<td>" + item.cost + "万</td>";
                        htmlStr += "	<td>" + item.owner + "</td>";
                        htmlStr += "	<td>" + item.startDate + "</td>";
                        htmlStr += "	<td>" + item.endDate + "</td>";
                        htmlStr += "</tr>";
                    })

                    //给装分页查询容器值的body赋值
                    $("#activityBodyForPage").html(htmlStr);

                    //计算有多少页
                    var totalPages = 1;
                    if (data.totalRows % pageSize == 0) {
                        totalPages = data.totalRows / pageSize
                    } else {
                        totalPages = parseInt(data.totalRows / pageSize) + 1
                    }

                    //给分页插件准备的容器赋值
                    $("#activityDivForPage").bs_pagination({
                        currentPage: pageNo,
                        rowsPerPage: pageSize,
                        totalPages: totalPages,
                        totalRows: data.totalRows,
                        visiblePageLinks: 5,
                        showGoToPage: true,
                        showRowsPerPage: true,
                        showRowsInfo: true,
                        onChangePage: function (event, pageObj) {
                            sendActivityRequestForPage(pageObj.currentPage, pageObj.rowsPerPage);
                            $("#allCheckRemark").prop("checked", false);
                        }
                    });
                }
            })
        }
    </script>
</head>
<body>

<!-- 创建市场活动的模态窗口 -->
<div class="modal fade" id="createActivityModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel1">创建市场活动</h4>
            </div>
            <div class="modal-body">

                <form class="form-horizontal" role="form" id="createActivityForm">

                    <div class="form-group">
                        <label for="create-marketActivityOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-marketActivityOwner">
                                <option></option>
                                <c:forEach items="${userList}" var="user">
                                    <option value="${user.id}">${user.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <label for="create-marketActivityName" class="col-sm-2 control-label">名称<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-marketActivityName">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-startTime" class="col-sm-2 control-label">开始日期<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control datetimepicker-createActivityFrom"
                                   id="create-startTime" readonly>
                        </div>
                        <label for="create-endTime" class="col-sm-2 control-label">结束日期<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control datetimepicker-createActivityFrom"
                                   id="create-endTime" readonly>
                        </div>
                    </div>
                    <div class="form-group">

                        <label for="create-cost" class="col-sm-2 control-label">成本<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-cost" placeholder="单位（万）">
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="create-describe" class="col-sm-2 control-label">描述&nbsp;</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="create-describe"></textarea>
                        </div>
                    </div>
                    <span id="activityMsg" style="color: red;position: absolute;left: 180px"></span>
                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button id="saveActivityBtn" type="button" class="btn btn-primary">保存</button>
            </div>
        </div>
    </div>
</div>

<!-- 修改市场活动模态窗口 -->
<div class="modal fade" id="editActivityModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
            </div>
            <div class="modal-body">

                <form class="form-horizontal" role="form">
                    <input type="hidden" id="edit-id"/>
                    <div class="form-group">
                        <label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-marketActivityOwner">
                                <c:forEach items="${userList}" var="user">
                                    <option value="${user.id}">${user.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-marketActivityName" value="发传单">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-startTime" class="col-sm-2 control-label">开始日期<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control datetimepicker-createActivityFrom"
                                   id="edit-startTime" value="2020-10-10" readonly>
                        </div>
                        <label for="edit-endTime" class="col-sm-2 control-label">结束日期<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control datetimepicker-createActivityFrom" id="edit-endTime"
                                   value="2020-10-20" readonly>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-cost" class="col-sm-2 control-label">成本&nbsp;[万]<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-cost">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-describe" class="col-sm-2 control-label">描述&nbsp;</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="edit-describe"></textarea>
                        </div>
                    </div>

                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="editActivityBtn">更新</button>
            </div>
        </div>
    </div>
</div>

<!-- 导入市场活动模态窗口 -->
<div class="modal fade" id="importActivityModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel">导入市场活动</h4>
            </div>
            <div class="modal-body" style="height: 350px;">
                <div style="position: relative;top: 20px; left: 50px;">
                    请选择要上传的文件：<b style="color: gray;">【仅支持.xls】</b>
                </div>
                <div style="position: relative;top: 40px; left: 50px;">
                    <input type="file" id="activityFile">
                </div>
                <div style="position: relative; width: 400px; height: 320px; left: 45% ; top: -40px;">
                    <h3>&nbsp;&nbsp;&nbsp;重要提示：</h3>
                    <ul>
                        <li>操作仅针对Excel且后缀名为XLS的文件</li>
                        <li>给定文件的第一行将视为字段名</li>
                        <li>请确认您的文件大小不超过5MB</li>
                        <li>日期必须符合yyyy-MM-dd格式</li>
                        <li>默认情况下字符编码是UTF-8(统一码)</li>
                        <li>请确保您导入的文件使用的是正确的字符编码方式</li>
                        <li>建议您在导入真实数据前用测试文件测试文件导入功能</li>
                        <br/>
                        <br/>
                        <li>下载文件的模板 ===> <input type="button" id="importActivityModel" value="点我下载模板"></li>
                    </ul>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button id="importActivityBtn" type="button" class="btn btn-primary">导入</button>
            </div>
        </div>
    </div>
</div>

<div>
    <div style="position: relative; left: 10px; top: -10px;">
        <div class="page-header">
            <h3>市场活动列表</h3>
        </div>
    </div>
</div>

<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">

    <div style="width: 100%; position: absolute;top: 5px; left: 10px;">

        <!--条件查询搜索框-->
        <div class="btn-toolbar" role="toolbar" style="height: 80px;">
            <form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
                <!-- 名称 -->
                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">名称</div>
                        <input class="form-control" type="text" id="ActivityNameForPage">
                    </div>
                </div>
                <!-- 所有者 -->
                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">所有者</div>
                        <select class="form-control" id="ActivityOwnerForPage">
                            <option></option>
                            <c:forEach items="${userList}" var="user">
                                <option value="${user.id}">${user.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <!-- 开始日期 -->
                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">开始日期</div>
                        <input type="text" class="form-control datetimepicker-createActivityFrom"
                               id="ActivityStartTimeForPage" readonly>
                    </div>
                </div>
                <!-- 结束日期 -->
                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">结束日期</div>
                        <input type="text" class="form-control datetimepicker-createActivityFrom"
                               id="ActivityEndTimeForPage" readonly>
                    </div>
                </div>

                <button type="button" class="btn btn-default" id="queryActivityForPage">查询</button>
            </form>
        </div>

        <!-- 创建,修改,删除,上传,下载-->
        <div class="btn-toolbar" role="toolbar"
             style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
            <!--弹出/调用模态窗口的按钮-->
            <div class="btn-group" style="position: relative; top: 18%;">
                <button type="button"
                        class="btn btn-primary"
                        id="managerModalCreateBtn">
                    <span class="glyphicon glyphicon-plus"></span> 创建
                </button>
                <button type="button" class="btn btn-default" id="editActivityInformationBtn"><span
                        class="glyphicon glyphicon-pencil"></span> 修改
                </button>
                <button type="button" class="btn btn-danger" id="deleteActivityBtn"><span
                        class="glyphicon glyphicon-minus"></span> 删除
                </button>
            </div>
            <div class="btn-group" style="position: relative; top: 18%;">
                <button type="button" class="btn btn-default" data-toggle="modal" data-target="#importActivityModal">
                    <span class="glyphicon glyphicon-import"></span> 上传列表数据（导入）
                </button>
                <button id="exportActivityAllBtn" type="button" class="btn btn-default"><span
                        class="glyphicon glyphicon-export"></span> 下载列表数据（批量导出）
                </button>
                <button id="exportActivityXzBtn" type="button" class="btn btn-default"><span
                        class="glyphicon glyphicon-export"></span> 下载列表数据（选择导出）
                </button>
            </div>
        </div>

        <!--分页查询展示框-->
        <div style="position: relative;top: 10px;">
            <table class="table table-hover">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td><input type="checkbox" id="allCheckRemark"/></td>
                    <td>名称</td>
                    <td>市场活动成本</td>
                    <td>所有者</td>
                    <td>开始日期</td>
                    <td>结束日期</td>
                </tr>
                </thead>
                <tbody id="activityBodyForPage">
                </tbody>
            </table>

            <!-- 分页插件 -->
            <div id="activityDivForPage"></div>

        </div>
    </div>
</div>
</body>
</html>
