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

    //IIAPIStruct().oauthPath
    @objc public var oauthPath = ""

    //IIAPIStruct().pintFirstCheckAdd
    @objc public var pingCheckAdd = ""

    //ping double check add
    @objc public var pingDoubleCheckAdd = ""

    //IMPAccessTokenModel.activeToken()?.tokenType
    @objc public var impTokenType = ""

    //IMPUserModel.activeInstance()?.enterprise?.id.description
    @objc public var impUserID = ""

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

    @objc public var ocRefreshTokenUti: GetRefreshTokenFunctionProtocal?

}

/// 所有提示信息
public class IIHTTPModuleAlertInfo: NSObject {
    
    //Utilities.showToast(getI18NStr(key: III18NEnum.http_request_unConnect.rawValue))
    //@objc public var unConnect = ""


}


/// 所有实时动态获取的属性信息
public class IIHTTPModuleDynamicParams: NSObject {

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
    
}
