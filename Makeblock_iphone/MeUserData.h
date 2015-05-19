//
//  MeUserData.h
//  Makeblock_Iphone
//
//  Created by Riven on 14-9-1.
//  Copyright (c) 2014年 Makeblock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWProjectModel.h"
@interface MeUserData : NSObject
@property int selIndex;
-(NSArray*)getProjectList;
-(MWProjectModel*)getProject:(int)index;
-(NSMutableArray*)getDemoList;
-(NSMutableDictionary*)getDemoPorject:(int)index;
-(void)updateProj:(NSMutableDictionary*)proj index:(int)index;
-(void)newProject:(NSString*)projName;
-(NSString*)getLocalTime;
-(void)selIndex:(int)index;
+(MeUserData*)share;
@end
