//
//  HTTPRequestResponseProgress.swift
//  FSZCItem
//
//  Created by MrShan on 16/6/23.
//  Copyright © 2016年 Mrshan. All rights reserved.
//

import Foundation
import UIKit
@_exported import II18N

// ⑤异常处理类
open class IIHTTPRequestErrorProgress: NSObject {
    
    //var thread: IIThread?
    
    var response: DataResponse<Any>!
    
    var requestType: RequestType!
    
    var successAction:((_ response: ResponseClass) -> Void)!
    
    var errorAction: ((_ errorType: ErrorInfo) -> Void)!
    
    var showAlertInfo: Bool!
    
    init(response: DataResponse<Any>!,
         requestType: RequestType,
         showAlertInfo: Bool,
         successAction:@escaping (_ response: ResponseClass) -> Void,
         errorAction:@escaping (_ errorType: ErrorInfo) -> Void) {
    
        self.response = response
        self.showAlertInfo = showAlertInfo
        self.requestType = requestType
        self.successAction = successAction
        self.errorAction = errorAction
    }
    
    /// 异常处理
    func errorMsgProgress(_ errorInfo: ErrorInfo) {
        switch errorInfo.errorType {
        case ERRORMsgType.noConnection:
            if !showAlertInfo { return }
            //Utilities.showToast(getI18NStr(key: III18NEnum.http_request_unConnect.rawValue))
            IIHTTPModuleDoor.dynamicParams.showToastAction?(getI18NStr(key: III18NEnum.http_request_unConnect.rawValue))
        case ERRORMsgType.timeOut:
            if !showAlertInfo { return }
            //Utilities.showToast(getI18NStr(key: III18NEnum.http_request_timeout.rawValue))
            IIHTTPModuleDoor.dynamicParams.showToastAction?(getI18NStr(key: III18NEnum.http_request_timeout.rawValue))
        case ERRORMsgType.businessErrorMsg:
            // 500 400 403
            self.progress400_403_500(errorInfo: errorInfo)
        case ERRORMsgType.authError:
            // 401
            self.realRequestToken()
        case ERRORMsgType.unknowError:
            if !showAlertInfo { return }
            //Utilities.showToast(getI18NStr(key: III18NEnum.http_request_error.rawValue))
            IIHTTPModuleDoor.dynamicParams.showToastAction?(getI18NStr(key: III18NEnum.http_request_error.rawValue))
        case ERRORMsgType.code400BodyHtml:
            code400AndBodyHtmlProgress()
        case ERRORMsgType.wifiHelper:
            if let urlStr = response.response?.allHeaderFields["Location"] as? String {
                errorInfo.wifiHelperURL = URL(string: urlStr)
            }
        }
    }
    
    deinit {
        print("IIRequestErrorProgress deinit...")
    }
}

// MARK: - 错误码为400 body结构体为html，如果是refreshtoken则退出登录否则报异常
extension IIHTTPRequestErrorProgress {
    func code400AndBodyHtmlProgress() {
        if self.requestType == .refreshToken {
            self.moreThanoneUserLoginwithsameoneAPPID()
        } else {
            if !showAlertInfo { return }
            //Utilities.showToast(getI18NStr(key: III18NEnum.http_request_error.rawValue))
            IIHTTPModuleDoor.dynamicParams.showToastAction?(getI18NStr(key: III18NEnum.http_request_error.rawValue))
        }
    }
}

// MARK: - refresh-token
extension IIHTTPRequestErrorProgress {
    
    /// 重新请求token
    /// 首先处理信号量-信号量减少1，然后处理类别获取
    /// 1.只需要释放信号量
    /// 2.释放信号量 & 重新请求
    /// 3.刷新token & 重新请求 & 释放信号量
    /// defer-释放信号量
    @objc private func realRequestToken() {
//        func innerSemProgress() {
//            let refreshTokenStatusCode = self.shouldRefreshToken()
//            switch refreshTokenStatusCode {
//            case .donothing:
//                IIHTTPRequest.gcdSem.releaseSignal()
//            case .shouldDirectRequest:
//                IIHTTPRequest.gcdSem.releaseSignal()
//                self.reRequest()
//            case .shouldRefresh:
//                IIHTTPRequest.refreshToken(id: IIHTTPModuleDoor.urlParams.authHeaderID, secret: IIHTTPModuleDoor.urlParams.authHeaderSecret, successAction: { (response) in
//                    if response.dicValue == nil {
//                        IIHTTPRequest.gcdSem.releaseSignal()
//                        return
//                    }
//                    self.saveToken(dic: response.dicValue)
//                    IIHTTPRequest.gcdSem.releaseSignal()
//                    self.reRequest()
//                }) { (_) in
//                    IIHTTPRequest.gcdSem.releaseSignal()
//                }
//            }
//        }
//        IIHTTPRequest.gcdSem.limitThreadCountAsyncProgress {
//            innerSemProgress()
//        }
        guard let originRequest = self.response.request as? NSMutableURLRequest else { return }
        (IIHTTPModuleDoor.urlParams.ocRefreshTokenUti as? GetRefreshTokenFunction.Type)?.updateAuthTokenComplete(originRequest, freshToken: { (isSuccess, shouldLogOut) in
            if isSuccess {
                //成功 - 重新发起请求
                self.reRequest()
            } else {
                //失败 & 是否需要登出
                if !shouldLogOut { return }
                self.moreThanoneUserLoginwithsameoneAPPID()
            }
        })
    }
    
    /// 重新发起之前失败的网络请求[请求new token之后去重新请求;并在header中标记;如果有标记则不会再次请求]
    @objc func reRequest() {
        guard var requestHeader = self.response.request?.allHTTPHeaderFields else { return }
        guard var changeRequest = self.response.request else { return }
        guard let newAT = IIHTTPHeaderAndParams.refreshTokenGetNewAT() else { return }
        if requestHeader["IsRerequest"] != nil { return }
        requestHeader["Authorization"] = newAT
        requestHeader["IsRerequest"] = "true"
        changeRequest.allHTTPHeaderFields = requestHeader
        IIHTTPRequest.startRequest(with: changeRequest, showAlertInfo: self.showAlertInfo, successAction: self.successAction, errorAction: self.errorAction)
    }
    
    /// 是否需要刷新token[requesttoken: 请求url中的token;localToken: 磁盘中token]
    @objc func shouldRefreshToken() -> RefreshTokenStatusCode {
        let requestToken = self.response.request?.allHTTPHeaderFields?["Authorization"]
        let localToken = IIHTTPModuleDoor.dynamicParams.impAccessAT//IMPAccessTokenModel.activeToken()?.accessToken
        if requestToken == nil || localToken == nil {
            return RefreshTokenStatusCode.donothing
        }
        if requestToken!.contains(localToken!) {
            return RefreshTokenStatusCode.shouldRefresh
        }
        return RefreshTokenStatusCode.shouldDirectRequest
    }
}

/// 异常处理细节方法-此处与云+app有耦合
extension IIHTTPRequestErrorProgress {
    
    /// 请求接口出错需要将信息反馈-先保存后处理
    private func errorUpload() {
        
    }
    
    /// 401后500-退到登录页面
    private func moreThanoneUserLoginwithsameoneAPPID() {
        //(IIHTTPRequest.actionForlogin as? LoginIBLLOC.Type)?.doLogout()
        IIHTTPModuleDoor.dynamicParams.logOutAction?()
    }
    
    /// 将token更新 & 持久化
    private func saveToken(dic: NSDictionary) {
        if let realDic = dic as? [AnyHashable: Any] {
            //IMPAccessTokenModel().exeofsetUserToken(realDic)
            IIHTTPModuleDoor.dynamicParams.saveNewTokenAction?(realDic)
        }
    }
    
    /// 第二级别code处理-弹窗
    func progressLv2ErrorCode(code: String) {
        let realLv2Code = "Error_400_\(code)"
        let enumValue = III18NEnum(rawValue: realLv2Code)
        if enumValue == nil {
            if !showAlertInfo { return }
            //Utilities.showToast(getI18NStr(key: III18NEnum.http_request_error.rawValue))
            IIHTTPModuleDoor.dynamicParams.showToastAction?(getI18NStr(key: III18NEnum.http_request_error.rawValue))
            return
        }
        let alertInfo = getI18NStr(key: enumValue!.rawValue)
        if !showAlertInfo { return }
        //Utilities.showToast(alertInfo)
        IIHTTPModuleDoor.dynamicParams.showToastAction?(alertInfo)
    }
    
    /// 处理400 403 500的情况
    /// 400时-如果lv2code不为空-需要弹出二级提示信息
    /// statuscode = 400 & requestType = refreshtoken 需要跳转到登录页面
    /// (403 | 500 ) & errormsg[S返回的错误信息]不为空，则需要弹出提示信息
    private func progress400_403_500(errorInfo: ErrorInfo) {
        if errorInfo.lv2ErrorCode != nil && errorInfo.lv2ErrorCode != "" {
            // 400
            progressLv2ErrorCode(code: errorInfo.lv2ErrorCode)
        } else {
            // refreshtoken & 400 : 跳转到登录页面
            if self.response.response?.statusCode == ResponseStatusCode.code400.rawValue && self.requestType == .refreshToken {
                self.moreThanoneUserLoginwithsameoneAPPID()
                return
            }
            // 403 500
            if errorInfo.errorMsg != nil {
                if !showAlertInfo { return }
                //Utilities.showToast(errorInfo.errorMsg)
                IIHTTPModuleDoor.dynamicParams.showToastAction?(errorInfo.errorMsg)
            } else {
                if !showAlertInfo { return }
                //Utilities.showToast(getI18NStr(key: III18NEnum.http_request_error.rawValue))
                IIHTTPModuleDoor.dynamicParams.showToastAction?(getI18NStr(key: III18NEnum.http_request_error.rawValue))
            }
        }
    }
}
