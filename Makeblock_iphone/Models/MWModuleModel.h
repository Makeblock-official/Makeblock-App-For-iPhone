//
//  MWModuleModel.h
//  Makeblock HD
//
//  Created by 虎子哥 on 14-3-27.
//  Copyright (c) 2014年 Makerworks. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface MWModuleModel : NSManagedObject
@property(nonatomic,retain)NSDate*createTime;
@property(nonatomic,retain)NSDate*updateTime;
@property(nonatomic,retain)NSString*name;
@property(nonatomic,retain)NSString*protocol;
@property(nonatomic,retain)NSNumber*mid;
@property(nonatomic,retain)NSNumber*pid;
@property(nonatomic,retain)NSNumber*pin;
@property(nonatomic,retain)NSNumber*port;
@property(nonatomic,retain)NSNumber*xPosition;
@property(nonatomic,retain)NSNumber*yPosition;
@property(nonatomic,retain)NSNumber*type;
@property(nonatomic,retain)NSNumber*slot;
@property(nonatomic,retain)NSNumber*index;
@property(nonatomic,retain)NSNumber*xib;
@property(nonatomic,retain)NSNumber*menu;
@property(nonatomic,retain)NSString*thumb;
@property(nonatomic,retain)NSNumber*displayMode;
@property(nonatomic,retain)NSNumber*minValue;
@property(nonatomic,retain)NSNumber*maxValue;
@property(nonatomic,retain)NSNumber*autoReset;

@end
