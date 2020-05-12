//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ** * * * *
//
// IIHTTPNetWorkUtility.h
//
// Created by    Noah Shan on 2018/10/29
// InspurEmail   shanwzh@inspur.com
//
// Copyright © 2018年 Inspur. All rights reserved.
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ** * * * *


#import <Foundation/Foundation.h>

@interface IIHTTPNetWorkUtilityOC : NSObject


- (NSArray *)getApplicationStatusBarVw;

/// 适配ios13.0
/// 0: wifi
/// 1: 1g或其他
/// 2: 2g
/// 3: 3g
/// 4: 4g
/// -1: have no
///
- (int)networkStateFromStatebar;

@end
