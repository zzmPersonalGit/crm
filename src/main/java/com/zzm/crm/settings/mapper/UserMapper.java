package com.zzm.crm.settings.mapper;

import com.zzm.crm.settings.pojo.User;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

public interface UserMapper {

    /**
     * 插入新用户
     * @param row
     * @return
     */
    int insert(User row);

    /**
     * 查询所有用户
     * @return
     */
    List<User> selectAllUsers();

    /**
     * 根据账号密码查询用户
     * @param map
     * @return
     */
    User selectUserByLoginActAndPwd(Map<String,Object> map);

    /**
     * 根据ID查询旧密码
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
    boolean updatePwdByUserId(@Param("newPwd") String newPwd,
                              @Param("id") String id);
}
