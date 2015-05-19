//
//  MeUserData.m
//  Makeblock_Iphone
//
//  Created by Riven on 14-9-1.
//  Copyright (c) 2014年 Makeblock. All rights reserved.
//

#import "MeUserData.h"
#import "MeModules/MeModule.h"
#import "MWCoreDataManager.h"
@implementation MeUserData
static MeUserData*_instance;
+(MeUserData*)share{
    if(_instance==nil){
        _instance = [[MeUserData alloc]init];
        [_instance initialize];
    }
    return _instance;
}

-(void)selIndex:(int)index
{
    self.selIndex = index;
}

-(NSArray*)getProjectList;
{
    NSArray * projs = [[MWCoreDataManager sharedManager] allProjects];
    return projs;
}


-(MWProjectModel*)getProject:(int)index{
    return [[MWCoreDataManager sharedManager].allProjects objectAtIndex:index];
}

-(NSMutableArray*)getDemoList{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSMutableArray * projs = [userDefaultes mutableArrayValueForKey:@"demos"];
    return projs;
}

-(NSDictionary*)getDemoPorject:(int)index{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSMutableArray * projs = [userDefaultes mutableArrayValueForKey:@"demos"];
    NSMutableDictionary * proj = [projs objectAtIndex:index];
    return proj;
}

-(void)updateProj:(NSMutableDictionary*)proj index:(int)index
{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSMutableArray * projs = [userDefaultes mutableArrayValueForKey:@"projects"];
    [projs setObject:proj atIndexedSubscript:index];
}

-(void)newProject:(NSString*)projName{
    [[MWCoreDataManager sharedManager]addProject:projName withTag:@"" withType:1];
    
}
-(void)nullFunction{
//    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
//    NSMutableArray * projs = [userDefaultes mutableArrayValueForKey:@"projects"];
//    for(NSMutableDictionary * proj in projs){
//        if([projName isEqualToString:[proj objectForKey:@"name"]]){
//            r//eturn (int)[projs indexOfObject:proj];
//        }
//    }
//    NSMutableDictionary * newProj = [NSMutableDictionary dictionaryWithCapacity:5];
//    [newProj setObject:projName forKey:@"name"];
//    [newProj setObject:[self getLocalTime] forKey:@"createTime"];
//    [newProj setObject:[self getLocalTime] forKey:@"updateTime"];
//    NSMutableArray * moduleList = [[NSMutableArray alloc]initWithCapacity:5];
//    [newProj setObject:moduleList forKey:@"moduleList"];
//    [projs addObject:newProj];
    //[userDefaultes synchronize];
    //return (int)[projs indexOfObject:newProj];
}

-(NSString*)getLocalTime
{
    NSDate *date = [[NSDate alloc] init];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:timeZone];
    
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

-(void)initialize{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSMutableArray * projs = [userDefaultes mutableArrayValueForKey:@"projects"];
    if([projs count]==0){
        NSMutableDictionary * testPorj = [NSMutableDictionary dictionaryWithCapacity:5];
        [testPorj setObject:@"test project" forKey:@"name"];
        [testPorj setObject:[self getLocalTime] forKey:@"createTime"];
        [testPorj setObject:[self getLocalTime] forKey:@"updateTime"];
        NSMutableArray * moduleList = [[NSMutableArray alloc]initWithCapacity:5];
        NSMutableDictionary * testModule = [[NSMutableDictionary alloc] initWithCapacity:5];

        [testModule setObject:@"ultrasonic" forKey:@"name"];
        [testModule setObject:[[NSNumber alloc] initWithInt:PORT_3] forKey:@"port"];
        [testModule setObject:[[NSNumber alloc] initWithInt:SLOT_1] forKey:@"slot"];
        [testModule setObject:[[NSNumber alloc] initWithFloat:200.0] forKey:@"xPosition"];
        [testModule setObject:[[NSNumber alloc] initWithFloat:100.0] forKey:@"yPosition"];
        [testModule setObject:[[NSNumber alloc] initWithInt:DEV_ULTRASOINIC] forKey:@"type"];
        [moduleList addObject:testModule];
        [testPorj setObject:moduleList forKey:@"moduleList"];
        projs = [NSMutableArray arrayWithCapacity:5];
        [projs addObject:testPorj];
    }
    [userDefaultes setObject:projs forKey:@"projects"];
    [userDefaultes synchronize];
}



@end
