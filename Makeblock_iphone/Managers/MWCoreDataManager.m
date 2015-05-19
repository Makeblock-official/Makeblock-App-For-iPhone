//
//  MWCoreDataManager.m
//  Makeblock HD
//
//  Created by 虎子哥 on 14-3-27.
//  Copyright (c) 2014年 Makerworks. All rights reserved.
//

#import "MWCoreDataManager.h"
#import "MWUserModel.h"
#import "MWProjectModel.h"
#import "MWModuleModel.h"
#import "MWLayoutModel.h"
#import "MWUserManager.h"
@implementation MWCoreDataManager
static MWCoreDataManager *_instance;
+(MWCoreDataManager*)sharedManager{
    if(_instance==nil){
        _instance = [[MWCoreDataManager alloc]init];
    }
    return _instance;
}
-(NSArray*)models:(NSString*)name{
    return [self models:name withPredicate:nil withKey:@"updateTime"];
}
-(NSArray*)models:(NSString*)name withKey:(NSString *)key{
    return [self models:name withPredicate:nil withKey:key];
}
-(NSArray*)models:(NSString*)name withPredicate:(NSString*)predicate{
    return [self models:name withPredicate:predicate withKey:@"updateTime"];
}
-(NSArray*)models:(NSString*)name withPredicate:(NSString*)predicate withKey:(NSString*)key{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:name];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:NO];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	[fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat:predicate]];
    NSError *error;
    return [_context executeFetchRequest:fetchRequest error:&error];
}
-(NSArray*)allUsers{
    return [self models:@"MWUser"];
}
-(NSArray*)allProjects{
    return [self models:@"MWProject"];
}
-(NSArray*)allModules{
    return [self models:@"MWModule"];
}
-(NSArray*)allLayouts{
    return [self models:@"MWLayout"];
}
-(NSArray*)modulesInProject:(NSInteger)pid{
    return [self models:@"MWModule" withPredicate:[NSString stringWithFormat:@"pid=%ld",(long)pid]];
}
-(void)addUser{
    MWUserModel *model = [NSEntityDescription insertNewObjectForEntityForName:@"MWUser" inManagedObjectContext:_context];
    model.createTime = [NSDate date];
    model.updateTime = [NSDate date];
    NSArray *users = [self models:@"MWUser" withKey:@"uid"];
    if(users.count>0){
        MWUserModel *lastUser = [users objectAtIndex:0];
        model.uid = [NSNumber numberWithInteger:lastUser.uid.integerValue+1];
    }else{
        model.uid = [NSNumber numberWithInteger:1];
    }
    model.name = [UIDevice currentDevice].name;
    model.device = [UIDevice currentDevice].systemVersion;
    [self save];
}

-(MWProjectModel*)addProject:(NSString*)name withTag:(NSString*)tag withType:(NSInteger)type{
    MWProjectModel *model = [NSEntityDescription insertNewObjectForEntityForName:@"MWProject" inManagedObjectContext:_context];
    model.createTime = [NSDate date];
    model.updateTime = [NSDate date];
    model.uid = [NSNumber numberWithInteger:[MWUserManager sharedManager].userId];
    NSArray *projects = [self models:@"MWProject" withKey:@"pid"];
    if(projects.count>0){
        MWProjectModel *lastProject = [projects objectAtIndex:0];
        model.pid = [NSNumber numberWithInteger:lastProject.pid.integerValue+1];
    }else{
        model.pid = [NSNumber numberWithInteger:1];
    }
    model.name = name;
    model.imageUrl = @"";
    model.imageLocal = @"";
    model.type = [NSNumber numberWithInteger:type];
    model.tag = tag;
    [self save];
    return model;
}

-(void)addModule:(NSInteger)pid withName:(NSString*)name withProtocol:(NSString*)protocol withType:(NSInteger)type{
    [self addModule:pid withName:name withProtocol:protocol withType:type withPort:0 withSlot:0 withThumb:nil withXib:1 withMenu:0];
}

-(MWModuleModel*)addModule:(NSInteger)pid withName:(NSString*)name withProtocol:(NSString*)protocol withType:(NSInteger)type withPort:(NSInteger)port withSlot:(NSInteger)slot withThumb:(NSString*)thumb withXib:(NSInteger)xib withMenu:(NSInteger)menu{
    MWModuleModel *model = [NSEntityDescription insertNewObjectForEntityForName:@"MWModule" inManagedObjectContext:_context];
    model.createTime = [NSDate date];
    model.updateTime = [NSDate date];
    model.pid = [NSNumber numberWithInteger:pid];
    NSArray *modules = [self models:@"MWModule" withKey:@"mid"];
    if(modules.count>0){
        MWModuleModel *lastModule = [modules objectAtIndex:0];
        model.mid = [NSNumber numberWithInteger:lastModule.mid.integerValue+1];
    }else{
        model.mid = [NSNumber numberWithInteger:1];
    }
    model.xib = [NSNumber numberWithInteger:xib];
    model.thumb = thumb;
    model.name = name;
    model.pin = [NSNumber numberWithInteger:0];
    model.port = [NSNumber numberWithInteger:port];
    model.slot = [NSNumber numberWithInteger:slot];
    model.protocol = protocol;
    model.xPosition = [NSNumber numberWithInteger:200];
    model.yPosition = [NSNumber numberWithInteger:200];
    model.type = [NSNumber numberWithInteger:type];
    model.menu = [NSNumber numberWithInteger:menu];
    model.maxValue = [NSNumber numberWithInt:255];
    model.minValue = [NSNumber numberWithInt:-255];
    [self save];
    return model;
}
-(void)addLayout:(NSInteger)mid withType:(NSInteger)type{
    MWLayoutModel *model = [NSEntityDescription insertNewObjectForEntityForName:@"MWLayout" inManagedObjectContext:_context];
    model.createTime = [NSDate date];
    model.updateTime = [NSDate date];
    model.mid = [NSNumber numberWithInteger:mid];
    NSArray *layouts = [self models:@"MWLayout" withKey:@"lid"];
    if(layouts.count>0){
        MWLayoutModel *lastLayout = [layouts objectAtIndex:0];
        model.lid = [NSNumber numberWithInteger:lastLayout.lid.integerValue+1];
    }else{
        model.lid = [NSNumber numberWithInteger:1];
    }
    model.type = [NSNumber numberWithInteger:type];
    model.value = [NSNumber numberWithDouble:1.0];
    [self save];
}
-(void)save{
    [_context save:nil];
}

-(void)remove:(NSManagedObject*)object{
    [_context deleteObject:object];
}
-(void)removeProject:(MWProjectModel*)project{
    NSArray *modules = [self modulesInProject:project.pid.integerValue];
    for(int i=0;i<modules.count;i++){
        [self remove:[modules objectAtIndex:i]];
    }
    [self remove:project];
}
@end
