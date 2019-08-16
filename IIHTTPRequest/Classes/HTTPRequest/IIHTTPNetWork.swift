//
//  HTTPRequestAnalyzeNetWork.swift
//  IIAlaSDK
//
//  Created by Noah_Shan on 2018/5/29.
//  Copyright © 2018年 Inspur. All rights reserved.
//

import Foundation

/// 网络接入状态
@objc public enum IIHTTPCurrentWWANAccessType: Int {
    case WiFi
    case gen5
    case gen4
    case gen3
    case gen2
    case unknown
    case notReachable
}

/*
 TODO:
 1.在没有VPN模式下使用ping功能来判定是否有网络[vpn下icmp协议失效]
 2.在使用VPN模式下使用系统当前链接状态来判定是否有网络
 3.sync方法直接获取的硬件网络状态
 4.async方法使用ping获取的真正联通状态
 */

public class IIHTTPNetWork: NSObject {

    static let pingTimeOut: TimeInterval = 6.5

    static let pingBarNetWorkTime: TimeInterval = 1.5

    static let connectivity = Connectivity(shouldUseHTTPS: false)
    
    /// 开启监听与设置ping服务器
    @objc public class func startService(with emmIPAdd: URL) {
        guard let appleUrl = URL(string: "https://www.apple.com") else { return }
        guard let baiduUrl = URL(string: "https://www.apple.com") else { return }
        guard let aliyunUrl = URL(string: "http://www.alidns.com") else { return }
        guard let txUrl = URL(string: "https://www.dnspod.cn") else { return }
        connectivity.connectivityURLs = [emmIPAdd, aliyunUrl, txUrl, appleUrl, baiduUrl]
        self.setPingHost()
        RealReachability.sharedInstance().startNotifier()
    }

    /// 获取当前的网络接入方式
    @objc public func getCurrentNetAccessType() -> IIHTTPCurrentWWANAccessType {
        var result: IIHTTPCurrentWWANAccessType? = nil
        let status = RealReachability.sharedInstance()?.currentReachabilityStatus() ?? ReachabilityStatus.RealStatusUnknown
        switch status {
        case .RealStatusNotReachable: result = IIHTTPCurrentWWANAccessType.notReachable
        case ReachabilityStatus.RealStatusViaWiFi: result = IIHTTPCurrentWWANAccessType.WiFi
        case .RealStatusUnknown: result = .unknown
        default: break
        }
        //
        let realStatus = RealReachability.sharedInstance()?.currentWWANtype() ?? WWANAccessType.typeUnknown
        switch realStatus {
        case .type2G: result = .gen2
        case .type3G: result = .gen3
        case .type4G: result = .gen4
        case .typeUnknown: result = result == nil ? .unknown : result
        default:
            break
        }
        return result ?? .unknown
    }
    
    /// 设置ping服务器[设置超时时间为10S]
    private class func setPingHost() {
        RealReachability.sharedInstance().hostForPing = IIHTTPModuleDoor.urlParams.pingCheckAdd
        RealReachability.sharedInstance().hostForCheck = IIHTTPModuleDoor.urlParams.pingDoubleCheckAdd
        RealReachability.sharedInstance().pingTimeout = pingTimeOut
    }
    
    /// 添加监听-多用在基类中或者工具类中，普通vc可不用
    @objc public class func addObserver(selector: Selector, observer: Any) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: NSNotification.Name.realReachabilityChanged, object: nil)
    }
    
    /// 返回真实的网络连接状态-[limit 10s,使用ping去校验网络]
    /// 这里进行二次认证 - 使用第三方来进一步判定 - 如果双重否定则是否定，否则都是真
    @objc public class func getRealNetStatus(connectAction:@escaping () -> Void, nonConnectAction: @escaping () -> Void) {
        RealReachability.sharedInstance().reachability { (status) in
            if status == ReachabilityStatus.RealStatusNotReachable {
                IIHTTPNetWork.getNetStatusWith3rd(endAction: { (results) in
                    if results {
                        connectAction()
                    } else {
                        nonConnectAction()
                    }
                })
            } else {
                connectAction()
            }
        }
    }

    /// 使用ping处理网络状态 & 返回时间线 [ping时间超过4S判定为网络差]
    /// 没有网络情况下，判定当前是否有wifi链接，如果有则认为是有小助手
    @objc public class func getNetWorkStatusAndTimeLineWithPing(connectAction: @escaping (_ pingState: PingNetWorkStatus) -> Void) {
        var timeLine: Double = 0
        let timeStart = Date().timeIntervalSince1970
        getRealNetStatus(connectAction: {
            timeLine = Date().timeIntervalSince1970 - timeStart
            if timeLine >= pingBarNetWorkTime {
                connectAction(PingNetWorkStatus.badNetWork)
            } else {
                connectAction(PingNetWorkStatus.goodWork)
            }
        }) {
            connectAction(PingNetWorkStatus.noNetWork)
        }
    }

    /// 处理网络状态-使用第三方的一个库来处理
    @objc public class func getNetStatusWith3rd(endAction: @escaping (_ haveNet: Bool) -> Void) {
        IIHTTPNetWork.connectivity.checkConnectivity { connectivity in
            switch connectivity.status {
            case .connected, .connectedViaCellular, .connectedViaWiFi :
                endAction(true)
            default:
                endAction(false)
            }
        }
    }
}
