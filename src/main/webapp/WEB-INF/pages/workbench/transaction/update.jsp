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
            var id = "${transaction.id}"

            // TODO 根据交易找到公司信息,从而找到联系人的列表
            $.ajax({
                url: 'workbench/contacts/queryByTranscationId',
                async: false,
                type: 'post',
                data: {
                    "id":id,
                },
                dataType: 'json',
                success: function (data) {
                    var htmlStr = "<option></option>"
                    $.each(data.object, function (index, item) {
                        htmlStr += "<option value="+item.id+">"+item.fullname+"</option>"
                    })
                    $("#edit-contactsId").html(htmlStr);
                }
            })

            // TODO 页面加载拿到最新数据,修改文本参数,渲染页面
            $("#edit-contactsId").val("${transaction.contactsId}")
            $("#edit-transactionOwner").val("${transaction.owner}")
            $("#edit-transactionStage").val("${transaction.stage}")
            $("#edit-transactionType").val("${transaction.transactionType}")
            $("#edit-source").val("${transaction.source}")
            $("#edit-contactsId").val("${transaction.contactsId}")

            // TODO 可能性展示
            $("#edit-transactionStage").change(function () {
                // 拿到交易阶段的值
                var optionValue = $("#edit-transactionStage>option:selected").text();
                if (optionValue == '') {
                    return;
                }
                $.ajax({
                    url: 'workbench/transaction/optionValuePossible',
                    type: 'post',
                    data: {"optionValue": optionValue},
                    dataType: 'json',
                    success: function (data) {
                        $("#edit-possibility").val(data + "%")
                    }
                })
            })

            // TODO 发送保存交易的请求
            $("#editTranscationBtn").click(function () {
                // 收集参数
                var name = $("#edit-transactionName").val().trim();
                var money = $("#edit-amountOfMoney").val().trim();
                var contactsId = $("#edit-contactsId").val().trim();
                var owner = $("#edit-transactionOwner").val().trim();
                var transactionType = $("#edit-transactionType").val().trim();
                var stage = $("#edit-transactionStage").val().trim();
                var possibility = $("#edit-possibility").val();
                var expectedDate = $("#edit-expectedClosingDate").val().trim();
                var source = $("#edit-source").val().trim();
                var nextContactTime = $("#edit-nextContactTime").val().trim();
                var description = $("#edit-describe").val().trim();
                var contactSummary = $("#edit-contactSummary").val().trim();

                if (name == '') {
                    alert("交易名称不能为空");
                    return;
                }
                if (money == '') {
                    alert("交易金额不能为空");
                    return;
                }
                var regExp = /^(([1-9]\d*)|0)$/
                if (!regExp.test(money)) {
                    alert("交易只能为非负整数");
                    return;
                }
                if (contactsId == '') {
                    alert("联系人不能为空");
                    return;
                }
                if (owner == '') {
                    alert("交易所有者不能为空");
                    return;
                }
                if (transactionType == '') {
                    alert("业务类型不能为空");
                    return;
                }
                if (stage == '') {
                    alert("交易阶段不能为空");
                    return;
                }
                if (expectedDate == '') {
                    alert("预计成交日期不能为空");
                    return;
                }
                if (source == '') {
                    alert("交易来源不能为空");
                    return;
                }
                if (nextContactTime == '') {
                    alert("下次联系时间不能为空");
                    return;
                }

                // 发送请求
                $.ajax({
                    url: 'workbench/transaction/editTransaction',
                    type: 'post',
                    data: {
                        "id":id,
                        "owner": owner,
                        "money": money,
                        "name": name,
                        "expectedDate": expectedDate,
                        "stage": stage,
                        "possibility": possibility,
                        "transactionType": transactionType,
                        "source": source,
                        "contactsId": contactsId,
                        "description": description,
                        "contactSummary": contactSummary,
                        "nextContactTime": nextContactTime
                    },
                    dataType: 'json',
                    success: function (data) {
                        if (data.code == "1") {
                            window.location.href = 'workbench/transaction/toTranIndex';
                        } else {
                            alert("修改错误...")
                        }
                    }
                })
            })

            // TODO 点击取消则退出
            $("#cancelBtn").click(function (){
                window.location.href = 'workbench/transaction/toTranIndex';
            })

            // TODO 给文本框加上日历插件功能
            $(".datetimepicker-editTranFrom").datetimepicker({
                language: 'zh-CN',
                format: 'yyyy-mm-dd',
                minView: 'month',
                initialDate: new Date(),
                autoclose: true,
                todayBtn: true,
                clearBtn: true
            })
        })
    </script>
</head>
<body>

<div style="position:  relative; left: 30px;">
    <h3>修改交易</h3>

    <!-- 保存和取消按钮 -->
    <div style="position: relative; top: -40px; left: 70%;">
        <button type="button" class="btn btn-primary" id="editTranscationBtn">更新</button>
        <button type="button" class="btn btn-default" id="cancelBtn">取消</button>
    </div>
    <hr style="position: relative; top: -40px;">

</div>

<form class="form-horizontal" role="form" style="position: relative; top: -30px;">

    <div class="form-group">
        <!-- 1.1:交易名称 -->
        <label for="edit-transactionName" class="col-sm-2 control-label">交易名称<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" id="edit-transactionName" value="${transaction.name}" readonly>
        </div>

        <!-- 1.2:金额 -->
        <label for="edit-amountOfMoney" class="col-sm-2 control-label">交易金额&nbsp;[万]<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" id="edit-amountOfMoney" value="${transaction.money}">
        </div>
    </div>

    <div class="form-group">

        <!-- 2.1:联系人名称 -->
        <label for="edit-contactsId" class="col-sm-2 control-label">联系人名称<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <select class="form-control" id="edit-contactsId">
                <option></option>
                <c:forEach items="${contacts}" var="app">
                    <option value="${app.id}">${app.fullname}</option>
                </c:forEach>
            </select>
        </div>

        <!-- 2.2:所有者 -->
        <label for="edit-transactionOwner" class="col-sm-2 control-label">交易所有者<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <select class="form-control" id="edit-transactionOwner">
                <option></option>
                <c:forEach items="${userList}" var="u">
                    <option value="${u.id}">${u.name}</option>
                </c:forEach>
            </select>
        </div>
    </div>

    <div class="form-group">
        <!-- 3.1:业务类型 -->
        <label for="edit-transactionType" class="col-sm-2 control-label">业务类型<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <select class="form-control" id="edit-transactionType">
                <option></option>
                <c:forEach items="${transactionType}" var="tranType">
                    <option value="${tranType.id}">${tranType.value}</option>
                </c:forEach>
            </select>
        </div>

        <!-- 3.2:阶段 -->
        <label for="edit-transactionStage" class="col-sm-2 control-label">交易阶段<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <select class="form-control" id="edit-transactionStage">
                <option></option>
                <c:forEach items="${stage}" var="s">
                    <option value="${s.id}">${s.value}</option>
                </c:forEach>
            </select>
        </div>
    </div>

    <div class="form-group">

        <!-- 4.1:可能性 -->
        <label for="edit-possibility" class="col-sm-2 control-label">交易可能性<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" id="edit-possibility" readonly value="${transaction.possibility}">
        </div>

        <!-- 4.2:预计成交时间 -->
        <label for="edit-expectedClosingDate" class="col-sm-2 control-label">预计成交日期<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control datetimepicker-editTranFrom" id="edit-expectedClosingDate"
                   readonly value="${transaction.expectedDate}">
        </div>
    </div>

    <div class="form-group">
        <!-- 5.1:来源 -->
        <label for="edit-source" class="col-sm-2 control-label">交易来源<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <select class="form-control" id="edit-source">
                <option></option>
                <c:forEach items="${source}" var="sour">
                    <option value="${sour.id}">${sour.value}</option>
                </c:forEach>
            </select>
        </div>

        <!-- 5.2:下次联系时间 -->
        <label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control datetimepicker-editTranFrom" id="edit-nextContactTime" readonly
                   value=${transaction.nextContactTime}>
        </div>
    </div>

    <div class="form-group">
        <label for="edit-describe" class="col-sm-2 control-label">描述&nbsp;&nbsp;</label>
        <div class="col-sm-10" style="width: 70%;">
            <textarea class="form-control" rows="3" id="edit-describe">${transaction.description}</textarea>
        </div>
    </div>

    <div class="form-group">
        <label for="edit-contactSummary" class="col-sm-2 control-label">联系纪要&nbsp;&nbsp;</label>
        <div class="col-sm-10" style="width: 70%;">
            <textarea class="form-control" rows="3" id="edit-contactSummary">${transaction.contactSummary}</textarea>
        </div>
    </div>

    <div class="form-group">

    </div>

</form>
</body>
</html>
