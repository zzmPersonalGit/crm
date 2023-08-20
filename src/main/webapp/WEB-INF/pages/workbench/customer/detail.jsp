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

        //默认情况下取消和保存按钮是隐藏的
        var cancelAndSaveBtnDefault = true;
        var customerId = "${customer.id}"

        $(function () {

            // TODO 查询交易的信息
            queryTranInfo(customerId)

            // TODO 查询联系人信息
            queryContactsInfo(customerId)

            // TODO 保存客户备注的按钮
            $("#saveCustomerRemarkBtn").click(function () {

                var noteContent = $("#remark").val().trim();
                var customerId = "${customer.id}";
                if (noteContent == null || noteContent == '') {
                    alert("备注不能为空...")
                    return;
                }

                $.ajax({
                    url: 'workbench/customer/createRemarkDetail',
                    type: 'POST',
                    data: {
                        "customerId": customerId,
                        "noteContent": noteContent
                    },
                    dataType: 'json',
                    success: function (data) {
                        if (data.code = "1") {
                            var htmlStr = "";
                            htmlStr += "<div id='div_${remark.id}' class=\"remarkDiv\" style=\"height: 60px;\">";
                            htmlStr += "	<img title=\"${customer.name}\" src=\"image/user-thumbnail.png\" style=\"width: 30px; height:30px;\">";
                            htmlStr += "	<div style=\"position: relative; top: -40px; left: 40px;\" >";
                            htmlStr += "	<h5>" + data.object.noteContent + "</h5>";
                            htmlStr += "		<font color=\"gray\">客户</font> <font color=\"gray\">-</font> <b>${customer.name}</b> " +
                                "<small editNameSmall=\"edit\" style=\"color: gray;\">&nbsp;&nbsp;&nbsp;" + data.object.createTime + "&nbsp;&nbsp;由 ${sessionScope.loginUser.name} 创建</small>";
                            htmlStr += "		<div style=\"position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;\">";
                            htmlStr += "			<a class=\"myHref\" name=\"editA\" remarkId=\"" + data.object.id + "\" href=\"javascript:void(0);\"><span class=\"glyphicon glyphicon-edit\" " +
                                "style=\"font-size: 20px; color: #E6E6E6;\"></span></a>";
                            htmlStr += "			&nbsp;&nbsp;&nbsp;&nbsp;";
                            htmlStr += "			<a class=\"myHref\" name=\"deleteA\" remarkId=\"" + data.object.id + "\" href=\"javascript:void(0);\"><span class=\"glyphicon glyphicon-remove\" " +
                                "style=\"font-size: 20px; color: #E6E6E6;\"></span></a>";
                            htmlStr += "		</div>";
                            htmlStr += "	</div>";
                            htmlStr += "</div>";
                            $("#remarkDiv").before(htmlStr)
                            $("#remark").val("");
                        } else {
                            alert("添加备注失败...")
                        }
                    }
                })
            })

            // TODO 给删除备注按钮添加点击事件
            $("#remarkListDivFather").on("click", " a[name='deleteA']", function () {
                var remarkId = $(this).attr("remarkId");
                var customerId = "${customer.id}";
                $.ajax({
                    url: 'workbench/customer/deleteCustomerRemarkById',
                    type: 'POST',
                    data: {id: remarkId},
                    dataType: 'json',
                    success: function (data) {
                        if (data.code == "1") {
                            window.location.href = 'workbench/customer/toDetail?id=' + customerId
                        } else {
                            alert("删除失败...")
                        }
                    }
                })
            })

            // TODO 修改备注
            $("#updateRemarkBtn").click(function () {
                var remarkId = $("#remarkId").val();
                var customerId = "${customer.id}";
                var text = $("#noteContent").val().trim();
                if (text == "") {
                    alert('内容不可为空')
                    return
                }

                $.ajax({
                    url: 'workbench/customer/editCustomerRemarkById',
                    type: 'POST',
                    data: {
                        "customerId":customerId,
                        "id": remarkId,
                        "noteContent": text
                    },
                    dataType: 'json',
                    success: function (data) {
                        if (data.code == "1") {
                            // 更新成功，则回到该页面
                            window.location.href = 'workbench/customer/toDetail?id=' + customerId
                        }else {
                            alert("修改失败");
                            $("#editRemarkModal").modal("show")
                        }
                    }
                })
            })

            // TODO 给所有编辑按钮添加点击事件
            $("#remarkListDivFather").on("click", " a[name='editA']", function () {
                $("#remarkId").val($(this).attr("remarkId"))
                $("#editRemarkModal").modal("show")
            })

            // TODO 删除交易
            $("#relationTranTbody").on("click", "a", function () {
                if (!window.confirm("是否删除交易")) {
                    return;
                }
                var transcationId = $(this).attr("transcationId");
                $.ajax({
                    url: 'workbench/transaction/deleteTranscationByIds',
                    type: 'POST',
                    data: {
                        "id": transcationId
                    },
                    dataType: 'json',
                    success: function (data) {
                        if (data.code == "1") {
                            queryTranInfo(customerId);
                        } else {
                            queryTranInfo(customerId);
                            alert("删除失败");
                        }
                    }
                })
            });

            // TODO 删除联系人
            $("#contactsTbody").on("click", "a", function () {
                if (!window.confirm("是否删除联系人")) {
                    return;
                }
                var contactsId = $(this).attr("contactsId");
                $.ajax({
                    url: 'workbench/contacts/deleteContacts',
                    type: 'POST',
                    data: {
                        "contactsId":contactsId,
                    },
                    dataType: 'json',
                    success: function (data) {
                        if (data.code == "1") {
                            queryContactsInfo(contactsId);
                        } else {
                            queryContactsInfo(contactsId);
                            alert("删除失败");
                        }
                    }
                })
            });

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

            // TODO 几个前端的操作，不重要
            $("#remarkListDivFather").on("mouseover", ".remarkDiv", function () {
                $(this).children("div").children("div").show();
            })

            $("#remarkListDivFather").on("mouseout", ".remarkDiv", function () {
                $(this).children("div").children("div").hide();
            })

            $("#remarkListDivFather").on("mouseover", ".myHref", function () {
                $(this).children("span").css("color", "red");
            })

            $("#remarkListDivFather").on("mouseout", ".myHref", function () {
                $(this).children("span").css("color", "#E6E6E6");
            })

            $("#remark").focus(function () {
                if (cancelAndSaveBtnDefault) {
                    //设置remarkDiv的高度为130px
                    $("#remarkDiv").css("height", "130px");
                    //显示
                    $("#cancelAndSaveBtn").show("2000");
                    cancelAndSaveBtnDefault = false;
                }
            });

            $("#cancelBtn").click(function () {
                //显示
                $("#cancelAndSaveBtn").hide();
                //设置remarkDiv的高度为130px
                $("#remarkDiv").css("height", "90px");
                cancelAndSaveBtnDefault = true;
            });

            $(".remarkDiv").mouseover(function () {
                $(this).children("div").children("div").show();
            });

            $(".remarkDiv").mouseout(function () {
                $(this).children("div").children("div").hide();
            });

            $(".myHref").mouseover(function () {
                $(this).children("span").css("color", "red");
            });

            $(".myHref").mouseout(function () {
                $(this).children("span").css("color", "#E6E6E6");
            });
        });

        // TODO 根据客户的ID查询交易信息
        queryTranInfo = function (customerId) {
            $.ajax({
                url: 'workbench/customer/getTranInfoByCustomerId',
                type: 'POST',
                data: {
                    "customerId": customerId
                },
                dataType: 'json',
                success: function (data) {
                    // TODO 渲染页面
                    var htmlStr = "";
                    $.each(data.object, function () {
                        htmlStr += "<tr>";
                        htmlStr += "<td>" + this.name + "</td>"
                        htmlStr += "<td>" + this.money + "万</td>"
                        htmlStr += "<td>" + this.stage + "</td>"
                        htmlStr += "<td>" + this.possibility + "</td>"
                        htmlStr += "<td>" + this.expectedDate + "</td>"
                        htmlStr += "<td>" + this.transactionType + "</td>"
                        htmlStr += "<td><a href=\"javascript:void(0);\" transcationId=\"" + this.id + "\" style=\"text-decoration: none;\"><span class=\"glyphicon glyphicon-remove\"></span>删除</a></td>";
                        htmlStr += "</tr>";
                    })
                    $("#relationTranTbody").html(htmlStr);
                }
            })
        }

        // TODO 根据客户的ID查询联系人信息
        queryContactsInfo = function (customerId) {
            $.ajax({
                url: 'workbench/customer/getContactsInfoByCustomerId',
                type: 'POST',
                data: {
                    "customerId": customerId
                },
                dataType: 'json',
                success: function (data) {
                    // TODO 渲染页面
                    var htmlStr = "";
                    $.each(data.object, function () {
                        htmlStr += "<tr>";
                        htmlStr += "<td>" + this.fullname + "</td>"
                        htmlStr += "<td>" + this.job + "</td>"
                        htmlStr += "<td>" + this.email + "</td>"
                        htmlStr += "<td>" + this.mphone + "</td>"
                        htmlStr += "<td>" + this.nextContactTime + "</td>"
                        htmlStr += "<td><a href=\"javascript:void(0);\" contactsId=\"" + this.id + "\" style=\"text-decoration: none;\"><span class=\"glyphicon glyphicon-remove\"></span>删除</a></td>";
                        htmlStr += "</tr>";
                    })
                    $("#contactsTbody").html(htmlStr);
                }
            })
        }
    </script>
</head>
<body>

<!-- 修改备注的模态窗口 -->
<div class="modal fade" id="editRemarkModal" role="dialog">
    <input type="hidden" id="remarkId">
    <div class="modal-dialog" role="document" style="width: 40%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel">修改备注</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form">
                    <div class="form-group">
                        <label for="noteContent" class="col-sm-2 control-label">内容</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="noteContent"></textarea>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="updateRemarkBtn">更新</button>
            </div>
        </div>
    </div>
</div>

<!-- 返回按钮 -->
<div style="position: relative; top: 35px; left: 10px;">
    <a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
</div>

<!-- 大标题 -->
<div style="position: relative; left: 40px; top: -30px;">
    <div class="page-header">
        <h3>${customer.name} <small><a href="${customer.website}" target="_blank">${customer.website}</a></small></h3>
    </div>
</div>
<br/>
<br/>
<br/>

<!-- 详细信息 -->
<div style="position: relative; top: -70px;">
    <div style="position: relative; left: 40px; height: 30px;">
        <div style="width: 300px; color: gray;">所有者</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${customer.owner}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">名称</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${customer.name}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 10px;">
        <div style="width: 300px; color: gray;">公司网站</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${customer.website}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">公司座机</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${customer.phone}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 20px;">
        <div style="width: 300px; color: gray;">创建者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;">
            <b>${customer.createBy}&nbsp;&nbsp;</b><small
                style="font-size: 10px; color: gray;">${customer.createTime}</small></div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 30px;">
        <div style="width: 300px; color: gray;">修改者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;">
            <b>${customer.editBy}&nbsp;&nbsp;</b><small
                style="font-size: 10px; color: gray;">${customer.editTime}</small></div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 40px;">
        <div style="width: 300px; color: gray;">联系纪要</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                ${customer.contactSummary}
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 50px;">
        <div style="width: 300px; color: gray;">下次联系时间</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${customer.nextContactTime}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px; "></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 60px;">
        <div style="width: 300px; color: gray;">描述</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                ${customer.description}
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 70px;">
        <div style="width: 300px; color: gray;">详细地址</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                ${customer.address}
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
</div>

<!-- 备注 -->
<div id="remarkListDivFather" style="position: relative; top: 10px; left: 40px;">
    <div class="page-header">
        <h4>备注</h4>
    </div>

    <!-- 展现备注信息 -->
    <c:forEach items="${customerRemarks}" var="remark">

        <div class="remarkDiv" style="height: 60px;">
            <img title="${customer.name}" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
            <div style="position: relative; top: -40px; left: 40px;">
                <h5>${remark.noteContent}</h5>
                <font color="gray">客户</font> <font color="gray">-</font> <b>${customer.name}</b>
                <small editNameSmall="edit" style="color: gray;">&nbsp;&nbsp;
                        ${remark.editFlag=="1"?remark.editTime:remark.createTime}&nbsp;&nbsp;由
                        ${remark.editFlag=="1"?remark.editBy:remark.createBy}
                        ${remark.editFlag=="1"?"修改":"创建"}</small>
                <div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
                    <a class="myHref" name="editA" remarkId="${remark.id}" href="javascript:void(0);"><span
                            class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
                    &nbsp;&nbsp;&nbsp;&nbsp;
                    <a class="myHref" name="deleteA" remarkId="${remark.id}" href="javascript:void(0);"><span
                            class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
                </div>

            </div>
        </div>
    </c:forEach>

    <!-- 添加备注 -->
    <div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
        <form role="form" style="position: relative;top: 10px; left: 10px;">
            <textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"
                      placeholder="添加备注..."></textarea>
            <p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
                <button id="cancelBtn" type="button" class="btn btn-default">取消</button>
                <button type="button" class="btn btn-primary" id="saveCustomerRemarkBtn">保存</button>
            </p>
        </form>
    </div>
</div>

<!-- 交易 -->
<div>
    <div style="position: relative; top: 20px; left: 40px;">
        <div class="page-header">
            <h4>交易信息</h4>
        </div>
        <div style="position: relative;top: 0px;">
            <table id="activityTable2" class="table table-hover" style="width: 900px;">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td>名称</td>
                    <td>金额</td>
                    <td>阶段</td>
                    <td>可能性</td>
                    <td>预计成交日期</td>
                    <td>类型</td>
                    <td></td>
                </tr>
                </thead>
                <tbody id="relationTranTbody">

                </tbody>
            </table>
        </div>
    </div>
</div>
<!-- 联系人 -->
<div>
    <div style="position: relative; top: 20px; left: 40px;">
        <div class="page-header">
            <h4>联系人</h4>
        </div>
        <div style="position: relative;top: 0px;">
            <table id="activityTable" class="table table-hover" style="width: 900px;">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td>名称</td>
                    <td>职位</td>
                    <td>邮箱</td>
                    <td>手机</td>
                    <td>下次联系时间</td>
                    <td></td>
                </tr>
                </thead>
                <tbody id="contactsTbody">

                </tbody>
            </table>
        </div>
    </div>
</div>

<div style="height: 200px;"></div>
</body>
</html>
