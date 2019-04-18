//
//  HTTPRequestExtension.swift
//  IIAlaSDK
//
//  Created by Noah_Shan on 2018/5/29.
//  Copyright © 2018年 Inspur. All rights reserved.
//

import Foundation

/// 为request添加ext-识别其hashvalue
extension Request: Hashable {
    
    public func getHashValue() -> Int {
        let createTime = self.startTime
        let url = self.request?.url
        let hashValue = (createTime!.description + url!.absoluteString).hashValue
        
        return hashValue
    }
    
    public var hashValue: Int {
        
        return getHashValue()
    }
    
    public static func == (lhs: Request, rhs: Request) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
