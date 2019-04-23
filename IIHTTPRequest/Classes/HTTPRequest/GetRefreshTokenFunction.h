//
//  GetRefreshTokenFunction.h
//  impcloud_dev
//
//  Created by 许阳 on 2019/4/23.
//  Copyright © 2019 Elliot. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GetRefreshTokenFunction : NSObject

//Token刷新函数
+ (void)updateAuthTokenComplete:(NSMutableURLRequest *_Nullable)requestStr freshToken:(void (^_Null_unspecified)(BOOL success, BOOL needLogout))completion;

@end

NS_ASSUME_NONNULL_END
