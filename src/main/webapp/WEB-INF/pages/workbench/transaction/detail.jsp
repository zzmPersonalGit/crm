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

    <style type="text/css">
        .mystage {
            font-size: 20px;
            vertical-align: middle;
            cursor: pointer;
        }

        .closingDate {
            font-size: 15px;
            cursor: pointer;
            vertical-align: middle;
        }
    </style>

    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>

    <script type="text/javascript">

        //默认情况下取消和保存按钮是隐藏的
        var cancelAndSaveBtnDefault = true;

        $(function () {
            // TODO 保存交易备注的按钮
            $("#saveTranRemarkBtn").click(function () {
                var noteContent = $("#remark").val().trim();
                var tranId = "${transaction.id}";
                if (noteContent == null || noteContent == '') {
                    alert("备注不能为空...")
                    return;
                }
                $.ajax({
                    url: 'workbench/transaction/createRemarkDetail',
                    type: 'POST',
                    data: {
                        "tranId": tranId,
                        "noteContent": noteContent
                    },
                    dataType: 'json',
                    success: function (data) {
                        if (data.code = "1") {
                            var htmlStr = "";
                            htmlStr += "<div id='div_${remark.id}' class=\"remarkDiv\" style=\"height: 60px;\">";
                            htmlStr += "	<img title=\"${activity.owner}\" src=\"image/user-thumbnail.png\" style=\"width: 30px; height:30px;\">";
                            htmlStr += "	<div style=\"position: relative; top: -40px; left: 40px;\" >";
                            htmlStr += "	<h5>" + data.object.noteContent + "</h5>";
                            htmlStr += "		<font color=\"gray\">交易</font> <font color=\"gray\">-</font> <b>${activity.name}</b> " +
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
                var tranId = "${transaction.id}";
                $.ajax({
                    url: 'workbench/transaction/deleteRemarkDetail',
                    type: 'POST',
                    data: {id: remarkId},
                    dataType: 'json',
                    success: function (data) {
                        if (data.code == "1") {
                            window.location.href = 'workbench/transaction/showTranDetail?id=' + tranId;
                        } else {
                            alert("删除失败...")
                        }
                    }
                })
            })

            // TODO 修改备注
            $("#updateRemarkBtn").click(function () {
                var remarkId = $("#remarkId").val();
                var tranId = "${transaction.id}";
                var text = $("#noteContent").val().trim();

                if (text == "") {
                    alert('内容不可为空')
                    return
                }

                $.ajax({
                    url: 'workbench/transaction/editTranRemarkById',
                    type: 'POST',
                    data: {
                        "tranId": tranId,
                        "id": remarkId,
                        "noteContent": text
                    },
                    dataType: 'json',
                    success: function (data) {
                        if (data.code == "1") {
                            // 更新成功，则回到该页面
                            window.location.href = 'workbench/transaction/showTranDetail?id=' + tranId;
                        } else {
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

            //阶段提示框
            $(".mystage").popover({
                trigger: 'manual',
                placement: 'bottom',
                html: 'true',
                animation: false
            }).on("mouseenter", function () {
                var _this = this;
                $(this).popover("show");
                $(this).siblings(".popover").on("mouseleave", function () {
                    $(_this).popover('hide');
                });
            }).on("mouseleave", function () {
                var _this = this;
                setTimeout(function () {
                    if (!$(".popover:hover").length) {
                        $(_this).popover("hide")
                    }
                }, 100);
            });
        });

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
    <a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left"
                                                                         style="font-size: 20px; color: #DDDDDD"></span></a>
</div>

<!-- 大标题 -->
<div style="position: relative; left: 40px; top: -30px;">
    <div class="page-header">
        <h3>${transaction.customerId}-${transaction.name} <small>￥${transaction.money}</small></h3>
    </div>

</div>

<br/>
<br/>
<br/>

<!-- 阶段状态 -->
<div style="position: relative; left: 40px; top: -50px;">
    阶段&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <c:forEach items="${stageList}" var="stageObj">
        <c:if test="${stageObj.orderNo<toolMap.tranStageId}">
            <span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom"
                  data-content="${stageObj.value}" style="color: #90F790;"></span>
            -----------
        </c:if>
        <c:if test="${stageObj.orderNo==toolMap.tranStageId}">
            <span class="glyphicon glyphicon-map-marker mystage" data-toggle="popover" data-placement="bottom"
                  data-content="${stageObj.value}" style="color: #90F790;"></span>
            -----------
        </c:if>
        <c:if test="${stageObj.orderNo>toolMap.tranStageId}">
            <span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom"
                  data-content="${stageObj.value}"></span>
            -----------
        </c:if>
    </c:forEach>
    <span class="closingDate">${transaction.expectedDate}</span>
</div>

<!-- 详细信息 -->
<div style="position: relative; top: 0px;">
    <div style="position: relative; left: 40px; height: 30px;">
        <div style="width: 300px; color: gray;">所有者</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${transaction.owner}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">金额</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${transaction.money}万</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 10px;">
        <div style="width: 300px; color: gray;">名称</div>
        <div style="width: 1000px;position: relative; left: 200px; top: -20px;"><b>${transaction.name}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">预计成交日期</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${transaction.expectedDate}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 20px;">
        <div style="width: 300px; color: gray;">客户名称</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${transaction.customerId}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">阶段</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${transaction.stage}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 30px;">
        <div style="width: 300px; color: gray;">类型</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${transaction.transactionType}</b>
        </div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">可能性</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${toolMap.possible}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 40px;">
        <div style="width: 300px; color: gray;">来源</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${transaction.source}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">市场活动源</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${transaction.activityId}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 50px;">
        <div style="width: 300px; color: gray;">联系人名称</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${transaction.contactsId}</b></div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 60px;">
        <div style="width: 300px; color: gray;">创建者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;">
            <b>${transaction.createBy}&nbsp;&nbsp;</b><small
                style="font-size: 10px; color: gray;">${transaction.createTime}</small></div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 70px;">
        <div style="width: 300px; color: gray;">修改者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;">
            <b>${transaction.editBy}&nbsp;&nbsp;</b><small
                style="font-size: 10px; color: gray;">${transaction.editTime}</small></div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 80px;">
        <div style="width: 300px; color: gray;">描述</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                ${transaction.description}
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 90px;">
        <div style="width: 300px; color: gray;">联系纪要</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                ${transaction.contactSummary}&nbsp;
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 100px;">
        <div style="width: 300px; color: gray;">下次联系时间</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;">
            <b>${transaction.nextContactTime}&nbsp;</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
</div>

<!-- 备注 -->
<div id="remarkListDivFather" style="position: relative; top: 100px; left: 40px;">
    <div class="page-header">
        <h4>备注</h4>
    </div>

    <c:forEach items="${transactionRemarkList}" var="remark">
        <div id="div_${remark.id}" class="remarkDiv" style="height: 60px;">
            <img title="${transaction.owner}" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
            <div style="position: relative; top: -40px; left: 40px;">
                <h5>${remark.noteContent}</h5>
                <font color="gray">交易</font> <font color="gray">-</font> <b>${activity.name}&nbsp;</b> <small
                    editNameSmall="edit" style="color: gray;">
                &nbsp;&nbsp;${remark.editFlag=="1"?remark.editTime:remark.createTime}
                &nbsp;由&nbsp;${remark.editFlag=="1"?remark.editBy:remark.createBy}
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

    <div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
        <form role="form" style="position: relative;top: 10px; left: 10px;">
            <textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"
                      placeholder="添加备注..."></textarea>
            <p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
                <button id="cancelBtn" type="button" class="btn btn-default">取消</button>
                <button type="button" class="btn btn-primary" id="saveTranRemarkBtn">保存</button>
            </p>
        </form>
    </div>
</div>

<!-- 阶段历史 -->
<div>
    <div style="position: relative; top: 100px; left: 40px;">
        <div class="page-header">
            <h4>阶段历史</h4>
        </div>
        <div style="position: relative;top: 0px;">
            <table id="activityTable" class="table table-hover" style="width: 900px;">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td>阶段</td>
                    <td>金额</td>
                    <td>预计成交日期</td>
                    <td>创建时间</td>
                    <td>创建人</td>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${transactionHistoryList}" var="history">
                    <tr>
                        <td>${history.stage}</td>
                        <td>${history.money}</td>
                        <td>${history.expectedDate}</td>
                        <td>${history.createTime}</td>
                        <td>${history.createBy}</td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>

    </div>
</div>

<div style="height: 200px;"></div>


</body>
</html>
