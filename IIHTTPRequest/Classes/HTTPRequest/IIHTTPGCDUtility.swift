//
//  IIHTTPGCDUtility.swift
//  impcloud_dev
//
//  Created by Noah_Shan on 2018/9/25.
//  Copyright © 2018 Elliot. All rights reserved.
//

import Foundation

/*
 REFRESH-TLKEN-REQUEST-SEM
 NUMBER: 1
 刷新token的信号量类
 
 */
class IIHTTPGCDUtility: NSObject {
    
    let limitqueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
    
    let semap = DispatchSemaphore(value: 1)
    
    func limitThreadCountAsyncProgress(asyncAction: @escaping () -> Void) {
        limitqueue.async {[weak self] () in
            self?.semap.wait()
            asyncAction()
        }
    }
    
    /// 释放信号量
    func releaseSignal() {
        self.semap.signal()
    }
    
    override init() {
        super.init()
    }
}
