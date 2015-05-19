//
//  MeModule.m
//  Makeblock_Iphone
//
//  Created by Riven on 14-9-3.
//  Copyright (c) 2014年 Makeblock. All rights reserved.
//

#import "MeModule.h"
#import "MWModuleModel.h"
#import "MWCoreDataManager.h"
@implementation MeModule
@synthesize moduleView,xPosition,yPosition,modDict,isEnable,shouldSelectSlot;
@synthesize dragGesture,tapGesture;

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        dragGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(dragHandle:)];
        [self addGestureRecognizer:dragGesture];
        tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHandle:)];
        [self addGestureRecognizer:tapGesture];
        isEnable = NO;
        shouldSelectSlot = NO;
    }
    return self;
}

-(void)dragHandle:(UIPanGestureRecognizer*)gesture{
    [self.superview bringSubviewToFront:self];
    CGPoint translation = [gesture translationInView:self];
    gesture.view.center = CGPointMake(gesture.view.center.x + translation.x,
                                      gesture.view.center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:self];
    if(gesture.state == UIGestureRecognizerStateEnded)
    {
        self.model.xPosition = [NSNumber numberWithFloat:gesture.view.center.x];
        self.model.yPosition = [NSNumber numberWithFloat:gesture.view.center.y];
        dLog(@"%f,%f",gesture.view.center.x,gesture.view.center.y);
        
        [[MWCoreDataManager sharedManager] save];
        //[[NSNotificationCenter defaultCenter]postNotificationName:@"updateposition" object:nil userInfo:modDict];
    }

}

-(void)tapHandle:(UITapGestureRecognizer*)gesture{
    
    CGPoint position = [gesture locationInView:self];
    position.x += self.frame.origin.x;
    position.y += self.frame.origin.y;
    if(isEnable==NO){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"module_taged" object:nil userInfo:@{@"module":self}];
    }
}
-(void)removeFromProject{
    [[MWCoreDataManager sharedManager]remove:self.model];
}
-(NSData*)getQuery:(int)index
{
    return nil;
}
-(void)cancel{
    
}
-(void)updateModuleValue:(float)value
{
    return;
}



-(void)setEnable:(BOOL)enable
{
    if(enable==YES){
        [dragGesture setEnabled:NO];
        [tapGesture setEnabled:NO];
    }else{
        [dragGesture setEnabled:YES];
        [tapGesture setEnabled:YES];
    }
    
    isEnable = enable;
}

-(void)updatePosition:(float)x y:(float)y
{
    self.xPosition = x;
    self.yPosition = y;
    self.center = CGPointMake(self.xPosition, self.yPosition);
}

-(void)setModel:(MWModuleModel*)mod
{
    _model = mod;
}


+(NSString*)getModuleString:(int)dev
{
    switch (dev) {
        case DEV_DCMOTOR:
            return @"Dc Motor";
            break;
        case DEV_SERVO:
            return @"Servo";
            break;
        case DEV_JOYSTICK:
            return @"Joystick";
            break;
        case DEV_RGBLED:
            return @"RGB Led";
            break;
        case DEV_SEVSEG:
            return @"7-Segment";
            break;
        case DEV_ULTRASOINIC:
            return @"Ultrasonic";
            break;
        case DEV_TEMPERATURE:
            return @"Temperature";
            break;
        case DEV_LIGHTSENSOR:
            return @"Light Sensor";
            break;
        case DEV_SOUNDSENSOR:
            return @"Sound Sensor";
            break;
        case DEV_LINEFOLLOWER:
            return @"Line Follower";
            break;
        case DEV_POTENTIALMETER:
            return @"Potential Meter";
            break;
        case DEV_LIMITSWITCH:
            return @"Limit Switch";
            break;
        case DEV_BUTTON:
            return @"Button";
            break;
        case DEV_PIRMOTION:
            return @"PIR Sensor";
            break;
        default:
            return @"NULL";
            break;
    }

}

+(NSString*)getModuleImageString:(int)dev
{
    switch (dev) {
        case DEV_DCMOTOR:
            return @"motor.png";
            break;
        case DEV_SERVO:
            return @"servo.png";
            break;
        case DEV_JOYSTICK:
            return @"joystick_icon.png";
            break;
        case DEV_RGBLED:
            return @"rgbled.png";
            break;
        case DEV_SEVSEG:
            return @"sevseg.png";
            break;
        case DEV_ULTRASOINIC:
            return @"ultrasonic.png";
            break;
        case DEV_TEMPERATURE:
            return @"temperature.png";
            break;
        case DEV_LIGHTSENSOR:
            return @"lightsensor.png";
            break;
        case DEV_SOUNDSENSOR:
            return @"soundsensor.png";
            break;
        case DEV_LINEFOLLOWER:
            return @"linefinder.png";
            break;
        case DEV_POTENTIALMETER:
            return @"potentiometer.png";
            break;
        case DEV_LIMITSWITCH:
            return @"limitswitch.png";
            break;
        case DEV_BUTTON:
            return @"button.png";
            break;
        case DEV_PIRMOTION:
            return @"pirmotion.png";
            break;
        default:
            return nil;
            break;
    }
}

+(NSMutableDictionary*)buildModule:(int)type port:(int)port slot:(int)slot x:(float)x y:(float)y
{
    NSMutableDictionary * mod = [[NSMutableDictionary alloc] initWithCapacity:6];
    [mod setObject:[self getModuleString:type] forKey:@"name"];
    [mod setObject:[[NSNumber alloc] initWithInt:port] forKey:@"port"];
    [mod setObject:[[NSNumber alloc] initWithInt:slot] forKey:@"slot"];
    [mod setObject:[[NSNumber alloc] initWithFloat:x] forKey:@"xPosition"];
    [mod setObject:[[NSNumber alloc] initWithFloat:y] forKey:@"yPosition"];
    [mod setObject:[[NSNumber alloc] initWithInt:type] forKey:@"type"];
    
    return mod;
}

union{
    unsigned char c[4];
    float f;
    uint32_t i;
}uf;
union{
    unsigned char c[2];
    short s;
}ucs;
+(NSData*)buildModuleWrite:(int)type port:(int)port slot:(int)slot value:(float)value
{
    unsigned char a[13]={0xff,0x55,0,0,0,0,0,0,0,0,0,0,'\n'};
    a[2] = 0x9;
    a[3] = 0;
    a[4] = WRITEMODULE;
    a[5] = type;
    a[6] = port;
    a[7] = slot;
    uf.f = value;
    memcpy(a+8, uf.c, 4);
    NSData * data = [NSData dataWithBytes:a length:13];
    return data;
}
+(NSData*)buildModuleWriteShort:(int)type port:(int)port slot:(int)slot value:(short)value
{
    unsigned char a[10]={0xff,0x55,0,0,0,0,0,0,0,'\n'};
    a[2] = 0x6;
    a[3] = 0;
    a[4] = WRITEMODULE;
    a[5] = type;
    a[6] = port;
    a[7] = value&0xff;
    a[8] = (value>>8)&0xff;
    
    NSData * data = [NSData dataWithBytes:a length:10];
    return data;
}
+(NSData*)buildModuleWriteRGB:(int)type port:(int)port slot:(int)slot index:(int)index r:(int)r g:(int)g b:(int)b
{
    unsigned char a[12]={0xff,0x55,0,0,0,0,0,0,0,0,0,'\n'};
    a[2] = 0x8;
    a[3] = 0;
    a[4] = WRITEMODULE;
    a[5] = type;
    a[6] = port;
    a[7] = index;
    a[8] = r;
    a[9] = g;
    a[10] = b;
    NSData * data = [NSData dataWithBytes:a length:12];
    
    return data;
}
+(NSData*)buildModuleRead:(int)type port:(int)port slot:(int)slot index:(int)index
{
    unsigned char a[9]={0xff,0x55,0,0,0,0,0,0,'\n'};
    a[2] = 0x5;
    a[3] = index;
    a[4] = READMODULE;
    a[5] = type;
    a[6] = port;
    a[7] = slot;
    NSData * data = [NSData dataWithBytes:a length:9];

    return data;
}



@end
