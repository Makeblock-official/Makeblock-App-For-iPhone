//
//  MeModule.h
//  Makeblock_Iphone
//
//  Created by Riven on 14-9-3.
//  Copyright (c) 2014年 Makeblock. All rights reserved.
//

#import <UIKit/UIKit.h>

// should be same to ios code
#define DEV_VERSION 0
#define DEV_ULTRASOINIC 1
#define DEV_TEMPERATURE 2
#define DEV_LIGHTSENSOR 3
#define DEV_POTENTIALMETER 4
#define DEV_GYRO 6
#define DEV_SOUNDSENSOR 7
#define DEV_RGBLED 8
#define DEV_SEVSEG 9
#define DEV_DCMOTOR 10
#define DEV_SERVO 11
#define DEV_ENCODER 12
#define DEV_JOYSTICK 13
#define DEV_PIRMOTION 15
#define DEV_INFRADRED 16
#define DEV_LINEFOLLOWER 17
#define DEV_BUTTON 18
#define DEV_LIMITSWITCH 19
#define DEV_PINDIGITAL 30
#define DEV_PINANALOG 31
#define DEV_PINPWM 32
#define DEV_PINANGLE 33

#define VIEW_DCMOTOR 1
#define VIEW_SERVO 2
#define VIEW_ULTRASONIC 3
#define VIEW_TEMPERATURE 4
#define VIEW_LIGHTSENSOR 5
#define VIEW_SOUNDSENSOR 6
#define VIEW_RGBLED 7
#define VIEW_LINEFOLLOWER 8
#define VIEW_BUTTON 9
#define VIEW_PIRMOTION 10
#define VIEW_LIMITSWITCH 11
#define VIEW_POTENTIALMETER 12
#define VIEW_JOYSTICK 13
#define VIEW_SEVSEG 14

#define SLOT_1 1 //0
#define SLOT_2 2 //1

#define READMODULE 1
#define WRITEMODULE 2

#define VERSION_INDEX 0xFA

#define PORT_NULL 0
#define PORT_1 1
#define PORT_2 2
#define PORT_3 3
#define PORT_4 4
#define PORT_5 5
#define PORT_6 6
#define PORT_7 7
#define PORT_8 8
#define PORT_M1 9
#define PORT_M2 10

#define MSG_VALUECHANGED 0x10
#import "MWModuleModel.h"
@interface MeModule : UIView <UIGestureRecognizerDelegate>
//@property int type;
//@property int port;
//@property int slot;
@property BOOL isEnable;
@property BOOL shouldSelectSlot;
@property NSMutableDictionary * modDict;
@property CGFloat xPosition,yPosition;
@property UIView * moduleView;
@property(nonatomic,strong) UIPanGestureRecognizer * dragGesture;
@property(nonatomic,strong) UITapGestureRecognizer * tapGesture;
@property(nonatomic,weak) MWModuleModel * model;

@property(nonatomic,weak)IBOutlet UIImageView *imageView;
@property(nonatomic,weak)IBOutlet UILabel *titleLabel;
@property(nonatomic,weak)IBOutlet UILabel *portLabel;

-(void)updatePosition:(float)x y:(float)y;
-(void)setModel:(MWModuleModel*)mod;
-(void)setEnable:(BOOL)enable;
-(void)cancel;
-(NSData*)getQuery:(int)index;
-(void)updateModuleValue:(float)value;
-(void)removeFromProject;
+(NSString*)getModuleString:(int)dev;
+(NSString*)getModuleImageString:(int)dev;
+(NSMutableDictionary*)buildModule:(int)type port:(int)port slot:(int)slot x:(float)x y:(float)y;
+(NSData*)buildModuleWrite:(int)type port:(int)port slot:(int)slot value:(float)value;
//+(NSData*)buildModuleWriteInt:(int)type port:(int)port slot:(int)slot value:(uint32_t)value;
+(NSData*)buildModuleWriteShort:(int)type port:(int)port slot:(int)slot value:(short)value;
+(NSData*)buildModuleRead:(int)type port:(int)port slot:(int)slot index:(int)index;
+(NSData*)buildModuleWriteRGB:(int)type port:(int)port slot:(int)slot index:(int)index r:(int)r g:(int)g b:(int)b;
@end
