package com.zzm.crm.settings.web.controller;

import com.zzm.crm.commons.constants.Constans;
import com.zzm.crm.commons.utils.ClearSessionUtil;
import com.zzm.crm.commons.utils.DateFormatUtil;
import com.zzm.crm.settings.pojo.User;
import com.zzm.crm.settings.service.UserService;
import com.zzm.crm.commons.pojo.ReturnObjectMessage;
import com.zzm.crm.commons.utils.EncryptUtil;
import com.zzm.crm.commons.utils.IPUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Logger;

@Controller
public class UserController {
    Logger log = Logger.getLogger("controller.web.settings.com.zzm.crm.UserController");

    @Autowired
    private UserService userService;

    @RequestMapping("/settings/qx/user/toLogin")
    public String toLogin() {
        log.info("去往登录页");
        return "settings/qx/user/login";
    }

    @RequestMapping("/settings/qx/user/Login")
    @ResponseBody
    public Object login(String loginAct, String loginPwd, String isRemPwd,
                        HttpServletRequest request, HttpServletResponse response) {
        log.info("处理登录请求");

        //判断登陆状态
        Map<String, Object> map = new HashMap<>();
        boolean loginActCookieFlag = false;
        boolean loginPwdCookieFlag = false;

        // 判断有没有登录的帐号密码的Cookie
        Cookie[] cookies = request.getCookies();
        for (Cookie cookie : cookies) {
            String name = cookie.getName();
            if ("loginAct".equals(name)) {
                loginActCookieFlag = true;
            }
            if ("loginPwd".equals(name)) {
                loginPwdCookieFlag = true;
            }
        }

        // 没有点击记住密码
        if (!"true".equals(isRemPwd)) {
            // 拿到加密的密码
            loginPwd = EncryptUtil.encryptMD5(loginPwd);
        }

        // 点击了记住密码，但是没有帐号密码的Cookie
        if ("true".equals(isRemPwd) && loginActCookieFlag == false && loginPwdCookieFlag == false) {
            // 拿到加密的密码
            loginPwd = EncryptUtil.encryptMD5(loginPwd);
        }

        // 点击了记住密码，也有帐号密码的Cookie
        map.put("loginAct", loginAct);
        map.put("loginPwd", loginPwd);
        User user = userService.queryUserByLoginActAndPwd(map);
        ReturnObjectMessage returnObjectMessage = new ReturnObjectMessage();
        returnObjectMessage.setCode(Constans.RETURN_OBJECT_LOGIN_FAILURE);

        if (user == null) {
            //联合查询查不到,用户的账号或者密码错误
            returnObjectMessage.setMessage("用户的账号或者密码错误");
        } else {
            String expireTime = user.getExpireTime();
            String lockState = user.getLockState();
            if (DateFormatUtil.formatDateTime(new Date()).compareTo(expireTime) > 0) {
                //用户账号时间过期
                returnObjectMessage.setMessage("用户账号时间过期");
            } else if ("0".equals(lockState)) {
                //用户登陆状态被锁定
                returnObjectMessage.setMessage("用户登陆状态被锁定");
            } else if (!IPUtil.checkIp(request.getRemoteAddr())) {
                //用户ip受限
                returnObjectMessage.setMessage("用户ip受限");
            } else {
                //用户登陆成功
                returnObjectMessage.setCode(Constans.RETURN_OBJECT_LOGIN_SUCCESS);
                returnObjectMessage.setMessage("用户登陆成功");
                //往会话里面储存信息
                request.getSession().setAttribute(Constans.SESSION_LOGIN_INF, user);
                if ("true".equals(isRemPwd)) {
                    //记住十天登陆功能的代码
                    Cookie loginActCookie = new Cookie("loginAct", loginAct);
                    Cookie loginPwdCookie = new Cookie("loginPwd", loginPwd);
                    loginActCookie.setMaxAge(10 * 24 * 60 * 60);
                    loginPwdCookie.setMaxAge(10 * 24 * 60 * 60);
                    loginActCookie.setPath(request.getContextPath());
                    loginPwdCookie.setPath(request.getContextPath());
                    response.addCookie(loginActCookie);
                    response.addCookie(loginPwdCookie);
                } else {
                    //不记住十天登陆功能的代码,要销毁Cookie
                    ClearSessionUtil.clearLoginInformation(request, response);
                }
            }
        }
        return returnObjectMessage;
    }

    @RequestMapping("/settings/qx/user/logout")
    public String logout(HttpServletRequest request, HttpServletResponse response) {
        log.info("处理登出请求,销毁本次会话和Cookie信息");
        ClearSessionUtil.clearLoginInformation(request, response);
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        return "redirect:/";
    }

    @RequestMapping("/settings/qx/user/updatePwd")
    @ResponseBody
    public Object updatePwd(HttpServletRequest request, HttpServletResponse response,
                            String oldPwd, String newPwd) {
        log.info("更新密码,并且销毁会话和Cookie");
        // 结果
        ReturnObjectMessage returnObjectMessage = new ReturnObjectMessage();

        // Session信息
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute(Constans.SESSION_LOGIN_INF);

        // 用户ID
        String id = user.getId();

        // 查询旧密码
        String findOldPwd = userService.findOldPwd(id);
        System.out.println(findOldPwd);

        oldPwd = EncryptUtil.encryptMD5(oldPwd);
        newPwd = EncryptUtil.encryptMD5(newPwd);
        if (oldPwd.equals(findOldPwd)) {
            // 更新密码
            try {
                userService.updatePwdByUserId(newPwd, id);
                returnObjectMessage.setCode(Constans.RETURN_OBJECT_SUCCESS);
                returnObjectMessage.setMessage("成功");
            } catch (Exception e) {
                returnObjectMessage.setCode(Constans.RETURN_OBJECT_FAILURE);
                returnObjectMessage.setMessage("失败");
            }
        }

        // 清空Cookie信息
        ClearSessionUtil.clearLoginInformation(request, response);

        // 清空会话信息
        if (session != null) {
            session.invalidate();
        }

        return returnObjectMessage;
    }
}
