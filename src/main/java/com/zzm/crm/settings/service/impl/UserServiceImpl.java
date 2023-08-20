package com.zzm.crm.settings.service.impl;

import com.zzm.crm.settings.mapper.UserMapper;
import com.zzm.crm.settings.pojo.User;
import com.zzm.crm.settings.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class UserServiceImpl implements UserService {

    @Autowired
    private UserMapper userMapper;

    @Override
    public User queryUserByLoginActAndPwd(Map<String, Object> map) {
        return userMapper.selectUserByLoginActAndPwd(map);
    }

    @Override
    public String findOldPwd(String id) {
        return userMapper.findOldPwd(id);
    }

    @Override
    public boolean updatePwdByUserId(String newPwd,String id) {
        return userMapper.updatePwdByUserId(newPwd,id);
    }

    @Override
    public List<User> queryAllUsers() {
        return userMapper.selectAllUsers();
    }
}
