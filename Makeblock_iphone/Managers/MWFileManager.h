//
//  MWFileManager.h
//  Makeblock_iphone
//
//  Created by 虎子哥 on 15/2/26.
//  Copyright (c) 2015年 Makeblock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWFileDelegate.h"

@interface MWFileManager : NSObject<NSURLConnectionDataDelegate,NSURLConnectionDelegate,NSXMLParserDelegate>
@property(nonatomic,strong)NSMutableData *data;
@property(nonatomic,assign)id<MWFileDelegate> delegate;
+(MWFileManager *)sharedManager;
-(void)start:(NSString*)path delegate:(id<MWFileDelegate>)delegate;
@end
