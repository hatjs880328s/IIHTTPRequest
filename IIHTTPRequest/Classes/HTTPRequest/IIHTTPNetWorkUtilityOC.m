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

@end
