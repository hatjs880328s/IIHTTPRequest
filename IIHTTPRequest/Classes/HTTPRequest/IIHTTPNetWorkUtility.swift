//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ** * * * *
//
// IIHTTPNetWorkUtility.swift
//
// Created by    Noah Shan on 2018/10/24
// InspurEmail   shanwzh@inspur.com
//
// Copyright © 2018年 Inspur. All rights reserved.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ** * * * *

import Foundation
import UIKit

@objc public class IIHTTPNetWorkUtility: NSObject {
    @objc public override init() {
        super.init()
    }

    /// 判定当前手机的硬件链接状态-不去判定是否真的有网络
    public func analyzeWifiOrOthers() -> HardWareNetWorkStatus {
//        guard let ocSubVw = IIHTTPNetWorkUtilityOC().getApplicationStatusBarVw() as? [UIView] else { return HardWareNetWorkStatus.noNetWork }
//        guard let anyCla = NSClassFromString("UIStatusBarDataNetworkItemView") else { return HardWareNetWorkStatus.noNetWork }
//        var realSubVw: UIView?
//        if self.isIphonex() {
//            guard let xwifi = NSClassFromString("_UIStatusBarWifiSignalView") else { return HardWareNetWorkStatus.noNetWork }
//            guard let x4g = NSClassFromString("_UIStatusBarStringView") else { return HardWareNetWorkStatus.noNetWork }
//            for vws in ocSubVw[2].subviews {
//                if vws.isKind(of: xwifi) {
//                    return HardWareNetWorkStatus.wifi
//                }
//                if vws.isKind(of: x4g) {
//                    return HardWareNetWorkStatus.g4
//                }
//            }
//            return HardWareNetWorkStatus.unknown
//        } else {
//            for eachVw in ocSubVw {
//                if eachVw.isKind(of: anyCla) {
//                    realSubVw = eachVw
//                    break
//                }
//            }
//        }
//
//        guard let typeNum = realSubVw?.value(forKey: "dataNetworkType") as? Int else { return HardWareNetWorkStatus.noNetWork }
//        switch typeNum {
//        case 0:
//            return HardWareNetWorkStatus.noNetWork
//        case 1:
//            return HardWareNetWorkStatus.g2
//        case 2:
//            return HardWareNetWorkStatus.g3
//        case 3:
//            return HardWareNetWorkStatus.g4
//        case 4:
//            return HardWareNetWorkStatus.LTE
//        case 5:
//            return HardWareNetWorkStatus.wifi
//        default:
//            return HardWareNetWorkStatus.unknown
//        }
        let result = IIHTTPNetWorkUtilityOC().networkStateFromStatebar()
        switch result {
        case -1:
            return HardWareNetWorkStatus.noNetWork
        case 0:
            return .wifi
        case 1:
            return .unknown
        case 2:
            return .g2
        case 3:
            return .g3
        case 4:
            return .g4
        default:
            return .unknown
        }
    }

    func isIphonex() -> Bool {
        if #available(iOS 11.0, *) {
            return (UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0 ) > 0
        } else {
            return false
        }
    }
}
