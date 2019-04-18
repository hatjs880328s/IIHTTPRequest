//
//  IHTTPProgressAFNCode.swift
//  impcloud_dev
//
//  Created by Noah_Shan on 2018/8/2.
//  Copyright © 2018 Elliot. All rights reserved.
//

import Foundation

/// ①：处理afn&alamofire自己的错误码[1001 1003 1009]没有联通Remote server时的错误
/// 在这一步将所有的afn&alamofire的异常都解决，下一步只处理statusCode
class IHTTPProgressAFNCode: NSObject {
    
    private static let timeOutCode: Int = -1_001
    
    private static let timeOutCodeOthers: Int = -1_003
    
    private static let unConCode: Int = -1_009
    
    /// 处理返回数据<无需判断response.issuccess & fail 因为无论失败与否都需要判定code>
    open class func progressResponse(response: DataResponse<Any>) -> ResponseClass {
        // time out & no connection & unknow
        if let errorInfo = response.result.error as NSError? {
            if errorInfo.code == timeOutCodeOthers || errorInfo.code == timeOutCode {
                return ResponseFactoary().responseInstance(data: response, responseType: ResponseContentType.html, errorType: ERRORMsgType.timeOut)
            }
            if errorInfo.code == unConCode {
                return ResponseFactoary().responseInstance(data: response, responseType: ResponseContentType.html, errorType: ERRORMsgType.noConnection)
            }
        }
        // unknow - 其他的失败都是unknow
        if response.response?.statusCode == nil {
            return ResponseFactoary().responseInstance(data: response, responseType: ResponseContentType.html, errorType: ERRORMsgType.unknowError)
        }
        // progress code[response-code]
        let codeIns = HTTPRequestCodeFactory().getInstance(response: response)
        return codeIns.responseIns
    }
    
}
