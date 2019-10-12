//
//  AlamofireDatatool.swift
//  DataPresistenceLayer
//
//  Created by MrShan on 16/6/13.
//  Copyright © 2016年 Mrshan. All rights reserved.
//

import Foundation

/*
 思路走一波：

 TODO:
 将网络请求封装到此core中
 1.网络请求 ✅
 2.数据上传 ✅
 3.数据下载 ✅
 4.网络实时监控与实时状态获取core ✅

 目前处理方式：
 ①首先处理网络无连接与网络连接超时状态-response.result.isFail -1001 & -1003 & -1009
 ②经过第一步确认有返回值，既response-result是有值的，此时处理code[200~300,300~500]
 ③经过第二步处理后在分析contenttype,分为 text/plain & application/json; charset=utf-8 & text/html
 ④根据第二步中的code和第三步中的type一起来分析数据
 ⑤错误处理类：HTTPRequestErrorProgress此处与当前APP业务有耦合

 注意：
 ①：urlencoding & jsonencoding 在此处的区别是：
 前者会将contenttype设置为application/x-www-form-urlencoded
 后者会将contenttype设置为application/json
 所以请求|刷新token需要编码为urlencoding,普通请求即为jsonencoding
 ②：刷新token時需要将刷新token任务+锁：
 因为多次刷新token时会造成  status=refreshtoken & code=400 跳转到登录页、这种情况是错误的
 ③：关于at & rt：
 at失效之前使用rt请求时，返回的是原来的at & rt
 at失效后使用rt请求，返回的是新的一组 at & rt，原来的at & rt全部失效
 at失效时间是8H,rt没有失效时间
 ④：关于301 & 302
 302代表的是临时性重定向，我们需要的就是这种临时重定向 来检测wifi助手
 301是永久重定向
 参考：https://www.cnblogs.com/timeismoney/p/7117779.html
 */

open class IIHTTPRequest: IIHTTPRequestFather {

    override private init() { super.init() }

    static public let refreshTokenOperationLock = NSRecursiveLock()

    static let gcdSem: IIHTTPGCDUtility = IIHTTPGCDUtility()

    static var actionForlogin: AnyClass?

    /// 静态网络请求-优先判断网络状态
    ///
    /// - Parameters:
    ///   - url: URL<String>
    ///   - showAlertInfo: 是否有必要弹出错误提示，默认为true
    ///   - shouldGetRedirect: 是否有必要捕获wifi小助手，默认关闭
    ///   - params: 参数
    ///   - header: header
    ///   - successAction: success action <ResponseClass>
    ///   - errorAction: error action <ErrorInfo>
    @objc override open class func startRequest(
        showAlertInfo: Bool = true,
        shouldGetRedirect: Bool = false,
        method: IIHTTPMethod,
        url: String,
        params: [String: Any]?,
        header: [String: String]? = nil,
        timeOut: TimeInterval = 15,
        encodingType: ParamsSeriType = .jsonEncoding,
        requestType: RequestType = .normal,
        successAction:@escaping (_ response: ResponseClass) -> Void,
        errorAction:@escaping (_ errorType: ErrorInfo) -> Void) {

        super.startRequest(method: method, url: url, params: params, successAction: successAction, errorAction: errorAction)
        if !IIHTTPHeaderAndParams.progressURL(url: url) { return }
        let httpHeader = IIHTTPHeaderAndParams.analyzeHTTPHeader(header)
        let httpMethod = method.changeToAlaMethod()
        let requestManager = IIHTTPHeaderAndParams.redirectURL(progress: shouldGetRedirect)
        var realEncoding: ParamsSeriType = encodingType
        if method == .get {
            realEncoding = .urlEncoding
        }
        let httpRencoding = IIHTTPHeaderAndParams.getTrueEncodingType(param: realEncoding)
        do {
            let req = try URLRequest(url: URL(string: url)!, method: httpMethod, headers: httpHeader)
            var reqEncode = try httpRencoding.encode(req, with: params)
            reqEncode.timeoutInterval = timeOut
            let startRuestTime = Date().timeIntervalSince1970
            _ = requestManager.request(reqEncode).responseJSON { (response) in
                let endRuestTime = Date().timeIntervalSince1970
                NotificationCenter.default.post(name: NSNotification.Name.init("IIHTTPModuleDoor_urlParams_responseNotiName"), object: nil, userInfo: ["RES": response, "START": startRuestTime, "END": endRuestTime])
                let resultResponse = IHTTPProgressAFNCode.progressResponse(response: response)
                if resultResponse.errorValue == nil {
                    successAction(resultResponse)
                } else {
                    let errorProgressIns = IIHTTPRequestErrorProgress(response: response, requestType: requestType, showAlertInfo: showAlertInfo, successAction: successAction, errorAction: errorAction)
                    errorProgressIns.errorMsgProgress(resultResponse.errorValue)
                    errorAction(resultResponse.errorValue)
                }
            }
        } catch {}
    }

    /// 401刷新token后[再次调用原始接口]-非业务人员调用
    @objc open override class func startRequest(
        with urlrequest: URLRequest,
        showAlertInfo: Bool,
        successAction:@escaping (_ response: ResponseClass) -> Void,
        errorAction:@escaping (_ errorType: ErrorInfo) -> Void) {

        super.startRequest(with: urlrequest, showAlertInfo: showAlertInfo, successAction: successAction, errorAction: errorAction)
        _ = request(urlrequest).responseJSON { (response) in
            let resultResponse = IHTTPProgressAFNCode.progressResponse(response: response)
            if resultResponse.errorValue == nil {
                successAction(resultResponse)
            } else {
                let errorProgressIns = IIHTTPRequestErrorProgress(response: response, requestType: .normal, showAlertInfo: showAlertInfo, successAction: successAction, errorAction: errorAction)
                errorProgressIns.errorMsgProgress(resultResponse.errorValue)
                errorAction(resultResponse.errorValue)
            }
        }
    }

    /// 请求token
    ///
    /// - Parameters:
    ///   - userName: 用户帐号
    ///   - userPwd: 用户密码
    ///   - id: client-id
    ///   - secret: client-secret
    ///   - successAction: yes
    ///   - errorAction: no
    @objc open class func requestToken(userName: String,
                                       userPwd: String,
                                       id: String,
                                       secret: String,
                                       successAction:@escaping (_ response: ResponseClass) -> Void,
                                       errorAction:@escaping (_ errorType: ErrorInfo) -> Void) {

        let params = IIHTTPHeaderAndParams.getRequestTokenParams(userName: userName, userPwd: userPwd, id: id, secret: secret)
        let header = IIHTTPHeaderAndParams.getRequestTokenHeader()
        IIHTTPRequest.startRequest(method: .post, url: IIHTTPModuleDoor.dynamicParams.oauthPath, params: params, header: header, encodingType: .urlEncoding, requestType: .requestToken, successAction: { (response) in
            successAction(response)
        }) { (error) in
            errorAction(error)
        }
    }

    /// 刷新token[被IIHTTPRefreshATModule调用]
    ///
    /// - Parameters:
    ///   - refreshTokenInfo: 旧token ^RT
    ///   - id: client-id
    ///   - secret: client-secret
    ///   - successAction: yes
    ///   - errorAction: no
    @objc public class func realRefreshToken(refreshTokenInfo: String,
                                             showAlertInfo: Bool,
                                             requestURL: String,
                                             successAction:@escaping (_ response: ResponseClass) -> Void,
                                             errorAction:@escaping (_ errorType: ErrorInfo) -> Void) {
        let params = IIHTTPHeaderAndParams.getRefreshTokenParams(refreshTokenInfo: refreshTokenInfo)
        let header = IIHTTPHeaderAndParams.getRefreshTokenHeader(id: IIHTTPModuleDoor.urlParams.authHeaderSecret, secret: IIHTTPModuleDoor.urlParams.authHeaderSecret)
        IIHTTPRequest.startRequest(showAlertInfo: showAlertInfo, method: .post, url: requestURL, params: params, header: header, timeOut: 30, encodingType: .urlEncoding, requestType: .refreshToken, successAction: { (response) in
            successAction(response)
        }) { (error) in
            errorAction(error)
        }
    }
}
