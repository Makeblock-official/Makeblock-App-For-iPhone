//
//  MWProjectModel.h
//  Makeblock HD
//
//  Created by 虎子哥 on 14-3-27.
//  Copyright (c) 2014年 Makerworks. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface MWProjectModel : NSManagedObject
@property(nonatomic,retain)NSDate*createTime;
@property(nonatomic,retain)NSDate*updateTime;
@property(nonatomic,retain)NSString*imageLocal;
@property(nonatomic,retain)NSString*imageUrl;
@property(nonatomic,retain)NSString*name;
@property(nonatomic,retain)NSNumber*pid;
@property(nonatomic,retain)NSNumber*uid;
@property(nonatomic,retain)NSNumber*type;
@property(nonatomic,retain)NSString*tag;
@end
