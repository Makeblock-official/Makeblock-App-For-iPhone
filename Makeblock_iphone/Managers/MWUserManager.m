//
//  MWUserManager.m
//  Makeblock HD
//
//  Created by 虎子哥 on 14-3-28.
//  Copyright (c) 2014年 Makerworks. All rights reserved.
//

#import "MWUserManager.h"
#import "MWCoreDataManager.h"
#import "MWUserModel.h"
@implementation MWUserManager
static MWUserManager*_instance;
+(MWUserManager*)sharedManager{
    if(_instance==nil){
        _instance = [[MWUserManager alloc]init];
    }
    return _instance;
}
-(void)generalUser{
    NSArray *users = [[MWCoreDataManager sharedManager]allUsers];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userCreated:) name:NSManagedObjectContextDidSaveNotification object:nil];
    if(users.count==0){
        [[MWCoreDataManager sharedManager]addUser];
    }else{
        [self userCreated:nil];
    }
}

-(void)userCreated:(NSNotification*)notification{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
    
    NSArray *users = [[MWCoreDataManager sharedManager]allUsers];
    [MWUserManager sharedManager].userId = [[(MWUserModel*)[users objectAtIndex:0] uid]integerValue];
}

@end