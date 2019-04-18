//
//  IIHTTPErrorInfo.swift
//  impcloud_dev
//
//  Created by Noah_Shan on 2018/8/2.
//  Copyright © 2018 Elliot. All rights reserved.
//

import Foundation

/// 包含错误类型、错误信息
public class ErrorInfo: NSObject {
    
    /// 这里给初值完全是因为让oc能调用到
    public var errorType: ERRORMsgType = ERRORMsgType.unknowError
    
    var errorMsg: String!
    
    /// 第二级错误码[400]下的Error_400_72001
    var lv2ErrorCode: String!

    /// 小助手url地址
    var wifiHelperURL: URL?

    /// 返回数据
    var responseData: Data?
    
    init(data: Data?, type: ERRORMsgType, errorMsg: String? = nil) {
        self.errorType = type
        self.errorMsg = errorMsg
        self.responseData = data
    }
    
    func setLv2ErrorCode(with code: String) {
        self.lv2ErrorCode = code
    }
}
