//
//  MWUserManager.h
//  Makeblock HD
//
//  Created by 虎子哥 on 14-3-28.
//  Copyright (c) 2014年 Makerworks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MWUserManager : NSObject
@property(nonatomic,assign)NSInteger userId;
@property(nonatomic,assign)BOOL isUpdating;
+(MWUserManager*)sharedManager;
-(void)generalUser;
@end
