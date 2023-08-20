<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String url = "" + request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()
            + request.getContextPath() + "/";
%>
<!DOCTYPE html>
<html>
<head>
    <base href="<%=url%>">
    <meta charset="UTF-8">

    <link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>
    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
    <link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css"
          rel="stylesheet"/>
    <script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
    <script type="text/javascript"
            src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

    <script type="text/javascript">
        let num = 0;
        let flag = false;
        $(function () {

            // TODO 看转换线索的时候是不是需要创建交易
            $("#isCreateTransaction").click(function () {
                // TODO 发送请求看线索是不是关联过市场活动
                $.ajax({
                    url: "workbench/clue/isRelation",
                    type: "post",
                    data: {
                        "clueId": "${clue.id}"
                    },
                    dataType: 'json',
                    success: function (data) {
                        if (data.code != "1") {
                            alert("请先关联市场活动");
                            window.location.href="workbench/clue/toDetail?id=${clue.id}"
                        }else {
                            num++;
                            if (num % 2 == 1) {
                                // 展现创建交易的窗口
                                flag = true;
                                $("#create-transaction2").show(200);
                            } else {
                                // 不展现创建交易的窗口
                                flag = false;
                                $("#create-transaction2").hide(200);
                            }
                        }
                    }
                })
            });

            // TODO 点击取消则退出
            $("#clueConvertCanalBtn").click(function () {
                window.location.href = "workbench/clue/toIndex";
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

            // TODO 点击搜索,查询跟自己关联了的市场活动信息
            $("#fuzzyQueryConvertText").keyup(function () {
                var clueId = "${clue.id}";
                var fuzzyText = $("#fuzzyQueryConvertText").val().trim();
                $.ajax({
                    url: "workbench/clue/fuzzyQueryForConvert",
                    type: "post",
                    data: {
                        "clueId": clueId,
                        "fuzzyText": fuzzyText
                    },
                    dataType: 'json',
                    success: function (data) {
                        if (data.code == "1") {
                            var htmlStr = ""
                            $.each(data.object, function () {
                                htmlStr += "<tr>";
                                htmlStr += "	<td><input type=\"radio\" activityName=\"" + this.name + "\"  value=\'" + this.id + "\' name=\"activity\"/></td>";
                                htmlStr += "	<td>" + this.name + "</td>";
                                htmlStr += "	<td>" + this.startDate + "</td>";
                                htmlStr += "	<td>" + this.endDate + "</td>";
                                htmlStr += "	<td>" + this.owner + "</td>";
                                htmlStr += "</tr>";
                            })

                            $("#fuzzyConvertTBody").html(htmlStr);
                        }
                    }
                })
            })

            // TODO 查询跟自己关联了的市场活动信息
            $("#fuzzyQueryA").click(function () {
                $("#searchActivityModal").modal("show");

                // 发送请求，查看自己已经关联的市场活动信息
                var clueId = "${clue.id}";
                var fuzzyText = $("#fuzzyQueryConvertText").val().trim();
                $.ajax({
                    url: "workbench/clue/fuzzyQueryForConvert",
                    type: "post",
                    data: {
                        "clueId": clueId,
                        "fuzzyText": fuzzyText
                    },
                    dataType: 'json',
                    success: function (data) {
                        if (data.code == "1") {

                            var htmlStr = ""
                            $.each(data.object, function () {
                                htmlStr += "<tr>";
                                htmlStr += "	<td><input type=\"radio\" activityName=\"" + this.name + "\"  value=\'" + this.id + "\' name=\"activity\"/></td>";
                                htmlStr += "	<td>" + this.name + "</td>";
                                htmlStr += "	<td>" + this.startDate + "</td>";
                                htmlStr += "	<td>" + this.endDate + "</td>";
                                htmlStr += "	<td>" + this.owner + "</td>";
                                htmlStr += "</tr>";
                            })
                            $("#fuzzyConvertTBody").html(htmlStr);
                        }
                    }
                })
            })

            // TODO 选中某条市场活动的数据了
            $("#fuzzyConvertTBody").on("click", "input[type='radio']", function () {
                $("#activityIDForFuzzy").val(this.value)
                $("#activity").val($(this).attr("activityName"))
                $("#searchActivityModal").modal("hide");
            })

            // TODO 给转换按钮添加事件
            $("#clueConvertBtn").click(function () {

                //获取参数
                var clueId = "${clue.id}";
                var isCreateTran = flag;
                var money = $("#amountOfMoney").val();
                var name = $("#tradeName").val();
                var expectedDate = $("#expectedClosingDate").val();
                var nextContactTime = $("#nextContactTime").val();
                var stage = $("#stage").val();
                var source = $("#source").val();
                var activityId = $("#activityIDForFuzzy").val();
                var transcationType = $("#transcationType").val();
                var possibility = $("#possibility").val();

                if(flag) {
                    if (transcationType == '') {
                        alert("业务类型不能为空");
                        return;
                    }

                    if (money == '') {
                        alert("金额不能为空");
                        return;
                    }

                    var regExp = /^(([1-9]\d*)|0)$/
                    if (!regExp.test(money)) {
                        alert("金额只能为非负整数")
                        return;
                    }

                    if (name == '') {
                        alert("交易名称不能为空");
                        return;
                    }

                    if (stage == '') {
                        alert("阶段不能为空");
                        return;
                    }

                    if(source==''){
                        alert("来源信息不能为空")
                        return;
                    }

                    if (expectedDate == '') {
                        alert("预计成交日期不能为空");
                        return;
                    }

                    if (nextContactTime == '') {
                        alert("下次联系时间不能为空");
                        return;
                    }

                    if (activityId == '') {
                        alert("市场活动源不能为空");
                        return;
                    }
                }

                //发送请求
                $.ajax({
                    url: "workbench/clue/clueConvertByConvertBtn",
                    type: "post",
                    data: {
                        "clueId": clueId,
                        "isCreateTran": isCreateTran,
                        "money": money,
                        "name": name,
                        "expectedDate": expectedDate,
                        "nextContactTime":nextContactTime,
                        "stage": stage,
                        "source":source,
                        "activityId": activityId,
                        "transcationType": transcationType,
                        "possibility": possibility
                    },
                    dataType: 'json',
                    success: function (data) {
                        if (data.code == "1") {
                            window.location.href = "workbench/clue/toIndex"
                        } else {
                            alert("转换失败...");
                        }
                    }
                })

            })

            // TODO 可能性展示
            $("#stage").change(function () {
                // 拿到交易阶段的值
                var optionValue = $("#stage>option:selected").text();
                if (optionValue == '') {
                    return;
                }
                $.ajax({
                    url: 'workbench/transaction/optionValuePossible',
                    type: 'post',
                    data: {"optionValue": optionValue},
                    dataType: 'json',
                    success: function (data) {
                        $("#possibility").val(data + "%")
                    }
                })
            })
        });
    </script>

</head>
<body>
<!-- TODO 搜索市场活动的模态窗口 -->
<div class="modal fade" id="searchActivityModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 90%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">搜索市场活动</h4>
            </div>
            <div class="modal-body">
                <div class="btn-group" style="position: relative; top: 18%; left: 8px;">
                    <form class="form-inline" role="form">
                        <div class="form-group has-feedback">
                            <input id="fuzzyQueryConvertText" type="text" class="form-control" style="width: 300px;"
                                   placeholder="请输入市场活动名称，支持模糊查询">
                            <span class="glyphicon glyphicon-search form-control-feedback"></span>
                        </div>
                    </form>
                </div>

                <table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
                    <thead>
                    <tr style="color: #B3B3B3;">
                        <td></td>
                        <td>名称</td>
                        <td>开始日期</td>
                        <td>结束日期</td>
                        <td>所有者</td>
                        <td></td>
                    </tr>
                    </thead>
                    <tbody id="fuzzyConvertTBody">

                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<div id="title" class="page-header" style="position: relative; left: 20px;">
    <h3>&nbsp;&nbsp;&nbsp;转换线索&nbsp;<small>${clue.fullname}${clue.appellation}&nbsp;--&nbsp;${clue.company}</small></h3>
</div>
<br/>
<div id="create-customer" style="position: relative; left: 40px; height: 35px;">
    <h4>新建客户：<b>${clue.company}</b></h4>
</div>

<div id="create-contact" style="position: relative; left: 40px; height: 35px;">
    <h4>新建联系人：<b>${clue.fullname}${clue.appellation}</b></h4>
</div>
<div id="owner" style="position: relative; left: 40px; height: 35px;">
    <h4>记录的所有者：<b>${clue.owner}</b></h4>
</div>
<div id="create-transaction1" style="position: relative; left: 40px; height: 35px; top: 25px;">
    <b><input type="button" id="isCreateTransaction" value="为客户创建交易"></b>
</div>
<br/>

<!-- TODO 创建交易的窗口 -->
<div id="create-transaction2"
     style="position: relative; left: 40px; top: 20px; width: 80%; background-color: #F7F7F7; display: none;">
    <form>
        <div class="form-group" style="width: 400px; position: relative; left: 20px;">
            <label for="transcationType">业务类型<span style="font-size: 15px; color: red;">*</span></label>
            <select id="transcationType" class="form-control">
                <option></option>
                <c:forEach items="${transcationType}" var="item">
                    <option value="${item.id}">${item.value}</option>
                </c:forEach>
            </select>
        </div>
        <div class="form-group" style="width: 400px; position: relative; left: 20px;">
            <label for="amountOfMoney">金额<span
                    style="font-size: 15px; color: red;">*</span></label>
            <input type="text" class="form-control" id="amountOfMoney">
        </div>

        <div class="form-group" style="width: 400px;position: relative; left: 20px;">
            <label for="tradeName">交易名称<span
                    style="font-size: 15px; color: red;">*</span></label>
            <input type="text" class="form-control" id="tradeName">
        </div>

        <div class="form-group" style="width: 400px;position: relative; left: 20px;">
            <label for="stage">阶段<span
                    style="font-size: 15px; color: red;">*</span></label>
            <select id="stage" class="form-control">
                <option></option>
                <c:forEach items="${stage}" var="st">
                    <option value="${st.id}">${st.value}</option>
                </c:forEach>
            </select>
        </div>

        <div class="form-group" style="width: 400px;position: relative; left: 20px;">
            <label for="source">来源<span
                    style="font-size: 15px; color: red;">*</span></label>
            <select id="source" class="form-control">
                <option></option>
                <c:forEach items="${source}" var="st">
                    <option value="${st.id}">${st.value}</option>
                </c:forEach>
            </select>
        </div>

        <div class="form-group" style="width: 400px; position: relative; left: 20px;">
            <label for="possibility">成交可能性<span
                    style="font-size: 15px; color: red;">*</span></label>
            <input type="text" class="form-control" id="possibility" readonly>
        </div>

        <div class="form-group" style="width: 400px;position: relative; left: 20px;">
            <label for="expectedClosingDate">预计成交日期<span
                    style="font-size: 15px; color: red;">*</span></label>
            <input type="text" class="form-control datetimepicker-createActivityFrom" id="expectedClosingDate" readonly>
        </div>

        <div class="form-group" style="width: 400px;position: relative; left: 20px;">
            <label for="nextContactTime">下次联系时间<span
                    style="font-size: 15px; color: red;">*</span></label>
            <input type="text" class="form-control datetimepicker-createActivityFrom" id="nextContactTime" readonly>
        </div>

        <div class="form-group" style="width: 400px;position: relative; left: 20px;">
            <label for="activity">市场活动源<span
                    style="font-size: 15px; color: red;">*</span>&nbsp;&nbsp;<a href="javascript:void(0);"
                                                                                id="fuzzyQueryA"
                                                                                style="text-decoration: none;"><span
                    class="glyphicon glyphicon-search"></span></a></label>
            <!-- 隐藏域,存的是市场活动的ID -->
            <input type="hidden" id="activityIDForFuzzy">
            <input type="text" class="form-control" id="activity" placeholder="点击上面搜索" readonly>
        </div>
    </form>
</div>

<div id="operation" style="position: relative; left: 40px; height: 10px; top: 30px;">
    <input id="clueConvertBtn" class="btn btn-primary" type="button" value="转换">
    &nbsp;&nbsp;&nbsp;&nbsp;
    <input id="clueConvertCanalBtn" class="btn btn-default" type="button" value="取消">
</div>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
</body>
</html>
