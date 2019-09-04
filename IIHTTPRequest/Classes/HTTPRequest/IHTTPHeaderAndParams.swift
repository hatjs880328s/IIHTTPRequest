//
//  IHTTPHeaderAndParams.swift
//  impcloud_dev
//
//  Created by Noah_Shan on 2018/8/2.
//  Copyright © 2018 Elliot. All rights reserved.
//

import Foundation

class IIHTTPHeaderAndParams: NSObject {
    
    private static let grantType = "grant_type"
    
    private static let refreshToken = "refresh_token"
    
    private static let oauthContent_type = "Content-Type"
    
    private static let oauthContent_Value = "application/x-www-form-urlencoded"
    
    /// app生命周期内目前只有两个sessionmanager 一个是 default普通请求使用，一个是当前属性，捕获wifihelper使用
    public static var redirectManager: SessionManager?
    
    /// 添加报文头部信息
    /// [old]v1:有header直接使用header;没有header返回默认header
    /// [new]V2:没header直接返回默认header;有header，将之添加覆盖到默认header之上
    /// - Returns: 字典
    class func analyzeHTTPHeader(_ header: HTTPHeaders?) -> HTTPHeaders {
        var defaultHeaderFields: HTTPHeaders = [
            "Authorization": (IIHTTPModuleDoor.urlParams.impTokenType) + " " + (IIHTTPModuleDoor.dynamicParams.impAccessAT ?? ""),
            "X-ECC-Current-Enterprise": "\(IIHTTPModuleDoor.dynamicParams.impUserID)",
            "User-Agent": "iOS/\(IIHTTPModuleDoor.urlParams.deviceIOSVersion)(Apple \(IIHTTPModuleDoor.urlParams.deviceKey)) CloudPlus_Phone/\(IIHTTPModuleDoor.urlParams.appCurrentVersion)",
            "Accept-Language": IIHTTPHeaderAndParams.currentUseLanguage(),
            "X-Device-ID": IIHTTPModuleDoor.urlParams.deviceUUID
        ]
        if header == nil {
            return defaultHeaderFields
        } else {
            let resultHeader = header!
            for eachItem in resultHeader {
                defaultHeaderFields[eachItem.key] = eachItem.value
            }
            return defaultHeaderFields
        }
    }
    
    /// 刷新token之后重新请求之前的req需要新的本地AT
    class func refreshTokenGetNewAT() -> String? {
        guard let realAT = IIHTTPModuleDoor.dynamicParams.impAccessAT else { return nil }
        return IIHTTPModuleDoor.urlParams.impTokenType + " " + realAT
    }
    
    /// 获取请求token-params
    class func getRequestTokenParams(userName: String, userPwd: String, id: String, secret: String) -> [String: String] {
        return [grantType: "password", "scope": "", "client_id": id, "client_secret": secret, "username": userName, "password": userPwd]
    }
    
    /// 获取刷新token-params
    class func getRefreshTokenParams(refreshTokenInfo: String) -> [String: String] {
        return [grantType: refreshToken, refreshToken: refreshTokenInfo]
    }
    
    /// 获取请求token-header
    class func getRequestTokenHeader() -> [String: String] {
        return [oauthContent_type: oauthContent_Value]
    }
    
    /// 获取刷新token-header
    class func getRefreshTokenHeader(id: String, secret: String) -> [String: String] {
        //let idAndSecret = "\(id):\(secret)"
        return [oauthContent_type: oauthContent_Value, "Authorization": "Basic \(IIHTTPModuleDoor.urlParams.base64IDAndSecret)"]
    }
    
    /// 编码类型处理
    class func getTrueEncodingType(param: ParamsSeriType) -> ParameterEncoding {
        if param == .urlEncoding {
            return URLEncoding.default
        } else {
            return JSONEncoding.default
        }
    }
    
    /// 是否需要拦截重定向
    class func redirectURL(progress: Bool) -> SessionManager {
        if progress {
            if redirectManager == nil {
                let serverTrustPolicyManager: ServerTrustPolicyManager? = nil
                //                if 2 == 1 {
                //                    serverTrustPolicyManager = ServerTrustPolicyManager(policies: [
                //                        (Utilities.getAppEMMIP() ?? ""): ServerTrustPolicy.performDefaultEvaluation(validateHost: true)
                //                        ])
                //                }
                let configuration = URLSessionConfiguration.default
                configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
                configuration.timeoutIntervalForRequest = 15
                redirectManager = SessionManager(configuration: configuration, serverTrustPolicyManager: serverTrustPolicyManager)
                redirectManager!.delegate.taskWillPerformHTTPRedirection = { (session, task, response, request) -> URLRequest? in
                    return IIHTTPModuleDoor.dynamicParams.redirectAction?(session, task, response, request)
                }
                return redirectManager!
            } else {
                return redirectManager!
            }
        } else {
            return SessionManager.default
        }
    }
    
    /// 判定是否是一个真正的url
    class func progressURL(url: String) -> Bool {
        //        if url.isRealUrl() {
        //            return true
        //        }
        if (IIHTTPModuleDoor.dynamicParams.isUrlAction?(url) ?? false) {
            return true
        }
        //RouteAlert.shareInstance().show(getI18NStr(key: III18NEnum.http_not_realrequest.rawValue))
        IIHTTPModuleDoor.dynamicParams.routeAlertAction?(getI18NStr(key: III18NEnum.http_not_realrequest.rawValue))
        return false
    }
    
    /// 获取当前使用的语言-作为header的一个参数
    class func currentUseLanguage() -> String {
        let currentLan = IMPI18N.userLanguage() ?? ""
        if currentLan == "zh-Hans" {
            return "zh-Hans"
        } else if currentLan == "en" {
            return "en"
        } else {
            return "zh-Hans"
        }
    }
    
}
