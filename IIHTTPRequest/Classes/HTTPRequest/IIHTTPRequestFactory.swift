//
//  HTTPRequestFactory.swift
//  FSZCItem
//
//  Created by MrShan on 16/6/23.
//  Copyright © 2016年 Mrshan. All rights reserved.
//

import Foundation

/// ③根据statusCode & response-type[json data html]数据处理
open class ResponseFactoary: NSObject {
    func responseInstance(data: DataResponse<Any>, responseType: ResponseContentType, errorType: ERRORMsgType? = nil) -> ResponseClass {
        // error不为空直接抛出responseClass
        if errorType != nil {
            return ResponseERROR(data: data, errorType: errorType!)
        }
        switch responseType {
        case .json:
            return ResponseJSON(data: data)
        case .protoBuf:
            return ResponseProtoBuf(data: data)
        case .html:
            return ResponseHTML(data: data)
        case .others:
            return ResponseERROR(data: data, errorType: ERRORMsgType.unknowError)
        }
    }
}

/// 返回数据类（基类）
open class ResponseClass: NSObject {
    
    /// 错误 可为nil
    @objc public var errorValue: ErrorInfo!
    
    /// 结果dic 可为nil
    @objc public var dicValue: NSDictionary!
    
    /// 结果arr 可为nil
    @objc public var arrValue: NSArray!
    
    /// 结果string 可为nil
    @objc public var anyValue: AnyObject!
    
    /// 结果中的response-为了给OC使用，swift中目前为结构体
    @objc public var ocResponse: HTTPOCResponse!
    
    /// alamofire-response，包含 [request & response]
    var response: DataResponse<Any>! {
        didSet {
            self.ocResponse = HTTPOCResponse(request: response.request, response: response.response, responseData: response.data)
        }
    }
    
    init(data: DataResponse<Any>, errorType: ERRORMsgType? = nil) {
        super.init()
        self.setData(data)
        if errorType != nil {
            self.errorValue = ErrorInfo(data: response, type: errorType!)
        }
    }
    
    func setData(_ data: DataResponse<Any>) {
        self.response = data
    }
}

/// 返回数据类型-错误类型
open class ResponseERROR: ResponseClass {
    override func setData(_ data: DataResponse<Any>) {
        super.setData(data)
        // 构造方法中已经处理
    }
}

/// 返回数据类型-HTML
open class ResponseHTML: ResponseClass {
    override func setData(_ data: DataResponse<Any>) {
        super.setData(data)
        if data.response?.statusCode == ResponseStatusCode.code400.rawValue {
            self.errorValue = ErrorInfo(data: response, type: ERRORMsgType.code400BodyHtml)
        } else {
            self.errorValue = ErrorInfo(data: response, type: ERRORMsgType.unknowError)
        }
    }
}

/// 返回数据类-JSON
open class ResponseJSON: ResponseClass {
    override func setData(_ data: DataResponse<Any>) {
        super.setData(data)
        if let dicValue = data.value as? NSDictionary {
            if self.progressStupidErrmsg(dicValue) { return }
            self.dicValue = dicValue
            return
        }
        if let arrValue = data.value as? NSArray {
            self.arrValue = arrValue
            return
        }
        //str value
        self.anyValue = data.value as AnyObject
        return
    }
    
    /// 业务逻辑返回错误码+错误信息 true: 是 false: 没返回
    /// 这个方法由于EMM ECM 不统一的数据结构导致代码有些许的丑陋
    private func progressStupidErrmsg(_ data: NSDictionary) -> Bool {
        if data["ErrorType"] != nil || data["errCode"] != nil || data["msg"] != nil || data["error"] != nil {
            var emptyStr = ""
            let errMsg = "\(data["msg"] ?? emptyStr)"
            if errMsg == "" {
                emptyStr = III18NEnum.http_request_error.rawValue
            }
            self.errorValue = ErrorInfo(data: response, type: ERRORMsgType.businessErrorMsg, errorMsg: errMsg)
            self.errorValue.setLv2ErrorCode(with: "\(data["code"] ?? (data["errCode"] ?? ""))")
            return true
        } else {
            return false
        }
    }
}

/// 返回数据类-protobuf <Data>
open class ResponseProtoBuf: ResponseClass {
    
    override func setData(_ data: DataResponse<Any>) {
        super.setData(data)
    }
}
