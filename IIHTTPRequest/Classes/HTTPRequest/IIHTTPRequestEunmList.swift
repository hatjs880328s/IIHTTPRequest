//
//  HTTPRequestEunmList.swift
//  FSZCItem
//
//  Created by MrShan on 16/6/23.
//  Copyright © 2016年 Mrshan. All rights reserved.
//

import Foundation

/// 参数编码类型 - json编码 url编码
@objc public enum ParamsSeriType: Int {
    case jsonEncoding = 0
    case urlEncoding = 1
}

/// response header content-type
public enum ResponseContentType: String {
    case json = "application/json"
    case html = "text/html"
    case protoBuf = "text/plain"
    case others = "others"
}

/// 网络状态枚举使用ping识别出来网络连接态
@objc public enum PingNetWorkStatus: Int {
    case badNetWork
    case noNetWork
    case goodWork
    /// 小助手 & wifi链接不通
    //case wifiHelper
}

/// 硬件体现出来的网络状态
@objc public enum HardWareNetWorkStatus: Int {
    case noNetWork
    case g2
    case g3
    case g4
    case wifi
    case unknown
    case LTE
}

/// 网络请求的类型-普通 请求token refreshtoken
@objc public enum RequestType: Int {
    case normal
    case requestToken
    case refreshToken
    /// 记录日志时使用
    case refreshTokenThenRequest
}

/// http request method
@objc public enum IIHTTPMethod: Int {
    case options
    /// 产看
    case get
    case head
    /// 创建
    case post
    /// 更新
    case put
    case patch
    /// 删除
    case delete
    case trace
    case connect
    
    func changeToAlaMethod() -> HTTPMethod {
        switch self {
        case .options:
            return HTTPMethod.options
        case .get:
            return HTTPMethod.get
        case .head:
            return HTTPMethod.head
        case .post:
            return HTTPMethod.post
        case .put:
            return HTTPMethod.put
        case .patch:
            return HTTPMethod.patch
        case .delete:
            return HTTPMethod.delete
        case .trace:
            return HTTPMethod.trace
        case .connect:
            return HTTPMethod.connect
        }
    }
}

/**
 网络接口返回数据错误处理枚举[oc无法桥接swift枚举，所以处理成类]
 
 - noConnection:                   没有网络
 - timeOut:                        网络请求超时
 - authError:                      权限错误
 - businessErrorMsg:               返回了业务错误信息eg,["errCode":"-3","msg":"未将对象引用指向对象实例","errorLvl":"3"]
 - unknowError:                    nginx返回错误码不做处理
 - code400BodyHtml:                status为400 Body Contenttype为Html-判定Requesttype为refreshtoken退出登录，其他抛异常
 */
@objc public enum ERRORMsgType: Int {
    case noConnection
    case timeOut
    case businessErrorMsg
    case authError
    case unknowError
    case code400BodyHtml
    case wifiHelper
}

/// 网络返回数据的Status-code
@objc public enum ResponseStatusCode: Int {
    case code200 = 200
    case code302 = 302
    case code301 = 301
    case code400 = 400
    case code401 = 401
    case code403 = 403
    case code500 = 500
}

/// 401刷新token队列操作码 0： 刷新 1： 不刷新，重新请求之前request 2: 不做操作只释放信号
@objc public enum RefreshTokenStatusCode: Int {
    case shouldRefresh
    case shouldDirectRequest
    case donothing
}
