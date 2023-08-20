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
    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
    <script type="text/javascript">

        //页面加载完毕
        $(function () {

            // 点击按钮展现更新密码的模态窗口
            $("#managerModalUpdateBtn").click(function () {
                $("#editPwdModal").modal("show")
            })

            //导航中所有文本颜色为黑色
            $(".liClass > a").css("color", "black");

            //默认选中导航菜单中的第一个菜单项
            $(".liClass:first").addClass("active");

            //第一个菜单项的文字变成白色
            $(".liClass:first > a").css("color", "white");

            //给所有的菜单项注册鼠标单击事件
            $(".liClass").click(function () {
                //移除所有菜单项的激活状态
                $(".liClass").removeClass("active");
                //导航中所有文本颜色为黑色
                $(".liClass > a").css("color", "black");
                //当前项目被选中
                $(this).addClass("active");
                //当前项目颜色变成白色
                $(this).children("a").css("color", "white");
            });

            // 默认打开 workbench/main/toIndex请求 页面
            window.open("workbench/main/toIndex", "workareaFrame");

            // 点击登出,发送请求
            $("#logoutBtn").click(function () {
                window.location.href = "settings/qx/user/logout";
            })

            // 更新密码
            $("#updatePwd").click(function () {
                var oldPwd = $("#oldPwd").val().trim();
                var newPwd = $("#newPwd").val().trim();
                var confirmPwd = $("#confirmPwd").val().trim();

                if (oldPwd == '') {
                    alert('原始密码不能为空');
                    return;
                }
                if (newPwd == '') {
                    alert('新密码不能为空');
                    return;
                }
                if (confirmPwd == '') {
                    alert('确认密码不能为空');
                    return;
                }
                if (newPwd != confirmPwd) {
                    alert('两次密码不相同');
                    return;
                }

                // 发送请求修改密码,删除会话记录和本地Cookie,然后把地址转向登录页
                $.ajax({
                    url: "settings/qx/user/updatePwd",
                    type: "POST",
                    data: {
                        "oldPwd": oldPwd,
                        "newPwd": newPwd
                    },
                    dataType: "json",
                    success: function (data) {
                        if ("0" == data.code) {
                            //创建失败,提示信息创建失败,模态窗口不关闭
                            alert(data.message);
                        } else {

                            //创建成功后，关闭模态窗口
                            $("#editPwdModal").modal("hide")

                            document.location.href = "settings/qx/user/toLogin";
                        }
                    }
                })
            })
        });
    </script>

</head>
<body>

<!-- 修改密码的模态窗口 -->
<div class="modal fade" id="editPwdModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 70%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">修改密码</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form">
                    <div class="form-group">
                        <label for="oldPwd" class="col-sm-2 control-label">原密码</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="oldPwd" style="width: 200%;">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="newPwd" class="col-sm-2 control-label">新密码</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="newPwd" style="width: 200%;">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="confirmPwd" class="col-sm-2 control-label">确认密码</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="confirmPwd" style="width: 200%;">
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
                <button type="button" id="updatePwd" class="btn btn-primary">更新</button>
            </div>
        </div>
    </div>
</div>

<!-- 退出系统的模态窗口 -->
<div class="modal fade" id="exitModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 30%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">离开</h4>
            </div>
            <div class="modal-body">
                <p>您确定要退出系统吗？</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
                <button type="button" id="logoutBtn" class="btn btn-primary" data-dismiss="modal">确定</button>
            </div>
        </div>
    </div>
</div>

<!-- 顶部 -->
<div id="top" style="height: 50px; background-color: #3C3C3C; width: 100%;">
    <div style="position: absolute; top: 5px; left: 0px; font-size: 30px; font-weight: 400; color: white; font-family: 'times new roman'">
        &nbsp;CRM&nbsp;&nbsp;<span style="font-size: 12px;">个人博客：zzxjxl.online</span></div>

    <div style="position: absolute; top: 15px; right: 38px;">
        <ul>
            <li class="dropdown user-dropdown">
                <a href="javascript:void(0)" style="text-decoration: none; color: white;" class="dropdown-toggle"
                   data-toggle="dropdown">
                    <span class="glyphicon glyphicon-user"></span> ${sessionScope.loginUser.name} <span
                        class="caret"></span>
                </a>
                <ul class="dropdown-menu">
                    <li><a href="javascript:void(0)"
                           id="managerModalUpdateBtn"
                    ><span class="glyphicon glyphicon-edit"></span> 修改密码</a></li>
                    <li><a href="javascript:void(0);" data-toggle="modal" data-target="#exitModal"><span
                            class="glyphicon glyphicon-off"></span> 退出</a></li>
                </ul>
            </li>
        </ul>
    </div>
</div>

<!-- 中间 -->
<div id="center" style="position: absolute;top: 50px; bottom: 30px; left: 0px; right: 0px;">

    <!-- 导航 -->
    <div id="navigation" style="left: 0px; width: 18%; position: relative; height: 100%; overflow:auto;">
        <ul id="no1" class="nav nav-pills nav-stacked">
            <!-- 市场活动 -->
            <li class="liClass"><a href="workbench/activity/toIndex" target="workareaFrame"><span
                    class="glyphicon glyphicon-play-circle"></span>&nbsp;市场活动</a></li>
            <li class="liClass"><a href="workbench/clue/toIndex" target="workareaFrame"><span
                    class="glyphicon glyphicon-search"></span>&nbsp;客户线索</a></li>
            <li class="liClass"><a href="workbench/customer/toIndex" target="workareaFrame"><span
                    class="glyphicon glyphicon-search"></span>&nbsp;真实客户</a></li>
            <li class="liClass"><a href="workbench/contacts/toIndex" target="workareaFrame">
                <span class="glyphicon glyphicon-earphone"></span>&nbsp;联系人</a></li>
            <li class="liClass"><a href="workbench/transaction/toTranIndex" target="workareaFrame"><span
                    class="glyphicon glyphicon-usd"></span>&nbsp;交易信息</a></li>
            <li class="liClass"><a href="workbench/chart/transaction/toCharIndex" target="workareaFrame"><span
                    class="glyphicon glyphicon-phone-alt"></span>&nbsp;交易图表</a></li>
            <li class="liClass"><a href="javascript:void(0);" target="workareaFrame">----------------</a></li>
            <li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><svg class="bi bi-exclamation-triangle-fill" width="1em" height="1em" viewBox="0 0 16 16" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" d="M8.982 1.566a1.13 1.13 0 0 0-1.96 0L.165 13.233c-.457.778.091 1.767.98 1.767h13.713c.889 0 1.438-.99.98-1.767L8.982 1.566zM8 5a.905.905 0 0 0-.9.995l.35 3.507a.552.552 0 0 0 1.1 0l.35-3.507A.905.905 0 0 0 8 5zm.002 6a1 1 0 1 0 0 2 1 1 0 0 0 0-2z"/>
            </svg>&nbsp;销售订单</a></li>
            <li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><svg class="bi bi-exclamation-triangle-fill" width="1em" height="1em" viewBox="0 0 16 16" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" d="M8.982 1.566a1.13 1.13 0 0 0-1.96 0L.165 13.233c-.457.778.091 1.767.98 1.767h13.713c.889 0 1.438-.99.98-1.767L8.982 1.566zM8 5a.905.905 0 0 0-.9.995l.35 3.507a.552.552 0 0 0 1.1 0l.35-3.507A.905.905 0 0 0 8 5zm.002 6a1 1 0 1 0 0 2 1 1 0 0 0 0-2z"/>
            </svg>&nbsp;销售报表</a></li>
            <li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><svg class="bi bi-exclamation-triangle-fill" width="1em" height="1em" viewBox="0 0 16 16" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" d="M8.982 1.566a1.13 1.13 0 0 0-1.96 0L.165 13.233c-.457.778.091 1.767.98 1.767h13.713c.889 0 1.438-.99.98-1.767L8.982 1.566zM8 5a.905.905 0 0 0-.9.995l.35 3.507a.552.552 0 0 0 1.1 0l.35-3.507A.905.905 0 0 0 8 5zm.002 6a1 1 0 1 0 0 2 1 1 0 0 0 0-2z"/>
            </svg>&nbsp;销售图表</a></li>
            <li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><svg class="bi bi-exclamation-triangle-fill" width="1em" height="1em" viewBox="0 0 16 16" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" d="M8.982 1.566a1.13 1.13 0 0 0-1.96 0L.165 13.233c-.457.778.091 1.767.98 1.767h13.713c.889 0 1.438-.99.98-1.767L8.982 1.566zM8 5a.905.905 0 0 0-.9.995l.35 3.507a.552.552 0 0 0 1.1 0l.35-3.507A.905.905 0 0 0 8 5zm.002 6a1 1 0 1 0 0 2 1 1 0 0 0 0-2z"/>
            </svg>&nbsp;发货单</a></li>
            <li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><svg class="bi bi-exclamation-triangle-fill" width="1em" height="1em" viewBox="0 0 16 16" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" d="M8.982 1.566a1.13 1.13 0 0 0-1.96 0L.165 13.233c-.457.778.091 1.767.98 1.767h13.713c.889 0 1.438-.99.98-1.767L8.982 1.566zM8 5a.905.905 0 0 0-.9.995l.35 3.507a.552.552 0 0 0 1.1 0l.35-3.507A.905.905 0 0 0 8 5zm.002 6a1 1 0 1 0 0 2 1 1 0 0 0 0-2z"/>
            </svg>&nbsp;产品列表</a></li>
            <li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><svg class="bi bi-exclamation-triangle-fill" width="1em" height="1em" viewBox="0 0 16 16" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" d="M8.982 1.566a1.13 1.13 0 0 0-1.96 0L.165 13.233c-.457.778.091 1.767.98 1.767h13.713c.889 0 1.438-.99.98-1.767L8.982 1.566zM8 5a.905.905 0 0 0-.9.995l.35 3.507a.552.552 0 0 0 1.1 0l.35-3.507A.905.905 0 0 0 8 5zm.002 6a1 1 0 1 0 0 2 1 1 0 0 0 0-2z"/>
            </svg>&nbsp;产品跟进</a></li>
            <li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><svg class="bi bi-exclamation-triangle-fill" width="1em" height="1em" viewBox="0 0 16 16" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" d="M8.982 1.566a1.13 1.13 0 0 0-1.96 0L.165 13.233c-.457.778.091 1.767.98 1.767h13.713c.889 0 1.438-.99.98-1.767L8.982 1.566zM8 5a.905.905 0 0 0-.9.995l.35 3.507a.552.552 0 0 0 1.1 0l.35-3.507A.905.905 0 0 0 8 5zm.002 6a1 1 0 1 0 0 2 1 1 0 0 0 0-2z"/>
            </svg>&nbsp;产品报价</a></li>
            <li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><svg class="bi bi-exclamation-triangle-fill" width="1em" height="1em" viewBox="0 0 16 16" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" d="M8.982 1.566a1.13 1.13 0 0 0-1.96 0L.165 13.233c-.457.778.091 1.767.98 1.767h13.713c.889 0 1.438-.99.98-1.767L8.982 1.566zM8 5a.905.905 0 0 0-.9.995l.35 3.507a.552.552 0 0 0 1.1 0l.35-3.507A.905.905 0 0 0 8 5zm.002 6a1 1 0 1 0 0 2 1 1 0 0 0 0-2z"/>
            </svg>&nbsp;跟进计划</a></li>
            <li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><svg class="bi bi-exclamation-triangle-fill" width="1em" height="1em" viewBox="0 0 16 16" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" d="M8.982 1.566a1.13 1.13 0 0 0-1.96 0L.165 13.233c-.457.778.091 1.767.98 1.767h13.713c.889 0 1.438-.99.98-1.767L8.982 1.566zM8 5a.905.905 0 0 0-.9.995l.35 3.507a.552.552 0 0 0 1.1 0l.35-3.507A.905.905 0 0 0 8 5zm.002 6a1 1 0 1 0 0 2 1 1 0 0 0 0-2z"/>
            </svg>&nbsp;销售任务</a></li>
            <li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><svg class="bi bi-exclamation-triangle-fill" width="1em" height="1em" viewBox="0 0 16 16" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" d="M8.982 1.566a1.13 1.13 0 0 0-1.96 0L.165 13.233c-.457.778.091 1.767.98 1.767h13.713c.889 0 1.438-.99.98-1.767L8.982 1.566zM8 5a.905.905 0 0 0-.9.995l.35 3.507a.552.552 0 0 0 1.1 0l.35-3.507A.905.905 0 0 0 8 5zm.002 6a1 1 0 1 0 0 2 1 1 0 0 0 0-2z"/>
            </svg>&nbsp;日程管理</a></li>
            <li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><svg class="bi bi-exclamation-triangle-fill" width="1em" height="1em" viewBox="0 0 16 16" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" d="M8.982 1.566a1.13 1.13 0 0 0-1.96 0L.165 13.233c-.457.778.091 1.767.98 1.767h13.713c.889 0 1.438-.99.98-1.767L8.982 1.566zM8 5a.905.905 0 0 0-.9.995l.35 3.507a.552.552 0 0 0 1.1 0l.35-3.507A.905.905 0 0 0 8 5zm.002 6a1 1 0 1 0 0 2 1 1 0 0 0 0-2z"/>
            </svg>&nbsp;定时回访</a></li>
            <li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><svg class="bi bi-exclamation-triangle-fill" width="1em" height="1em" viewBox="0 0 16 16" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" d="M8.982 1.566a1.13 1.13 0 0 0-1.96 0L.165 13.233c-.457.778.091 1.767.98 1.767h13.713c.889 0 1.438-.99.98-1.767L8.982 1.566zM8 5a.905.905 0 0 0-.9.995l.35 3.507a.552.552 0 0 0 1.1 0l.35-3.507A.905.905 0 0 0 8 5zm.002 6a1 1 0 1 0 0 2 1 1 0 0 0 0-2z"/>
            </svg>&nbsp;商机管理</a></li>
            <li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><svg class="bi bi-exclamation-triangle-fill" width="1em" height="1em" viewBox="0 0 16 16" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" d="M8.982 1.566a1.13 1.13 0 0 0-1.96 0L.165 13.233c-.457.778.091 1.767.98 1.767h13.713c.889 0 1.438-.99.98-1.767L8.982 1.566zM8 5a.905.905 0 0 0-.9.995l.35 3.507a.552.552 0 0 0 1.1 0l.35-3.507A.905.905 0 0 0 8 5zm.002 6a1 1 0 1 0 0 2 1 1 0 0 0 0-2z"/>
            </svg>&nbsp;合同管理</a></li>
            <li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><svg class="bi bi-exclamation-triangle-fill" width="1em" height="1em" viewBox="0 0 16 16" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" d="M8.982 1.566a1.13 1.13 0 0 0-1.96 0L.165 13.233c-.457.778.091 1.767.98 1.767h13.713c.889 0 1.438-.99.98-1.767L8.982 1.566zM8 5a.905.905 0 0 0-.9.995l.35 3.507a.552.552 0 0 0 1.1 0l.35-3.507A.905.905 0 0 0 8 5zm.002 6a1 1 0 1 0 0 2 1 1 0 0 0 0-2z"/>
            </svg>&nbsp;团队管理</a></li>
            <li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><svg class="bi bi-exclamation-triangle-fill" width="1em" height="1em" viewBox="0 0 16 16" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" d="M8.982 1.566a1.13 1.13 0 0 0-1.96 0L.165 13.233c-.457.778.091 1.767.98 1.767h13.713c.889 0 1.438-.99.98-1.767L8.982 1.566zM8 5a.905.905 0 0 0-.9.995l.35 3.507a.552.552 0 0 0 1.1 0l.35-3.507A.905.905 0 0 0 8 5zm.002 6a1 1 0 1 0 0 2 1 1 0 0 0 0-2z"/>
            </svg>&nbsp;发票管理</a></li>
            <li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><svg class="bi bi-exclamation-triangle-fill" width="1em" height="1em" viewBox="0 0 16 16" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" d="M8.982 1.566a1.13 1.13 0 0 0-1.96 0L.165 13.233c-.457.778.091 1.767.98 1.767h13.713c.889 0 1.438-.99.98-1.767L8.982 1.566zM8 5a.905.905 0 0 0-.9.995l.35 3.507a.552.552 0 0 0 1.1 0l.35-3.507A.905.905 0 0 0 8 5zm.002 6a1 1 0 1 0 0 2 1 1 0 0 0 0-2z"/>
            </svg>&nbsp;业绩管理</a></li>
            <li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><svg class="bi bi-exclamation-triangle-fill" width="1em" height="1em" viewBox="0 0 16 16" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" d="M8.982 1.566a1.13 1.13 0 0 0-1.96 0L.165 13.233c-.457.778.091 1.767.98 1.767h13.713c.889 0 1.438-.99.98-1.767L8.982 1.566zM8 5a.905.905 0 0 0-.9.995l.35 3.507a.552.552 0 0 0 1.1 0l.35-3.507A.905.905 0 0 0 8 5zm.002 6a1 1 0 1 0 0 2 1 1 0 0 0 0-2z"/>
            </svg>&nbsp;绩效考核</a></li>
            <li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><svg class="bi bi-exclamation-triangle-fill" width="1em" height="1em" viewBox="0 0 16 16" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" d="M8.982 1.566a1.13 1.13 0 0 0-1.96 0L.165 13.233c-.457.778.091 1.767.98 1.767h13.713c.889 0 1.438-.99.98-1.767L8.982 1.566zM8 5a.905.905 0 0 0-.9.995l.35 3.507a.552.552 0 0 0 1.1 0l.35-3.507A.905.905 0 0 0 8 5zm.002 6a1 1 0 1 0 0 2 1 1 0 0 0 0-2z"/>
            </svg>&nbsp;提成计算</a></li>
            <li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><svg class="bi bi-exclamation-triangle-fill" width="1em" height="1em" viewBox="0 0 16 16" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" d="M8.982 1.566a1.13 1.13 0 0 0-1.96 0L.165 13.233c-.457.778.091 1.767.98 1.767h13.713c.889 0 1.438-.99.98-1.767L8.982 1.566zM8 5a.905.905 0 0 0-.9.995l.35 3.507a.552.552 0 0 0 1.1 0l.35-3.507A.905.905 0 0 0 8 5zm.002 6a1 1 0 1 0 0 2 1 1 0 0 0 0-2z"/>
            </svg>&nbsp;销售利润</a></li>
            <li class="liClass"><a href="javascript:void(0);" target="workareaFrame"><svg class="bi bi-exclamation-triangle-fill" width="1em" height="1em" viewBox="0 0 16 16" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" d="M8.982 1.566a1.13 1.13 0 0 0-1.96 0L.165 13.233c-.457.778.091 1.767.98 1.767h13.713c.889 0 1.438-.99.98-1.767L8.982 1.566zM8 5a.905.905 0 0 0-.9.995l.35 3.507a.552.552 0 0 0 1.1 0l.35-3.507A.905.905 0 0 0 8 5zm.002 6a1 1 0 1 0 0 2 1 1 0 0 0 0-2z"/>
            </svg>&nbsp;业绩排行</a></li>

        </ul>

        <!-- 分割线 -->
        <div id="divider1"
             style="position: absolute; top : 0px; right: 0px; width: 1px; height: 100% ; background-color: #B3B3B3;"></div>
    </div>

    <!-- 工作区 -->
    <div id="workarea" style="position: absolute; top : 0px; left: 18%; width: 82%; height: 100%;">
        <iframe style="border-width: 0px; width: 100%; height: 100%;" name="workareaFrame"></iframe>
    </div>

</div>

<div id="divider2" style="height: 1px; width: 100%; position: absolute;bottom: 30px; background-color: #B3B3B3;"></div>

<!-- 底部 -->
<div id="down" style="height: 30px; width: 100%; position: absolute;bottom: 0px;"></div>

</body>
</html>
