//
//  MWLayoutModel.h
//  Makeblock HD
//
//  Created by 虎子哥 on 14-3-27.
//  Copyright (c) 2014年 Makerworks. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface MWLayoutModel : NSManagedObject
@property(nonatomic,retain)NSDate *createTime;
@property(nonatomic,retain)NSDate *updateTime;
@property(nonatomic,retain)NSNumber *lid;
@property(nonatomic,retain)NSNumber *mid;
@property(nonatomic,retain)NSNumber *type;
@property(nonatomic,retain)NSNumber *value;
@end
