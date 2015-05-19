//
//  MWUserModel.h
//  Makeblock HD
//
//  Created by 虎子哥 on 14-3-27.
//  Copyright (c) 2014年 Makerworks. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface MWUserModel : NSManagedObject
@property(nonatomic,retain)NSDate*createTime;
@property(nonatomic,retain)NSDate*updateTime;
@property(nonatomic,retain)NSString*device;
@property(nonatomic,retain)NSString*name;
@property(nonatomic,retain)NSNumber*uid;
@end
