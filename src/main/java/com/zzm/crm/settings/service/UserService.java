package com.zzm.crm.settings.service;

import com.zzm.crm.settings.pojo.User;

import java.util.List;
import java.util.Map;

public interface UserService {

    /**
     * 根据账号密码查询用户
     * @param map
     * @return
     */
    User queryUserByLoginActAndPwd(Map<String,Object> map);

    /**
     * 查询所有用户
     * @return
     */
    List<User> queryAllUsers();

    /**
     * 查询旧密码
     * @param id
     * @return
     */
    String findOldPwd(String id);

    /**
     * 更新密码
     * @param newPwd
     * @param id
     * @return
     */
    boolean updatePwdByUserId(String newPwd,String id);
}
