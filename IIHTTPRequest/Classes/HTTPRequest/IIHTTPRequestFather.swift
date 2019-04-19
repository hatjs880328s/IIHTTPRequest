//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ** * * * *
//
// IIHTTPRequestFather.swift
//
// Created by    Noah Shan on 2018/10/26
// InspurEmail   shanwzh@inspur.com
//
// Copyright © 2018年 Inspur. All rights reserved.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ** * * * *

import Foundation

/// 请求父类-为了处理日志记录
open class IIHTTPRequestFather: NSObject {

    /// 是否上传日志-默认关闭
    @objc static var uploadLog: Bool = false

    @objc public static func startUploadLogService() {
        uploadLog = true
    }

    @objc public static func stopUploadLogService() {
        uploadLog = false
    }

    @objc public class func startRequest(showAlertInfo: Bool = true,
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
        writeLog(url: url, requestType: requestType)
    }

    @objc open class func startRequest(with urlrequest: URLRequest,
                                       showAlertInfo: Bool,
                                       successAction:@escaping (_ response: ResponseClass) -> Void,
                                       errorAction:@escaping (_ errorType: ErrorInfo) -> Void) {
        writeLog(url: urlrequest.url?.absoluteString, requestType: .refreshTokenThenRequest)
    }

    @objc public static func writeLog(url: String?, requestType: RequestType) {
        if uploadLog {
//            let item = APIEvent()
//            item.setBaseInfo(apiName: url ?? "", time: Date(), requestType: requestType.rawValue)
//            AOPDiskIOProgress.getInstance().writeEventsToDisk(with: [NSUUID().uuidString: [item]])
            IIHTTPModuleDoor.dynamicParams.apiLogAction?(url ?? "", requestType.rawValue)
        }
    }
}
