//
//  AppDelegate.h
//  Makeblock_Iphone
//
//  Created by Riven on 14-9-1.
//  Copyright (c) 2014年 Makeblock. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UMENG_APPKEY @"5413c628fd98c50a910502ef"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
