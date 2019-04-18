//
//  IIHTTPOCResponse.swift
//  impcloud_dev
//
//  Created by Noah_Shan on 2018/8/2.
//  Copyright © 2018 Elliot. All rights reserved.
//

import Foundation

/// swift中的 dataresponse- 转义到oc中的nsobject子类
/// 结果中的response-为了给OC使用，swift中目前为结构体
public class HTTPOCResponse: NSObject {
    
    @objc public var ocRequest: URLRequest?
    
    @objc public var ocResponse: HTTPURLResponse?

    @objc public var responseData: Data?
    
    @objc public init(request: URLRequest?, response: HTTPURLResponse?, responseData: Data?) {
        super.init()
        self.ocRequest = request
        self.ocResponse = response
        self.responseData = responseData
    }
}
