//
//  GetRefreshTokenFunctionProtocal.h
//  impcloud_dev
//
//  Created by 许阳 on 2019/4/19.
//  Copyright © 2019 Elliot. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 此接口作用；
 放到POD管理
 引入此GetRefreshTokenFunctionProtocal之后调用接口方法，启动服务时，进行处理
 */

@protocol GetRefreshTokenFunctionProtocal <NSObject>

//刷新Token 函数
- (void)updateAuthTokenComplete:(NSMutableURLRequest *_Nullable)requestStr freshToken:(void (^_Null_unspecified)(BOOL success, BOOL needLogout))completion;

@end

