//
//  IHTHTTPCoreParametersProgress.swift
//  Htime
//
//  Created by xin on 2020/3/6.
//  Copyright © 2020 Inspur. All rights reserved.
//

import UIKit

/// 处理iht params
class IHTHTTPCoreParametersProgress: NSObject {
    func progressParams(params: [String: Any]?) -> [String: Any] {
        guard let realParams = params else {
            return ["token": IIHTTPModuleDoor.dynamicParams.ihttoken]
        }
        if realParams["token"] != nil {
            return realParams
        }
        var newParams = realParams
        
        newParams["token"] = IIHTTPModuleDoor.dynamicParams.ihttoken
        
        return newParams
    }
}
