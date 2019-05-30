//
//  *******************************************
//  
//  IIHTTPRefreshATModule.swift
//  IIHTTPRequest
//
//  Created by Noah_Shan on 2019/5/29.
//  Copyright © 2018 Inpur. All rights reserved.
//  
//  *******************************************
//

import UIKit

/*

 业务模块 - refreshATModule

 入口：

 1.业务接口访问结果为401
 2.启动APP时首先操作refreshtoken

 */

@objc public class IIHTTPRefreshATModule: NSObject {


    /// 刷新token方法[全局队列中处理]
    ///
    /// - Parameters:
    ///   - originAT: 源请求的at
    ///   - id: client-id
    ///   - secret: client-secret
    ///   - requestATURLArr: 刷新TOKEN的地址数组
    ///   - successAction: 刷新成功回调函数
    ///   - errorAction: 刷新失败回调函数
    ///   - directRequest: 直接重新请求回调
    @objc public dynamic static func refreshToken(originAT: String,
                                                  showAlertInfo: Bool,
                                          directRequest: @escaping () -> Void,
                                          successAction:@escaping (_ response: ResponseClass) -> Void,
                                          errorAction:@escaping (_ shouldLogOut: Bool, _ errorStr: String?) -> Void) {

        let refreshTokenStatusCode = self.shouldRefreshToken(oldAT: originAT)
        switch refreshTokenStatusCode {
        case .donothing:
            errorAction(false, nil)
        case .shouldDirectRequest:
            directRequest()
        case .shouldRefresh:
            IIHTTPRequest.gcdSem.limitThreadCountAsyncProgress {
                realRefreshToken(originAT: originAT, showAlertInfo: showAlertInfo, requestATURLArr: IIHTTPModuleDoor.dynamicParams.refreshTokenPath, successAction: successAction, errorAction: errorAction)
            }
        }
    }

}

// MARK: 刷新token前的判定
extension IIHTTPRefreshATModule {

    /// TOKEN更新 & 持久化
    @objc private dynamic static func saveToken(dic: NSDictionary) {
        if let realDic = dic as? [AnyHashable: Any] {
            IIHTTPModuleDoor.dynamicParams.saveNewTokenAction?(realDic)
        }
    }

    /// 判定是否需要刷新token[requesttoken: 请求url中的token;localToken: 磁盘中token]
    @objc dynamic static func shouldRefreshToken(oldAT: String) -> RefreshTokenStatusCode {
        guard let realLocalToken = IIHTTPModuleDoor.dynamicParams.impAccessAT else { return RefreshTokenStatusCode.donothing }
        if realLocalToken == "" { return RefreshTokenStatusCode.donothing }
        if oldAT.contains(realLocalToken) {
            return RefreshTokenStatusCode.shouldRefresh
        }
        return RefreshTokenStatusCode.shouldDirectRequest
    }

    /// 真正的刷新token方法[全局队列中处理]
    ///
    /// - Parameters:
    ///   - refreshTokenInfo: 旧token ^RT
    ///   - id: client-id
    ///   - secret: client-secret
    ///   - successAction: yes
    ///   - errorAction: no
    @objc private dynamic static func realRefreshToken(originAT: String,
                                                       showAlertInfo: Bool,
                                               requestATURLArr: [String],
                                               successAction:@escaping (_ response: ResponseClass) -> Void,
                                               errorAction:@escaping (_ shouldLogOut: Bool, _ errorStr: String?) -> Void) {

        let refreshToken = IIHTTPModuleDoor.dynamicParams.impAccessRT

        // 如果本地RT为空则返回 & 如果at请求地址数组为空则返回 & 原AT为空也返回
        if refreshToken == nil || refreshToken == "" || requestATURLArr.count == 0 || originAT.isEmpty {
            errorAction(false, nil)
            IIHTTPRequest.gcdSem.releaseSignal()
            return
        }
        // 设置是否需要弹错误信息
        var realAlertInfo = showAlertInfo
        if requestATURLArr.count > 1 { realAlertInfo = false }

        IIHTTPRequest.realRefreshToken(refreshTokenInfo: refreshToken!, showAlertInfo: realAlertInfo, requestURL: requestATURLArr[0], successAction: { (response) in
            self.saveToken(dic: response.dicValue)
            successAction(response)
            IIHTTPRequest.gcdSem.releaseSignal()
        }) { (errInfo) in
            if requestATURLArr.count == 1 {
                //最后一个[执行回调后再释放信号]
                guard let responseStatusCode = errInfo.responseData?.response?.statusCode else {
                    errorAction(false, errInfo.responseData?.response?.description)
                    IIHTTPRequest.gcdSem.releaseSignal()
                    return
                }
                if responseStatusCode == ResponseStatusCode.code400.rawValue {
                    errorAction(true, errInfo.responseData?.response?.description)
                } else {
                    errorAction(false, errInfo.responseData?.response?.description)
                }
                IIHTTPRequest.gcdSem.releaseSignal()
            } else {
                //不是最后一个[这里不释放信号量]
                var newURLArr = requestATURLArr
                _ = newURLArr.removeFirst()
                IIHTTPRefreshATModule.realRefreshToken(originAT: originAT, showAlertInfo: showAlertInfo, requestATURLArr: newURLArr, successAction: successAction, errorAction: errorAction)
            }
        }
    }
}
