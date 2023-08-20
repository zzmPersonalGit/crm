package com.zzm.crm.commons.utils;

import java.util.UUID;

/*UUID 来作为数据库数据表主键是非常不错的选择，保证每次生成的UUID 是唯一的。*/
public class UUIDUtil {
    private UUIDUtil(){}

    public static String getUUID(){
        return UUID.randomUUID().toString().replaceAll("-", "");
    }
}
