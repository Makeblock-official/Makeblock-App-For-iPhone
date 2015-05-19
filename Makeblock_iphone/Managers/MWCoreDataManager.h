//
//  MWCoreDataManager.h
//  Makeblock HD
//
//  Created by 虎子哥 on 14-3-27.
//  Copyright (c) 2014年 Makerworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWModuleModel.h"
@class MWProjectModel;
@interface MWCoreDataManager : NSObject
@property(nonatomic,assign)NSManagedObjectContext*context;
+(MWCoreDataManager*)sharedManager;
-(void)addUser;
-(MWProjectModel*)addProject:(NSString*)name withTag:(NSString*)tag withType:(NSInteger)type;
-(void)addModule:(NSInteger)pid withName:(NSString*)name withProtocol:(NSString*)protocol withType:(NSInteger)type;
-(MWModuleModel*)addModule:(NSInteger)pid withName:(NSString*)name withProtocol:(NSString*)protocol withType:(NSInteger)type withPort:(NSInteger)port withSlot:(NSInteger)slot withThumb:(NSString*)thumb withXib:(NSInteger)xib withMenu:(NSInteger)menu;
-(void)addLayout:(NSInteger)mid withType:(NSInteger)type;
-(NSArray*)allUsers;
-(NSArray*)allProjects;
-(NSArray*)allModules;
-(NSArray*)allLayouts;
-(NSArray*)modulesInProject:(NSInteger)pid;

-(NSArray*)models:(NSString*)name;
-(NSArray*)models:(NSString*)name withKey:(NSString*)key;
-(NSArray*)models:(NSString*)name withPredicate:(NSString*)predicate;
-(NSArray*)models:(NSString*)name withPredicate:(NSString*)predicate withKey:(NSString*)key;
-(void)save;
-(void)remove:(NSManagedObject*)object;
-(void)removeProject:(MWProjectModel*)project;
@end
