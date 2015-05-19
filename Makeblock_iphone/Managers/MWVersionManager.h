//
//  MWVersionManager.h
//  Makeblock_iphone
//
//  Created by 虎子哥 on 15/2/26.
//  Copyright (c) 2015年 Makeblock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MWVersionManager : NSObject<NSURLConnectionDataDelegate,NSURLConnectionDelegate,NSXMLParserDelegate>
@property(nonatomic,strong)NSMutableData *data;
@property(nonatomic,strong)NSMutableArray *firmwares;
@property(nonatomic,copy)NSString *orionURL;
@property(nonatomic,copy)NSString *orionVer;
@property(nonatomic,assign)BOOL hasNewOrionVersion;
@property(nonatomic,assign)BOOL hasNewBotVersion;
+(MWVersionManager *)sharedManager;
-(void)start;
-(void)updateVersion:(NSString*)ver;
@end
