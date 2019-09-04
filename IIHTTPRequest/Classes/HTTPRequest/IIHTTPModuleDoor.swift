//
//  *******************************************
//  
//  IIHTTPModuleDoor.swift
//  testcanrun
//
//  Created by Noah_Shan on 2019/4/18.
//  Copyright © 2018 Inpur. All rights reserved.
//  
//  *******************************************
//

import Foundation

/*
 http模块的入口设置函数，需要设置当前模块启动所必须的一些属性
  
 */

public class IIHTTPModuleDoor: NSObject {
    
    
    @objc public static var urlParams: IIHTTPModuleDoorURL = IIHTTPModuleDoorURL()
    
    @objc public static var dynamicParams: IIHTTPModuleDynamicParams = IIHTTPModuleDynamicParams()
    
    @objc public static var alertParams: IIHTTPModuleAlertInfo = IIHTTPModuleAlertInfo()
    
}

/// 所有URL类属性信息
public class IIHTTPModuleDoorURL: NSObject {
    
    //IIAPIStruct().wifiHelperURL
    @objc public var wifiHelperURL = ""
    
    //IIAPIStruct().pintFirstCheckAdd
    @objc public var pingCheckAdd = ""
    
    //ping double check add
    @objc public var pingDoubleCheckAdd = ""
    
    //IMPAccessTokenModel.activeToken()?.tokenType
    @objc public var impTokenType = ""
    
    //Utilities.getDeviceiOSVersion() ?? ""
    @objc public var deviceIOSVersion = ""
    
    // Utilities.getDeviceKey() ?? ""
    @objc public var deviceKey = ""
    
    //Utilities.getAPPCurrentVersion() ?? ""
    @objc public var appCurrentVersion = ""
    
    //GetDeviceUUIDClass.shareInstance().getDeviceUUID()
    @objc public var deviceUUID = ""
    
    //idAndSecret base 64
    @objc public var base64IDAndSecret = ""
    
    //kOAuthClientId
    @objc public var authHeaderID = ""
    
    //kOAuthSecret
    @objc public var authHeaderSecret = ""
    
    //oc http svc ins
    @objc public var ocRefreshTokenUti: AnyClass?
    
}

/// 所有提示信息
public class IIHTTPModuleAlertInfo: NSObject {
    
}


/// 所有实时动态获取的属性信息
public class IIHTTPModuleDynamicParams: NSObject {
    
    /// 100104错误码处理方法
    @objc public var exchangeLV2CodeAction: ((_ requestHeader: [String: String]?) -> Void)?
    
    /// 设置rt信息的action
    @objc public var getRTAction: (() -> String)?
    
    ////IMPAccessTokenModel.activeToken()?.refreshToken
    var impAccessRT: String? {
        guard let realAction = getRTAction else { return nil }
        return realAction()
    }
    
    /// 设置AT信息的action
    @objc public var getATAction: (() -> String)?
    
    ///IMPAccessTokenModel.activeToken()?.accessToken
    var impAccessAT: String?  {
        guard let realAction = getATAction else { return nil }
        return realAction()
    }
    
    /// enterprise id
    var impUserID: String  {
        guard let realAction = enterpriseIdAction else { return "" }
        return realAction()
    }
    
    /// oauth-path
    var oauthPath: String {
        guard let realAction = getAuthPathAction else { return "" }
        return realAction()
    }
    
    /// 刷新token地址数组
    var refreshTokenPath: [String] {
        guard let realAction = getRefreshPathAction else { return [] }
        return realAction()
    }
    
    /// 刷新token地址数组
    @objc public var getRefreshPathAction: (() -> [String])?
    
    /// auth - path
    @objc public var getAuthPathAction: (() -> String)?
    
    /// user & enterpeise - action
    @objc public var enterpriseIdAction: (() -> String)?
    
    /// toast- action
    @objc public var showToastAction: ((_ showInfo: String) -> Void)?
    
    /// RouteAlert.shareInstance().show(getI18NStr(key: III18NEnum.http_not_realrequest.rawValue))
    @objc public var routeAlertAction: ((_ showInfo: String) -> Void)?
    
    /// (IIHTTPRequest.actionForlogin as? LoginIBLLOC.Type)?.doLogout()
    @objc public var logOutAction: (() -> Void)?
    
    /// IMPAccessTokenModel().exeofsetUserToken(realDic)
    @objc public var saveNewTokenAction: ((_ dic: [AnyHashable: Any]) -> Void)?
    
    /// url.isRealUrl()
    @objc public var isUrlAction: ((_ url: String) -> Bool)?
    
    /// 记录api访问日志的 action
    @objc public var apiLogAction: ((_ url: String, _ requestType: Int) -> Void)?
    
    /// 重定向 action
    @objc public var redirectAction: ((_ session: URLSession, _ task: URLSessionTask, _ response: HTTPURLResponse, _ request: URLRequest) -> URLRequest?)?
}
