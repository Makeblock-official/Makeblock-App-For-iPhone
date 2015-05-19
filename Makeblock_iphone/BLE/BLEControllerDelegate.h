//
//  BLEControllerDelegate.h
//  BLEManager
//
//  Created by 虎子哥 on 13-10-30.
//  Copyright (c) 2013年 虎子哥. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BLEControllerDelegate<NSObject>

@optional

-(void)bleStateChanged;
-(void)bleConnected;
-(void)bleDisconnected;
-(void)bleReceivedData:(NSData*)data;
@end
