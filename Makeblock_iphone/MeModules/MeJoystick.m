//
//  MeJoystick.m
//  Makeblock_Iphone
//
//  Created by Riven on 14-9-5.
//  Copyright (c) 2014年 Makeblock. All rights reserved.
//

#import "MeJoystick.h"

@implementation MeJoystick
@synthesize joystickBar;
float x,y;
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        barDrag = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(barHandle:)];
    }
    return self;
}

-(void)setEnable:(BOOL)enable
{
    if(enable){
        [joystickBar addGestureRecognizer:barDrag];
    }else{
        [joystickBar removeGestureRecognizer:barDrag];
    }
    [super setEnable:enable];
}

-(void)barHandle:(UIPanGestureRecognizer*)gesture{
    [self.superview bringSubviewToFront:self];
    if(gesture.state == UIGestureRecognizerStateBegan){
        x = 100.0;
        y = 100.0;
    }
    
    CGPoint translation = [gesture translationInView:self];
    CGPoint pos =CGPointMake(gesture.view.center.x + translation.x,
                             gesture.view.center.y + translation.y);
    // limit the bar position
    if(pos.x>x+150) pos.x = x+150;
    if(pos.x<x-150) pos.x = x-150;
    if(pos.y>y+150) pos.y = y+150;
    if(pos.y<y-150) pos.y = y-150;
    gesture.view.center = pos;
    [gesture setTranslation:CGPointZero inView:self];
    if(gesture.state == UIGestureRecognizerStateEnded)
    {
        gesture.view.center = CGPointMake(x,y);
        [self sendSpeedValue:x y:y];
    }else{
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
        // 10ms fraction delay
        if((time-lastTouchTime)>0.01f){
            [self sendSpeedValue:pos.x y:pos.y];
        }
        lastTouchTime = time;
    }
}
double lastTime;
-(void)sendSpeedValue:(float)posX y:(float)posY{
    float motor1,motor2;
    motor1 = -(posY-y)/150*255;
    motor2 = -(posY-y)/150*255;
    motor1+= (posX-x)/150*255;
    motor2-= (posX-x)/150*255;
    dLog(@"m1=%f m2=%f",motor1,motor2);
    double tt = [[NSDate date]timeIntervalSince1970];
    if(tt-lastTime>0.1||(motor1+motor2==0.0)){
        lastTime = tt;
    // send m1 speed
        NSData * cmd = [MeModule buildModuleWriteShort:DEV_DCMOTOR port:PORT_M1 slot:SLOT_1 value:motor1];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"module_value" object:nil userInfo:@{@"cmd":cmd}];
    // send m2 speed
        NSData * cmd2 = [MeModule buildModuleWriteShort:DEV_DCMOTOR port:PORT_M2 slot:SLOT_1 value:motor2];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"module_value" object:nil userInfo:@{@"cmd":cmd2}];
    }

}
-(void)cancel{
    [super cancel];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after
        // send m1 speed
        NSData * cmd = [MeModule buildModuleWriteShort:DEV_DCMOTOR port:PORT_M1 slot:SLOT_1 value:0];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"module_value" object:nil userInfo:@{@"cmd":cmd}];
        // send m2 speed
        NSData * cmd2 = [MeModule buildModuleWriteShort:DEV_DCMOTOR port:PORT_M2 slot:SLOT_1 value:0];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"module_value" object:nil userInfo:@{@"cmd":cmd2}];

    });
}

@end
