//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ** * * * *
//
// IIHTTPNetWorkUtility.m
//
// Created by    Noah Shan on 2018/10/29
// InspurEmail   shanwzh@inspur.com
//
// Copyright © 2018年 Inspur. All rights reserved.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ** * * * *


#import "IIHTTPNetWorkUtilityOC.h"
#import <UIKit/UIKit.h>

@implementation IIHTTPNetWorkUtilityOC

- (NSArray *)getApplicationStatusBarVw {
    UIApplication *application = [UIApplication sharedApplication];
    NSArray *children;
    if([[application valueForKeyPath:@"_statusBar"] isKindOfClass:NSClassFromString(@"UIStatusBar_Modern")]) {
        children = [[[[application valueForKeyPath:@"_statusBar"] valueForKeyPath:@"_statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    } else if ([[application valueForKeyPath:@"_statusBar"] isKindOfClass:NSClassFromString(@"UIStatusBar")]){
        children = [[[application valueForKeyPath:@"_statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    }else{
    }

    return children;
}

/// HardWareNetWorkStatus [0: wifi 1: 1g或其他 2: 2g 3: 3g 4: 4g -1 have no]
- (int)networkStateFromStatebar {
    __block int returnValue = -1;
    if (![[NSThread currentThread] isMainThread]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            returnValue = [self networkStateFromStatebar];
        });
        return returnValue;
    }
    id _statusBar = nil;
    if (@available(iOS 13.0, *)) {
        /*
         We can still get statusBar using the following code, but this is not recommended.
         */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        UIStatusBarManager *statusBarManager = [UIApplication sharedApplication].keyWindow.windowScene.statusBarManager;
        if ([statusBarManager respondsToSelector:@selector(createLocalStatusBar)]) {
            UIView *_localStatusBar = [statusBarManager performSelector:@selector(createLocalStatusBar)];
            if ([_localStatusBar respondsToSelector:@selector(statusBar)]) {
                _statusBar = [_localStatusBar performSelector:@selector(statusBar)];
            }
        }
#pragma clang diagnostic pop
        if (_statusBar) {
            // _UIStatusBarDataCellularEntry
            id currentData = [[_statusBar valueForKeyPath:@"_statusBar"] valueForKeyPath:@"currentData"];
            id _wifiEntry = [currentData valueForKeyPath:@"wifiEntry"];
            id _cellularEntry = [currentData valueForKeyPath:@"cellularEntry"];
            if (_wifiEntry && [[_wifiEntry valueForKeyPath:@"isEnabled"] boolValue]) {
                // If wifiEntry is enabled, is WiFi.
                returnValue = 0;
            } else if (_cellularEntry && [[_cellularEntry valueForKeyPath:@"isEnabled"] boolValue]) {
                NSNumber *type = [_cellularEntry valueForKeyPath:@"type"];
                if (type) {
                    switch (type.integerValue) {
                        case 5:
                            returnValue = 4;
                            break;
                        case 4:
                            returnValue = 3;
                            break;
                            //                        case 1: // Return 1 when 1G.
                            //                            break;
                        case 0:
                            // Return 0 when no sim card.
                            returnValue = -1;
                        default:
                            returnValue = 1;
                            break;
                    }
                }
            }
        }
    } else {
        UIApplication *app = [UIApplication sharedApplication];
        _statusBar = [app valueForKeyPath:@"_statusBar"];

        if ([_statusBar isKindOfClass:NSClassFromString(@"UIStatusBar_Modern")]) {
            // For iPhoneX
            NSArray *children = [[[_statusBar valueForKeyPath:@"_statusBar"] valueForKeyPath:@"foregroundView"] subviews];
            for (UIView *view in children) {
                for (id child in view.subviews) {
                    if ([child isKindOfClass:NSClassFromString(@"_UIStatusBarWifiSignalView")]) {
                        returnValue = 0;
                        break;
                    }
                    if ([child isKindOfClass:NSClassFromString(@"_UIStatusBarStringView")]) {
                        NSString *originalText = [child valueForKey:@"_originalText"];
                        if ([originalText containsString:@"G"]) {
                            if ([originalText isEqualToString:@"2G"]) {
                                returnValue = 2;
                            } else if ([originalText isEqualToString:@"3G"]) {
                                returnValue = 3;
                            } else if ([originalText isEqualToString:@"4G"]) {
                                returnValue = 4;
                            } else {
                                returnValue = 1;
                            }
                            break;
                        }
                    }
                }
            }
        } else {
            // For others iPhone
            NSArray *children = [[_statusBar valueForKeyPath:@"foregroundView"] subviews];
            int type = -1;
            for (id child in children) {
                if ([child isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
                    type = [[child valueForKeyPath:@"dataNetworkType"] intValue];
                }
            }
            switch (type) {
                case 0:
                    returnValue = -1;
                    break;
                case 1:
                    returnValue = 2;
                    break;
                case 2:
                    returnValue = 3;
                    break;
                case 3:
                    returnValue = 4;
                    break;
                case 4:
                    returnValue = 1;
                    break;
                case 5:
                    returnValue = 0;
                    break;
                default:
                    break;
            }
        }
    }

    return returnValue;
}

@end
