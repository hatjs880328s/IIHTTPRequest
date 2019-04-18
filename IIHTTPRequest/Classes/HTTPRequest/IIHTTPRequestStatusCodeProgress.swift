//
//  IIHTTPRequestStatusCodeProgress.swift
//  IIAlaSDK
//
//  Created by Noah_Shan on 2018/5/29.
//  Copyright © 2018年 Inspur. All rights reserved.
//

import Foundation

/// ②分类response-statusCode
/// 这一步必然拥有Status-code
class HTTPRequestCodeFactory: NSObject {
    func getInstance(response: DataResponse<Any> ) -> IIHTTPRequestStatusCodeProgress {
        switch response.response!.statusCode {
        case ResponseStatusCode.code200.rawValue:
            return Code200(response: response)//需要继续处理
        case ResponseStatusCode.code302.rawValue:
            return Code302(response: response)//抛出wifihelper错误
//        case ResponseStatusCode.code301.rawValue:
//            return Code302(response: response)//抛出wifihelper错误[和302相同]
        case ResponseStatusCode.code400.rawValue:
            return Code400(response: response)//需要继续处理
        case ResponseStatusCode.code401.rawValue:
            return Code401(response: response)//只需要抛出authError
        case ResponseStatusCode.code403.rawValue:
            return Code403(response: response)//需要继续处理
        case ResponseStatusCode.code500.rawValue:
            return Code500(response: response)//需要继续处理
        default:
            return CodeOthers(response: response)//只需要抛出unknowerror
        }
    }
}

/// 状态码处理父类
class IIHTTPRequestStatusCodeProgress: NSObject {
    
    var code: Int!
    
    var request: URLRequest!
    
    var responseIns: ResponseClass!
    
    var responseData: DataResponse<Any>!
    
    let contentType = "Content-Type"
    
    init(response: DataResponse<Any> ) {
        super.init()
        self.request = response.request!
        self.code = response.response!.statusCode
        self.responseData = response
        self.progress()
    }
    
    func progress() {}
    
    /// progress 200
    func progressContentType(response: DataResponse<Any>) -> ResponseClass {
        guard let contentType = (response.response?.allHeaderFields[self.contentType] as? NSString)?.replacingOccurrences(of: " ", with: "").lowercased() else {
            return ResponseFactoary().responseInstance(data: response, responseType: ResponseContentType.others)
        }
        // json response
        if contentType.contains(ResponseContentType.json.rawValue) {
            return ResponseFactoary().responseInstance(data: response, responseType: ResponseContentType.json)
        // proto buf response
        } else if contentType.contains(ResponseContentType.protoBuf.rawValue) {
            return ResponseFactoary().responseInstance(data: response, responseType: ResponseContentType.protoBuf)
        // html response
        } else if contentType.contains(ResponseContentType.html.rawValue) {
            return ResponseFactoary().responseInstance(data: response, responseType: ResponseContentType.html)
        // others-unknow
        } else {
            return ResponseFactoary().responseInstance(data: response, responseType: ResponseContentType.others)
        }
    }
}

/// otherCode，抛出unknowerror
class CodeOthers: IIHTTPRequestStatusCodeProgress {
    override func progress() {
        self.responseIns = ResponseFactoary().responseInstance(data: self.responseData, responseType: ResponseContentType.html, errorType: ERRORMsgType.unknowError)
    }
}

/// 200，需要继续处理response.data-json/probuf/string
class Code200: IIHTTPRequestStatusCodeProgress {
    override func progress() {
        self.responseIns = self.progressContentType(response: self.responseData)
    }
}

/// 302，直接返回wifihelper
class Code302: IIHTTPRequestStatusCodeProgress {
    override func progress() {
        if let locationStr = (responseData.response?.allHeaderFields["Location"] as? String) {
            if locationStr != IIHTTPModuleDoor.urlParams.wifiHelperURL {
                self.responseIns = ResponseFactoary().responseInstance(data: responseData!, responseType: ResponseContentType.html, errorType: ERRORMsgType.wifiHelper)
            } else {
                self.responseIns = ResponseFactoary().responseInstance(data: self.responseData, responseType: ResponseContentType.html, errorType: ERRORMsgType.unknowError)
            }
        } else {
            self.responseIns = ResponseFactoary().responseInstance(data: self.responseData, responseType: ResponseContentType.html, errorType: ERRORMsgType.unknowError)
        }
    }
}

/// 400比较特殊，同200处理方式
class Code400: IIHTTPRequestStatusCodeProgress {
    override func progress() {
        self.responseIns = self.progressContentType(response: self.responseData)
    }
}

/// 401，直接暴露给业务层即可
class Code401: IIHTTPRequestStatusCodeProgress {
    override func progress() {
        self.responseIns = ResponseFactoary().responseInstance(data: self.responseData, responseType: ResponseContentType.html, errorType: ERRORMsgType.authError)
    }
}

/// 403，继续向下处理
class Code403: IIHTTPRequestStatusCodeProgress {
    override func progress() {
        self.responseIns = self.progressContentType(response: self.responseData)
    }
}

/// 500，继续向下处理
class Code500: IIHTTPRequestStatusCodeProgress {
    override func progress() {
        self.responseIns = self.progressContentType(response: self.responseData)
    }
}
