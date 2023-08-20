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
        let contactsId = '';

        $(function () {

            // TODO 展开搜索市场活动的窗口
            $("#findMarketActivityA").click(function () {
                if (contactsId == '') {
                    alert("请先选择联系人");
                    return;
                }
                $.ajax({
                    url: 'workbench/transaction/fuzzyQueryForSave',
                    type: 'post',
                    data: {
                        "value": '',
                        "contactsId": contactsId
                    },
                    dataType: 'json',
                    success: function (data) {
                        var htmlStr = ""
                        $.each(data, function () {
                            htmlStr += "<tr>";
                            htmlStr += "    <td><input value=\'" + this.id + "\' activityName=\"" + this.name + "\" type=\"radio\" name=\"activity\"/></td>";
                            htmlStr += "    <td>" + this.name + "</td>";
                            htmlStr += "    <td>" + this.startDate + "</td>";
                            htmlStr += "    <td>" + this.endDate + "</td>";
                            htmlStr += "    <td>" + this.owner + "</td>";
                            htmlStr += "</tr>";
                        })
                        if(htmlStr==''){
                            alert("请确保该联系人关联过至少一个市场活动");
                            return;
                        }
                        $("#fuzzyTbody").html(htmlStr);
                        $("#findMarketActivity").modal("show")
                    }
                })
            })

            // TODO 输入内容,搜索市场活动信息
            $("#fuzzyQueryInput").keyup(function () {
                var value = this.value.trim();
                $.ajax({
                    url: 'workbench/transaction/fuzzyQueryForSave',
                    type: 'post',
                    data: {
                        "value": value,
                        "contactsId": contactsId
                    },
                    dataType: 'json',
                    success: function (data) {
                        var htmlStr = ""
                        $.each(data, function () {
                            htmlStr += "<tr>";
                            htmlStr += "    <td><input value=\'" + this.id + "\' activityName=\"" + this.name + "\" type=\"radio\" name=\"activity\"/></td>";
                            htmlStr += "    <td>" + this.name + "</td>";
                            htmlStr += "    <td>" + this.startDate + "</td>";
                            htmlStr += "    <td>" + this.endDate + "</td>";
                            htmlStr += "    <td>" + this.owner + "</td>";
                            htmlStr += "</tr>";
                        })
                        $("#fuzzyTbody").html(htmlStr);
                    }
                })
            })

            // TODO 选中了某个市场活动
            $("#fuzzyTbody").on("click", "input", function () {
                var activityId = this.value;
                var activityName = $(this).attr("activityName");
                $("#create-activitySrcId").val(activityId);
                $("#create-activitySrc").val(activityName);
                $("#findMarketActivity").modal("hide")
            })

            // TODO 可能性展示
            $("#create-transactionStage").change(function () {
                // 拿到交易阶段的值
                var optionValue = $("#create-transactionStage>option:selected").text();
                if (optionValue == '') {
                    return;
                }
                $.ajax({
                    url: 'workbench/transaction/optionValuePossible',
                    type: 'post',
                    data: {"optionValue": optionValue},
                    dataType: 'json',
                    success: function (data) {
                        $("#create-possibility").val(data + "%")
                    }
                })
            })

            // TODO 发送保存交易的请求
            $("#saveTranscationBtn").click(function () {
                // 收集参数
                var owner = $("#create-transactionOwner").val().trim();
                var money = $("#create-amountOfMoney").val().trim();
                var name = $("#create-transactionName").val().trim();
                var expectedDate = $("#create-expectedClosingDate").val().trim();
                var customerName = $("#create-accountName").val().trim();
                var stage = $("#create-transactionStage").val().trim();
                var transactionType = $("#create-transactionType").val().trim();
                var source = $("#create-clueSource").val().trim();
                var possibility = $("#create-possibility").val();
                var activityId = $("#create-activitySrcId").val().trim();
                var contactsId = $("#create-contactsId").val();
                var description = $("#create-describe").val().trim();
                var contactSummary = $("#create-contactSummary").val().trim();
                var nextContactTime = $("#create-nextContactTime").val().trim();

                if (customerName == '') {
                    alert("所属公司不能为空");
                    return;
                }
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
                if (contactsId == '') {
                    alert("联系人不能为空");
                    return;
                }
                if (activityId == '') {
                    alert("市场活动源不能为空");
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
                    url: 'workbench/transaction/saveTransaction',
                    type: 'post',
                    data: {
                        "owner": owner,
                        "money": money,
                        "name": name,
                        "expectedDate": expectedDate,
                        "customerName": customerName,
                        "stage": stage,
                        "possibility": possibility,
                        "transactionType": transactionType,
                        "source": source,
                        "activityId": activityId,
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
                            alert("保存错误...")
                        }
                    }
                })
            })

            // TODO 点击取消,跳转回去
            $("#cancelBtn").click(function () {
                window.location.href = 'workbench/transaction/toTranIndex';
            })

            // TODO 当公司信息发生变化的时候,用于判断联系人信息
            $("#create-accountName").change(function () {
                customerName = $("#create-accountName").val();
                if(customerName==''){
                    $("#create-contactsId").html("<option></option>")
                    return;
                }
                $.ajax({
                    url: 'workbench/contacts/queryByCustomerName',
                    type: 'post',
                    data: {
                        "customerName": customerName
                    },
                    dataType: 'json',
                    success: function (data) {
                        if(data.object.length>=1) {
                            var htmlStr = "<option></option>"
                            $.each(data.object, function (index, item) {
                                htmlStr += "<option value=" + item.id + ">" + item.fullname + "</option>"
                            })
                            $("#create-contactsId").html(htmlStr);
                        }else {
                            contactsId = '';
                            var htmlStr = "<option value=''>该公司暂无联系人，无法创建交易</option>"
                            $("#create-contactsId").html(htmlStr);
                        }
                    }
                })
            })

            // TODO 当联系人发生变化的时候,用于判断市场活动源头
            $("#create-contactsId").change(function () {
                contactsId = $("#create-contactsId").val();
            })

            // TODO 给文本框加上日历插件功能
            $(".datetimepicker-createTranFrom").datetimepicker({
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

<!-- 查找市场活动 -->
<div class="modal fade" id="findMarketActivity" role="dialog">
    <div class="modal-dialog" role="document" style="width: 80%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">查找市场活动</h4>
            </div>
            <div class="modal-body">
                <div class="btn-group" style="position: relative; top: 18%; left: 8px;">
                    <form class="form-inline" role="form">
                        <div class="form-group has-feedback">
                            <input id="fuzzyQueryInput" type="text" class="form-control" style="width: 300px;"
                                   placeholder="请输入市场活动名称，支持模糊查询">
                            <span class="glyphicon glyphicon-search form-control-feedback"></span>
                        </div>
                    </form>
                </div>
                <table id="activityTable3" class="table table-hover"
                       style="width: 900px; position: relative;top: 10px;">
                    <thead>
                    <tr style="color: #B3B3B3;">
                        <td></td>
                        <td>名称</td>
                        <td>开始日期</td>
                        <td>结束日期</td>
                        <td>所有者</td>
                    </tr>
                    </thead>
                    <tbody id="fuzzyTbody">

                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<div style="position:  relative; left: 30px;">
    <h3>创建交易</h3>

    <!-- 保存和取消按钮 -->
    <div style="position: relative; top: -40px; left: 70%;">
        <button type="button" class="btn btn-primary" id="saveTranscationBtn">保存</button>
        <button type="button" class="btn btn-default" id="cancelBtn">取消</button>
    </div>
    <hr style="position: relative; top: -40px;">

</div>

<form class="form-horizontal" role="form" style="position: relative; top: -30px;">

    <div class="form-group">
        <!-- 1.1:所属公司 -->
        <label for="create-accountName" class="col-sm-2 control-label">所属公司<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <select class="form-control" id="create-accountName">
                <option></option>
                <c:forEach items="${customers}" var="app">
                    <option value="${app.id}">${app.name}</option>
                </c:forEach>
            </select>
        </div>

        <!-- 1.2:交易名称 -->
        <label for="create-transactionName" class="col-sm-2 control-label">交易名称<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" id="create-transactionName">
        </div>
    </div>

    <div class="form-group">
        <!-- 2.1:金额 -->
        <label for="create-amountOfMoney" class="col-sm-2 control-label">交易金额<span style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" id="create-amountOfMoney" placeholder="单位（万）">
        </div>

        <!-- 2.2:所有者 -->
        <label for="create-transactionOwner" class="col-sm-2 control-label">交易所有者<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <select class="form-control" id="create-transactionOwner">
                <option></option>
                <c:forEach items="${userList}" var="u">
                    <option value="${u.id}">${u.name}</option>
                </c:forEach>
            </select>
        </div>
    </div>

    <div class="form-group">
        <!-- 3.1:业务类型 -->
        <label for="create-transactionType" class="col-sm-2 control-label">业务类型<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <select class="form-control" id="create-transactionType">
                <option></option>
                <c:forEach items="${transactionType}" var="tranType">
                    <option value="${tranType.id}">${tranType.value}</option>
                </c:forEach>
            </select>
        </div>

        <!-- 3.2:阶段 -->
        <label for="create-transactionStage" class="col-sm-2 control-label">交易阶段<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <select class="form-control" id="create-transactionStage">
                <option></option>
                <c:forEach items="${stage}" var="s">
                    <option value="${s.id}">${s.value}</option>
                </c:forEach>
            </select>
        </div>
    </div>

    <div class="form-group">

        <!-- 4.1:可能性 -->
        <label for="create-possibility" class="col-sm-2 control-label">交易可能性<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control" id="create-possibility" readonly>
        </div>

        <!-- 4.2:预计成交时间 -->
        <label for="create-expectedClosingDate" class="col-sm-2 control-label">预计成交日期<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control datetimepicker-createTranFrom" id="create-expectedClosingDate"
                   readonly>
        </div>

    </div>

    <div class="form-group">
        <!-- 5.1:联系人名称 -->
        <label for="create-contactsId" class="col-sm-2 control-label">联系人名称<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <select class="form-control" id="create-contactsId">
                <option></option>
                <c:forEach items="${contacts}" var="app">
                    <option value="${app.id}">${app.fullname}</option>
                </c:forEach>
            </select>
        </div>

        <!-- 5.2:市场活动源 -->
        <label for="create-activitySrc" class="col-sm-2 control-label">市场活动源&nbsp;<a href="javascript:void(0);"
                                                                                     id="findMarketActivityA"><span
                class="glyphicon glyphicon-search"></span></a></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="hidden" id="create-activitySrcId">
            <input type="text" class="form-control" id="create-activitySrc" readonly>
        </div>
    </div>

    <div class="form-group">
        <!-- 6.1:来源 -->
        <label for="create-clueSource" class="col-sm-2 control-label">交易来源<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <select class="form-control" id="create-clueSource">
                <option></option>
                <c:forEach items="${source}" var="sour">
                    <option value="${sour.id}">${sour.value}</option>
                </c:forEach>
            </select>
        </div>

        <!-- 6.2:下次联系时间 -->
        <label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间<span
                style="font-size: 15px; color: red;">*</span></label>
        <div class="col-sm-10" style="width: 300px;">
            <input type="text" class="form-control datetimepicker-createTranFrom" id="create-nextContactTime" readonly>
        </div>
    </div>

    <div class="form-group">
        <label for="create-describe" class="col-sm-2 control-label">描述&nbsp;&nbsp;</label>
        <div class="col-sm-10" style="width: 70%;">
            <textarea class="form-control" rows="3" id="create-describe"></textarea>
        </div>
    </div>

    <div class="form-group">
        <label for="create-contactSummary" class="col-sm-2 control-label">联系纪要&nbsp;&nbsp;</label>
        <div class="col-sm-10" style="width: 70%;">
            <textarea class="form-control" rows="3" id="create-contactSummary"></textarea>
        </div>
    </div>

    <div class="form-group">

    </div>

</form>
</body>
</html>
