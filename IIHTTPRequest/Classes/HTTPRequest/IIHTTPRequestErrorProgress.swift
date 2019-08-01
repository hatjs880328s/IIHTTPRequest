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

    var response: DataResponse<Any>!
    
    var requestType: RequestType!
    
    var successAction:((_ response: ResponseClass) -> Void)!
    
    var errorAction: ((_ errorType: ErrorInfo) -> Void)!
    
    var showAlertInfo: Bool!

    /// exchange should relogin code
    private let exchangeLV2Code = "100401"
    
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
            // 没有网络连接 - 提示即可
            if !showAlertInfo { return }
            IIHTTPModuleDoor.dynamicParams.showToastAction?(getI18NStr(key: III18NEnum.http_request_unConnect.rawValue))
        case ERRORMsgType.timeOut:
            // 连接超时 - 提示即可
            if !showAlertInfo { return }
            IIHTTPModuleDoor.dynamicParams.showToastAction?(getI18NStr(key: III18NEnum.http_request_timeout.rawValue))
        case ERRORMsgType.businessErrorMsg:
            // 500 400 403错误 - 按需要提示
            self.progress400_403_500(errorInfo: errorInfo)
        case ERRORMsgType.authError:
            // 401 - 刷新token
            self.refreshToken()
        case ERRORMsgType.unknowError:
            // 未知错误 - 提示即可
            if !showAlertInfo { return }
            IIHTTPModuleDoor.dynamicParams.showToastAction?(getI18NStr(key: III18NEnum.http_request_error.rawValue))
        case ERRORMsgType.code400BodyHtml:
            // 400 后的HTML返回 - 退出登录
            code400AndBodyHtmlProgress()
        case ERRORMsgType.wifiHelper:
            // 小助手 - 赋值即可
            if let urlStr = response.response?.allHeaderFields["Location"] as? String {
                errorInfo.wifiHelperURL = URL(string: urlStr)
            }
        }
    }
    
    deinit {
        print("IIRequestErrorProgress deinit...")
    }
}

// MARK: - 401后的refreshtoken
extension IIHTTPRequestErrorProgress {

    /// 刷新token操作
    func refreshToken() {
        let oldAT = self.response.request?.allHTTPHeaderFields?["Authorization"] ?? ""
        IIHTTPRefreshATModule.refreshToken(originAT: oldAT, showAlertInfo: false, directRequest: {
            self.reRequest()
        }, successAction: { (response) in
            self.reRequest()
        }) { (shouldLogOut, _) in
            if !shouldLogOut { return }
            self.moreThanoneUserLoginwithsameoneAPPID()
        }
    }
}

/// 异常处理细节方法-此处与云+app有耦合
extension IIHTTPRequestErrorProgress {

    /// 重新发起之前失败的网络请求[请求new token之后去重新请求;并在header中标记;如果有标记则不会再次请求]
    @objc func reRequest() {
        guard var requestHeader = self.response?.request?.allHTTPHeaderFields else { return }
        guard var changeRequest = self.response.request else { return }
        guard let newAT = IIHTTPHeaderAndParams.refreshTokenGetNewAT() else { return }
        if requestHeader["IsRerequest"] != nil { return }
        requestHeader["Authorization"] = newAT
        requestHeader["IsRerequest"] = "true"
        changeRequest.allHTTPHeaderFields = requestHeader
        IIHTTPRequest.startRequest(with: changeRequest, showAlertInfo: self.showAlertInfo, successAction: self.successAction, errorAction: self.errorAction)
    }
    
    /// 退到登录页面
    private func moreThanoneUserLoginwithsameoneAPPID() {
        IIHTTPModuleDoor.dynamicParams.logOutAction?()
    }
    
    /// 第二级别code处理-弹窗
    func progressLv2ErrorCode(code: String) {
        if code == self.exchangeLV2Code {
            IIHTTPModuleDoor.dynamicParams.exchangeLV2CodeAction?(self.response.request?.allHTTPHeaderFields)
            return
        }
        let realLv2Code = "Error_400_\(code)"
        let enumValue = III18NEnum(rawValue: realLv2Code)
        if enumValue == nil {
            if !showAlertInfo { return }
            IIHTTPModuleDoor.dynamicParams.showToastAction?(getI18NStr(key: III18NEnum.http_request_error.rawValue))
            return
        }
        let alertInfo = getI18NStr(key: enumValue!.rawValue)
        if !showAlertInfo { return }
        IIHTTPModuleDoor.dynamicParams.showToastAction?(alertInfo)
    }

    /// 错误码为400 body数据类型为html，如果是refreshtoken则退出登录否则报异常
    func code400AndBodyHtmlProgress() {
//        if self.requestType == .refreshToken {
//            self.moreThanoneUserLoginwithsameoneAPPID()
//        } else {
//            if !showAlertInfo { return }
//            IIHTTPModuleDoor.dynamicParams.showToastAction?(getI18NStr(key: III18NEnum.http_request_error.rawValue))
//        }
        if !showAlertInfo { return }
        IIHTTPModuleDoor.dynamicParams.showToastAction?(getI18NStr(key: III18NEnum.http_request_error.rawValue))
    }
    
    /// 处理400 403 500的情况
    /// 400时-如果lv2code不为空-需要弹出二级提示信息
    /// statuscode = 400 & requestType = refreshtoken 不处理
    /// (403 | 500 ) & errormsg[返回的错误信息]不为空，弹出提示信息
    private func progress400_403_500(errorInfo: ErrorInfo) {
        if errorInfo.lv2ErrorCode != nil && errorInfo.lv2ErrorCode != "" {
            // 400
            progressLv2ErrorCode(code: errorInfo.lv2ErrorCode)
        } else {
            // refreshtoken & 400 : 跳转到登录页面
            if self.response.response?.statusCode == ResponseStatusCode.code400.rawValue && self.requestType == .refreshToken {
                return
            }
            // 403 500
            if errorInfo.errorMsg != nil {
                if !showAlertInfo { return }
                IIHTTPModuleDoor.dynamicParams.showToastAction?(errorInfo.errorMsg)
            } else {
                if !showAlertInfo { return }
                IIHTTPModuleDoor.dynamicParams.showToastAction?(getI18NStr(key: III18NEnum.http_request_error.rawValue))
            }
        }
    }
}
