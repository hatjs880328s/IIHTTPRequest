//
//  *******************************************
//  
//  IHTHTTPCore.swift
//  Htime
//
//  Created by Noah_Shan on 2020/3/6.
//  Copyright © 2018 Inpur. All rights reserved.
//  
//  *******************************************
//


import UIKit

open class IHTHTTPCore: IIHTTPRequestFather {

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
        let httpHeader = IIHTTPHeaderAndParams.ihtanalyzeHTTPHeader(header)
        let httpMethod = method.changeToAlaMethod()
        let requestManager = IIHTTPHeaderAndParams.redirectURL(progress: shouldGetRedirect)
        var realEncoding: ParamsSeriType = encodingType
        if method == .get {
            realEncoding = .urlEncoding
        }
        let httpRencoding = IIHTTPHeaderAndParams.getTrueEncodingType(param: realEncoding)
        let newParams = IHTHTTPCoreParametersProgress().progressParams(params: params)
        do {
            let req = try URLRequest(url: URL(string: url)!, method: httpMethod, headers: httpHeader)
            var reqEncode = try httpRencoding.encode(req, with: newParams)
            reqEncode.timeoutInterval = timeOut
            let startRuestTime = Date().timeIntervalSince1970
            // ---这里需要加上对body-sum的校验--- start
            if method == .get {
                let bodySum = IIHTTPModuleDoor.dynamicParams.progressHttpBody?(nil, reqEncode.url?.query) ?? ""
                reqEncode.addValue(bodySum, forHTTPHeaderField: "body-sum")
            } else {
                let bodySum = IIHTTPModuleDoor.dynamicParams.progressHttpBody?(reqEncode.httpBody as? NSData, nil) ?? ""
                reqEncode.addValue(bodySum, forHTTPHeaderField: "body-sum")
            }

            // ---这里需要加上对body-sum的校验--- end
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

}
