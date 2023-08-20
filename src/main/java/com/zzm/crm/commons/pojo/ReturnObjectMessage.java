package com.zzm.crm.commons.pojo;

import com.zzm.crm.commons.constants.Constans;

public class ReturnObjectMessage {
    private String code;
    private String message;
    private Object object;

    public ReturnObjectMessage() {
        this.code= Constans.RETURN_OBJECT_FAILURE;
        this.message="成功";
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Object getObject() {
        return object;
    }

    public void setObject(Object object) {
        this.object = object;
    }
}
