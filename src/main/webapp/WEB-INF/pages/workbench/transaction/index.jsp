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

            // TODO 页面加载查询
            sendTranscationRequestForPage(1, 10);

            // TODO 点击搜索查询
            $("#findTranInfoBtn").click(function () {
                sendTranscationRequestForPage(1, $("#customerDivForPage").bs_pagination('getOption', 'rowsPerPage'));
                $("#allCheckRemark").prop("checked", false);
            })

            // TODO 给交易的删除按钮添加点击事件函数
            $("#deleteTranBtn").click(function () {

                var idsCheckbox = $("#transcationBodyForPage input[type='checkbox']:checked");
                if (idsCheckbox.size() <= 0) {
                    alert("每次至少删除一条交易信息");
                    return;
                }
                if (!window.confirm("是否删除所选交易信息")) {
                    return;
                }
                var ids = ""
                $.each(idsCheckbox, function () {
                    ids += "id=" + this.value + "&"
                })
                ids = ids.substr(0, ids.length - 1);

                //发送请求
                $.ajax({
                    url: 'workbench/transaction/deleteTranscationByIds',
                    type: 'POST',
                    data: ids,
                    dataType: 'json',
                    success: function (data) {
                        if (data.code == 0) {
                            alert(data.message)
                        } else {
                            // 删除之后到第一页
                            sendTranscationRequestForPage(1, $("#transcationDivForPage").bs_pagination('getOption', 'rowsPerPage'));
                            $("#allCheckRemark").prop("checked", false)
                        }
                    }
                })
            })

            // TODO 给交易的修改按钮添加点击事件函数，先获取数据并渲染
            $("#managerModalUpdateBtn").click(function () {
                var editCheckbox = $("#transcationBodyForPage input[type='checkbox']:checked");
                if (editCheckbox.size() == 0) {
                    alert("你还没有选中要修改的数据");
                    return;
                }
                if (editCheckbox.size() != 1) {
                    alert("每次只能修改一条交易信息");
                    return;
                }
                var id = editCheckbox[0].value;

                // 查看这个线索是否已经成交了
                $.ajax({
                    url: 'workbench/transaction/queryIsComplete',
                    type: 'POST',
                    data: {
                        "id":id
                    },
                    dataType: 'json',
                    success: function (data) {
                        if (data.code == 1) {
                            if(data.object == true){
                                alert("交易已经成交，无法修改");
                            }else {
                                window.location.href = "workbench/transaction/toSaveIndex?id=" + id;
                            }
                        } else {
                            alert("查询交易阶段失败")
                        }
                    }
                })

            })

            // TODO 给全选的checked框按钮绑定相对应的事件
            $("#allCheckRemark").click(function () {
                $("#transcationBodyForPage input[type='checkbox']").prop("checked", this.checked)
            })

            // TODO 给动态生成的checked框绑定单击事件
            $("#transcationBodyForPage").on("click", "input[type='checkbox']", function () {
                if ($("#transcationBodyForPage input[type='checkbox']").size()
                    == $("#transcationBodyForPage input[type='checkbox']:checked").size()) {
                    $("#allCheckRemark").prop("checked", true)
                } else {
                    $("#allCheckRemark").prop("checked", false)
                }
            })

        });

        // TODO 发送分页查询的请求的函数
        sendTranscationRequestForPage = function (pageNo, pageSize) {
            var name = $("#transcationNameForPage").val().trim();
            var customerId = $("#customerNameForPage").val().trim();
            var contactsId = $("#contactsNameForPage").val().trim();
            var source = $("#sourceForPage").val();
            var transactionType = $("#typeForPage").val();
            var stage = $("#stageForPage").val();
            var owner = $("#ownerForPage").val();

            $.ajax({
                url: 'workbench/transcation/queryByConditionForPage',
                type: 'POST',
                data: {
                    "name": name,
                    "customerId": customerId,
                    "contactsId": contactsId,
                    "owner": owner,
                    "source": source,
                    "transactionType": transactionType,
                    "stage": stage,
                    "pageNo": pageNo,
                    "pageSize": pageSize
                },
                dataType: 'json',
                success: function (data) {
                    var htmlStr = "";
                    $.each(data.transactions, function (index, item) {
                        htmlStr += "<tr class=\"active\">";
                        htmlStr += "	<td><input type=\"checkbox\" value='" + item.id + "'/></td>";
                        htmlStr += "	<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='workbench/transaction/showTranDetail?id=" + item.id + "';\">" + item.name + "</a></td>";
                        htmlStr += "	<td>" + item.customerId + "</td>";
                        htmlStr += "	<td>" + item.contactsId + "</td>";
                        htmlStr += "	<td>" + item.money + "万</td>";
                        htmlStr += "	<td>" + item.stage + "</td>";
                        htmlStr += "	<td>" + item.transactionType + "</td>";
                        htmlStr += "	<td>" + item.source + "</td>";
                        htmlStr += "	<td>" + item.owner + "</td>";
                        htmlStr += "</tr>";
                    })

                    //给装分页查询容器值的body赋值
                    $("#transcationBodyForPage").html(htmlStr);

                    //计算有多少页
                    var totalPages = 1;
                    if (data.totalRows % pageSize == 0) {
                        totalPages = data.totalRows / pageSize
                    } else {
                        totalPages = parseInt(data.totalRows / pageSize) + 1
                    }

                    //给分页插件准备的容器赋值
                    $("#transcationDivForPage").bs_pagination({
                        currentPage: pageNo,
                        rowsPerPage: pageSize,
                        totalPages: totalPages,
                        totalRows: data.totalRows,
                        visiblePageLinks: 5,
                        showGoToPage: true,
                        showRowsPerPage: true,
                        showRowsInfo: true,
                        onChangePage: function (event, pageObj) {
                            sendTranscationRequestForPage(pageObj.currentPage, pageObj.rowsPerPage);
                            $("#allCheckRemark").prop("checked", false);
                        }
                    });
                }
            })
        }

    </script>
</head>
<body>
<div>
    <div style="position: relative; left: 10px; top: -10px;">
        <div class="page-header">
            <h3>交易列表</h3>
        </div>
    </div>
</div>

<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">

    <div style="width: 100%; position: absolute;top: 5px; left: 10px;">

        <div class="btn-toolbar" role="toolbar" style="height: 80px;">
            <form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">

                <!-- 交易名称 -->
                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">交易名称</div>
                        <input class="form-control" type="text" id="transcationNameForPage">
                    </div>
                </div>

                <!-- 公司名称 -->
                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">公司名称</div>
                        <input class="form-control" type="text" id="customerNameForPage">
                    </div>
                </div>

                <!-- 联系人名称 -->
                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">联系人名称</div>
                        <input class="form-control" type="text" id="contactsNameForPage">
                    </div>
                </div>

                <br/>
                <!-- 来源 -->
                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">来源</div>
                        <select class="form-control" id="sourceForPage">
                            <option></option>
                            <c:forEach items="${source}" var="s">
                                <option value="${s.id}">${s.value}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <!-- 类型 -->
                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">类型</div>
                        <select class="form-control" id="typeForPage">
                            <option></option>
                            <c:forEach items="${transactionType}" var="tranType">
                                <option value="${tranType.id}">${tranType.value}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <!-- 阶段 -->
                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">阶段</div>
                        <select class="form-control" id="stageForPage">
                            <option></option>
                            <c:forEach items="${stage}" var="s">
                                <option value="${s.id}">${s.value}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <!-- 所有者 -->
                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">所有者</div>
                        <select class="form-control" id="ownerForPage">
                            <option></option>
                            <c:forEach items="${users}" var="s">
                                <option value="${s.id}">${s.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <input type="button" id="findTranInfoBtn" class="btn btn-default" value="查询"></input>

            </form>
        </div>
        <div class="btn-toolbar" role="toolbar"
             style="background-color: #F7F7F7; height: 50px; position: relative;top: 10px;">
            <div class="btn-group" style="position: relative; top: 18%;">
                <button type="button" class="btn btn-primary"
                        onclick="window.location.href='workbench/transaction/toSaveIndex';"><span
                        class="glyphicon glyphicon-plus"></span> 创建
                </button>

                <button type="button" class="btn btn-default" id="managerModalUpdateBtn"><span
                        class="glyphicon glyphicon-pencil"></span> 修改
                </button>

                <button type="button" class="btn btn-danger" id="deleteTranBtn"><span
                        class="glyphicon glyphicon-minus"></span> 删除
                </button>
            </div>


        </div>
        <div style="position: relative;top: 10px;">
            <table class="table table-hover">

                <!-- 头部信息 -->
                <thead>
                <tr style="color: #B3B3B3;">
                    <td><input type="checkbox" id="allCheckRemark"></td>
                    <td>交易名称</td>
                    <td>客户名称</td>
                    <td>联系人名称</td>
                    <td>交易金额</td>
                    <td>阶段</td>
                    <td>类型</td>
                    <td>来源</td>
                    <td>所有者</td>

                </tr>
                </thead>

                <!-- 内容 -->
                <tbody id="transcationBodyForPage">

                </tbody>
            </table>

            <!-- 分页插件 -->
            <div id="transcationDivForPage"></div>

        </div>
    </div>

</div>
</body>
</html>
