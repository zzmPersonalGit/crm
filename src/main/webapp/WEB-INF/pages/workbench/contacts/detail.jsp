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
        var contactsId = "${contacts.id}"
        $(function () {

            // TODO 查询交易信息
            queryTranInfo(contactsId);

            // TODO 查询关联的市场活动信息
            queryActivityInfo(contactsId);

            // TODO 点击关联市场活动按钮,展现当前联系人所未关联的市场活动
            $("#activityRelationA").click(function () {
                // 展示模态窗口
                $("#bundModal").modal("show");

                // 搜索的参数值【这个时候为空】
                var value = $("#searchActivityForRelation").val().trim();
                $.ajax({
                    url: 'workbench/clue/fuzzyQueryActivityByContactsId',
                    type: 'POST',
                    data: {
                        "value": value,
                        "contactsId": contactsId
                    },
                    dataType: 'json',
                    success: function (data) {
                        if (data.code == "1") {
                            var htmlStr = "";
                            $.each(data.object, function (index, item) {
                                htmlStr += "<tr>";
                                htmlStr += "	<td><input type=\"checkbox\" value=\'" + item.id + "\'/></td>";
                                htmlStr += "	<td>" + this.name + "</td>";
                                htmlStr += "	<td>" + this.startDate + "</td>";
                                htmlStr += "	<td>" + this.endDate + "</td>";
                                htmlStr += "	<td>" + this.owner + "</td>";
                                htmlStr += "</tr>";
                            })

                            $("#fuzzyTbody").html(htmlStr)
                        } else {
                            $("#bundModal").modal("show")
                        }
                    }
                })
            })

            // TODO 点击关联市场活动内的搜索按钮，展现所搜索的并且未关联的市场活动
            $("#searchActivityForRelation").keyup(function () {
                var value = $("#searchActivityForRelation").val().trim();
                $.ajax({
                    url: 'workbench/clue/fuzzyQueryActivityByContactsId',
                    type: 'POST',
                    data: {
                        "value": value,
                        "contactsId": contactsId
                    },
                    dataType: 'json',
                    success: function (data) {
                        if (data.code == "1") {
                            var htmlStr = "";
                            $.each(data.object, function (index, item) {
                                htmlStr += "<tr>";
                                htmlStr += "	<td><input type=\"checkbox\" value=\'" + item.id + "\'/></td>";
                                htmlStr += "	<td>" + this.name + "</td>";
                                htmlStr += "	<td>" + this.startDate + "</td>";
                                htmlStr += "	<td>" + this.endDate + "</td>";
                                htmlStr += "	<td>" + this.owner + "</td>";
                                htmlStr += "</tr>";
                            })

                            $("#fuzzyTbody").html(htmlStr)
                        } else {
                            $("#bundModal").modal("show")
                        }
                    }
                })
            })

            // TODO 关联客户和市场活动的操作
            $("#relationContactsAndActivity").click(function () {

                var checkboxs = $("#fuzzyTbody input[type='checkbox']:checked");
                if (checkboxs.size() <= 0) {
                    alert("请选择一个关联市场活动...")
                    return
                }

                // 动态拼接市场活动的id,打包成为字符串
                var ids = ""
                $.each(checkboxs, function () {
                    ids += "activityId=" + this.value + "&"
                })
                ids += "contactsId=" + contactsId
                $.ajax({
                    url: 'workbench/contacts/saveContactsActivityRelationByIds',
                    type: 'POST',
                    data: ids,
                    dataType: 'json',
                    success: function (data) {
                        if (data.code == "1") {
                            queryActivityInfo(contactsId);
                            $("#bundModal").modal("hide")
                            $("#fuzzyTbody").html("")
                            $("#searchActivityForRelation").val("")
                            $("#allCheckRemark").prop("checked", false)
                        } else {
                            alert("关联失败...")
                            $("#bundModal").modal("show")
                        }
                    }
                })
            })

            // TODO 给全选的checked框按钮绑定相对应的事件
            $("#allCheckRemark").click(function () {
                $("#fuzzyTbody input[type='checkbox']").prop("checked", this.checked)
            })

            // TODO 给动态生成的checked框绑定单击事件
            $("#fuzzyTbody").on("click", "input[type='checkbox']", function () {
                if ($("#fuzzyTbody input[type='checkbox']").size()
                    == $("#fuzzyTbody input[type='checkbox']:checked").size()) {
                    $("#allCheckRemark").prop("checked", true)
                } else {
                    $("#allCheckRemark").prop("checked", false)
                }
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
                            queryTranInfo(contactsId);
                        } else {
                            queryTranInfo(contactsId);
                            alert("删除失败");
                        }
                    }
                })
            });

            // TODO 解除市场活动和联系人的关系
            $("#activityTbody").on("click", "a", function () {
                if (!window.confirm("是否解除关联关系")) {
                    return;
                }
                var activityId = $(this).attr("activityId");
                $.ajax({
                    url: 'workbench/activity/deleteRelation',
                    type: 'POST',
                    data: {
                        "activityId": activityId,
                        "contactsId": contactsId
                    },
                    dataType: 'json',
                    success: function (data) {
                        if (data.code == "1") {
                            queryActivityInfo(contactsId);
                        } else {
                            queryActivityInfo(contactsId);
                            alert("删除失败");
                        }
                    }
                })
            });

            // TODO 保存联系人备注的按钮
            $("#saveContactsRemarkBtn").click(function () {
                var noteContent = $("#remark").val().trim();
                var contactsId = "${contacts.id}";

                if (noteContent == null || noteContent == '') {
                    alert("备注不能为空...")
                    return;
                }

                $.ajax({
                    url: 'workbench/contacts/createRemarkDetail',
                    type: 'POST',
                    data: {
                        "contactsId": contactsId,
                        "noteContent": noteContent
                    },
                    dataType: 'json',
                    success: function (data) {
                        if (data.code = "1") {
                            var htmlStr = "";
                            htmlStr += "<div id='div_${remark.id}' class=\"remarkDiv\" style=\"height: 60px;\">";
                            htmlStr += "	<img title=\"${contacts.owner}\" src=\"image/user-thumbnail.png\" style=\"width: 30px; height:30px;\">";
                            htmlStr += "	<div style=\"position: relative; top: -40px; left: 40px;\" >";
                            htmlStr += "	<h5>" + data.object.noteContent + "</h5>";
                            htmlStr += "		<font color=\"gray\">联系人</font> <font color=\"gray\">-</font> <b>${contacts.fullname}</b> " +
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
                var contactsId = "${contacts.id}";
                $.ajax({
                    url: 'workbench/contacts/deleteContactsRemarkById',
                    type: 'POST',
                    data: {id: remarkId},
                    dataType: 'json',
                    success: function (data) {
                        if (data.code == "1") {
                            window.location.href = 'workbench/contacts/toDetail?id=' + contactsId
                        } else {
                            alert("删除失败...")
                        }
                    }
                })
            })

            // TODO 修改备注
            $("#updateRemarkBtn").click(function () {
                var remarkId = $("#remarkId").val();
                var contactsId = "${contacts.id}";
                var text = $("#noteContent").val().trim();

                if (text == "") {
                    alert('内容不可为空')
                    return
                }

                $.ajax({
                    url: 'workbench/contacts/editContactsemarkById',
                    type: 'POST',
                    data: {
                        "contactsId": contactsId,
                        "id": remarkId,
                        "noteContent": text
                    },
                    dataType: 'json',
                    success: function (data) {
                        if (data.code == "1") {
                            // 更新成功，则回到该页面
                            window.location.href = 'workbench/contacts/toDetail?id=' + contactsId
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
        });

        // TODO 根据联系人的ID查询交易信息
        queryTranInfo = function (contactsId) {
            $.ajax({
                url: 'workbench/contacts/getTranInfoByContactsId',
                type: 'POST',
                data: {
                    "contactsId": contactsId
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

        // TODO 根据联系人的ID查询市场活动信息
        queryActivityInfo = function (contactsId) {
            $.ajax({
                url: 'workbench/activity/getActivityInfoByContactsId',
                type: 'POST',
                data: {
                    "contactsId": contactsId
                },
                dataType: 'json',
                success: function (data) {
                    // TODO 渲染页面
                    var htmlStr = "";
                    $.each(data.object, function () {
                        htmlStr += "<tr>";
                        htmlStr += "<td>" + this.name + "</td>"
                        htmlStr += "<td>" + this.cost + "</td>"
                        htmlStr += "<td>" + this.startDate + "</td>"
                        htmlStr += "<td>" + this.endDate + "</td>"
                        htmlStr += "<td>" + this.owner + "</td>"
                        htmlStr += "<td><a href=\"javascript:void(0);\" activityId=\"" + this.id + "\" style=\"text-decoration: none;\"><span class=\"glyphicon glyphicon-remove\"></span>删除</a></td>";
                        htmlStr += "</tr>";
                    })
                    $("#activityTbody").html(htmlStr);
                }
            })
        }
    </script>

</head>
<body>

<!-- 解除联系人和市场活动关联的模态窗口 -->
<div class="modal fade" id="unbundActivityModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 30%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">解除关联</h4>
            </div>
            <div class="modal-body">
                <p>您确定要解除该关联关系吗？</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
                <button type="button" class="btn btn-danger" data-dismiss="modal">解除</button>
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
                <h4 class="modal-title" id="myModalLabel">修改联系人</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form">

                    <div class="form-group">
                        <label for="edit-contactsOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-contactsOwner">
                                <option selected>zhangsan</option>
                                <option>lisi</option>
                                <option>wangwu</option>
                            </select>
                        </div>
                        <label for="edit-clueSource" class="col-sm-2 control-label">来源</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-clueSource">
                                <option></option>
                                <option selected>广告</option>
                                <option>推销电话</option>
                                <option>员工介绍</option>
                                <option>外部介绍</option>
                                <option>在线商场</option>
                                <option>合作伙伴</option>
                                <option>公开媒介</option>
                                <option>销售邮件</option>
                                <option>合作伙伴研讨会</option>
                                <option>内部研讨会</option>
                                <option>交易会</option>
                                <option>web下载</option>
                                <option>web调研</option>
                                <option>聊天</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-surname" class="col-sm-2 control-label">姓名<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-surname" value="李四">
                        </div>
                        <label for="edit-call" class="col-sm-2 control-label">称呼</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-call">
                                <option></option>
                                <option selected>先生</option>
                                <option>夫人</option>
                                <option>女士</option>
                                <option>博士</option>
                                <option>教授</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-job" class="col-sm-2 control-label">职位</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-job" value="CTO">
                        </div>
                        <label for="edit-mphone" class="col-sm-2 control-label">手机</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-mphone" value="12345678901">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-email" class="col-sm-2 control-label">邮箱</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-email" value="lisi@bjpowernode.com">
                        </div>
                        <label for="edit-birth" class="col-sm-2 control-label">生日</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-birth">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-customerName" class="col-sm-2 control-label">客户名称</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-customerName"
                                   placeholder="支持自动补全，输入客户不存在则新建" value="动力节点">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-describe" class="col-sm-2 control-label">描述</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="edit-describe">这是一条线索的描述信息</textarea>
                        </div>
                    </div>

                    <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

                    <div style="position: relative;top: 15px;">
                        <div class="form-group">
                            <label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="create-contactSummary"></textarea>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-nextContactTime">
                            </div>
                        </div>
                    </div>

                    <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                    <div style="position: relative;top: 20px;">
                        <div class="form-group">
                            <label for="edit-address1" class="col-sm-2 control-label">详细地址</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="1" id="edit-address1">北京大兴区大族企业湾</textarea>
                            </div>
                        </div>
                    </div>
                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" data-dismiss="modal">更新</button>
            </div>
        </div>
    </div>
</div>

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
<!-- 关联市场活动的模态窗口 -->
<div class="modal fade" id="bundModal" role="dialog">

    <div class="modal-dialog" role="document" style="width: 80%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">关联市场活动</h4>
            </div>
            <div class="modal-body">
                <div class="btn-group" style="position: relative; top: 18%; left: 8px;">
                    <form class="form-inline" role="form">
                        <div class="form-group has-feedback">
                            <input id="searchActivityForRelation" type="text" class="form-control" style="width: 300px;"
                                   placeholder="请输入市场活动名称，支持模糊查询">
                            <span class="glyphicon glyphicon-search form-control-feedback"></span>
                        </div>
                    </form>
                </div>
                <table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
                    <thead>
                    <tr style="color: #B3B3B3;">
                        <td><input type="checkbox" id="allCheckRemark"></td>
                        <td>名称</td>
                        <td>开始日期</td>
                        <td>结束日期</td>
                        <td>所有者</td>
                        <td></td>
                    </tr>
                    </thead>
                    <tbody id="fuzzyTbody">

                    </tbody>
                </table>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
                <button type="button" class="btn btn-primary" id="relationContactsAndActivity">关联</button>
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
        <h3>${contacts.fullname}<small> - ${contacts.customerId}</small></h3>
    </div>
</div>

<br/>
<br/>
<br/>

<!-- 详细信息 -->
<div style="position: relative; top: -70px;">
    <div style="position: relative; left: 40px; height: 30px;">
        <div style="width: 300px; color: gray;">所有者</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${contacts.owner}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">来源</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${contacts.source}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 10px;">
        <div style="width: 300px; color: gray;">客户名称</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${contacts.customerId}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">姓名</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${contacts.fullname}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 20px;">
        <div style="width: 300px; color: gray;">邮箱</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${contacts.email}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">手机</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${contacts.mphone}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 30px;">
        <div style="width: 300px; color: gray;">职位</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${contacts.job}</b></div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 40px;">
        <div style="width: 300px; color: gray;">创建者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;">
            <b>${contacts.createBy}&nbsp;&nbsp;</b><small
                style="font-size: 10px; color: gray;">${contacts.createTime}</small></div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 50px;">
        <div style="width: 300px; color: gray;">修改者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;">
            <b>${contacts.editBy}&nbsp;&nbsp;</b><small
                style="font-size: 10px; color: gray;">${contacts.editTime}</small></div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 60px;">
        <div style="width: 300px; color: gray;">描述</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                ${contacts.description}
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 70px;">
        <div style="width: 300px; color: gray;">联系纪要</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                ${contacts.contactSummary}
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 80px;">
        <div style="width: 300px; color: gray;">下次联系时间</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${contacts.nextContactTime}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 90px;">
        <div style="width: 300px; color: gray;">详细地址</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                ${contacts.address}
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
</div>

<!-- 备注 -->
<div id="remarkListDivFather" style="position: relative; top: 20px; left: 40px;">
    <div class="page-header">
        <h4>备注</h4>
    </div>

    <!-- 展现备注信息 -->
    <c:forEach items="${contactsRemarks}" var="remark">

        <div class="remarkDiv" style="height: 60px;">
            <img title="${contacts.fullname}" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
            <div style="position: relative; top: -40px; left: 40px;">
                <h5>${remark.noteContent}</h5>
                <font color="gray">联系人</font> <font color="gray">-</font> <b>${contacts.fullname}</b>
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

    <div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
        <form role="form" style="position: relative;top: 10px; left: 10px;">
            <textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"
                      placeholder="添加备注..."></textarea>

            <p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
                <button id="cancelBtn" type="button" class="btn btn-default">取消</button>
                <button type="button" class="btn btn-primary" id="saveContactsRemarkBtn">保存</button>
            </p>
        </form>
    </div>
</div>

<!-- 交易 -->
<div>
    <div style="position: relative; top: 20px; left: 40px;">
        <div class="page-header">
            <h4>交易</h4>
        </div>
        <div style="position: relative;top: 0px;">
            <table id="activityTable3" class="table table-hover" style="width: 900px;">
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
<!-- 市场活动 -->
<div>
    <div style="position: relative; top: 60px; left: 40px;">
        <div class="page-header">
            <h4>市场活动</h4>
        </div>
        <div style="position: relative;top: 0px;">
            <table id="activityTable" class="table table-hover" style="width: 900px;">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td>名称</td>
                    <td>花费</td>
                    <td>开始日期</td>
                    <td>结束日期</td>
                    <td>所有者</td>
                    <td></td>
                </tr>
                </thead>
                <tbody id="activityTbody">

                </tbody>
            </table>
        </div>

        <div>
            <!-- TODO 关联市场活动按钮 -->
            <a href="javascript:void(0);" id="activityRelationA" style="text-decoration: none;"><span
                    class="glyphicon glyphicon-plus"></span>关联市场活动</a>
        </div>
    </div>
</div>

<div style="height: 200px;"></div>
</body>
</html>
