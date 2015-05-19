//
//  MeDcmotor.m
//  Makeblock_Iphone
//
//  Created by Riven on 14-9-5.
//  Copyright (c) 2014年 Makeblock. All rights reserved.
//

#import "MeDcmotor.h"

@implementation MeDcmotor
@synthesize speedSlide;
UILabel *popView;
NSTimer *timer;

-(void)didMoveToSuperview{
    popView = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, 70, 20)];
    [popView setTextAlignment:NSTextAlignmentCenter];
    [popView setBackgroundColor:[UIColor clearColor]];
    [popView setAlpha:0.f];
    [self.superview addSubview:popView];
}

-(void)setEnable:(BOOL)enable
{
    [speedSlide setEnabled:enable];
    [super setEnable:enable];
}

- (IBAction)slideValueChanged:(id)sender {
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    // 10ms fraction delay
    if((time-lastTouchTime)>0.01f){
        int type = [self.model.type intValue];
        int port = [self.model.port intValue];
        int slot = [self.model.slot intValue];
        float value = [speedSlide value];
        [self showPosView:value+250 value:value];
        NSData * cmd = [MeModule buildModuleWriteShort:type port:port slot:slot value:value];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"module_value" object:nil userInfo:@{@"cmd":cmd}];
    }
    lastTouchTime = time;
}

- (IBAction)slideReset:(id)sender {
    [speedSlide setValue:0.0f];
    int type = [self.model.type intValue];
    int port = [self.model.port intValue];
    int slot = [self.model.slot intValue];
    float value = [speedSlide value];
    [self showPosView:value+250 value:value];
    NSData * cmd = [MeModule buildModuleWriteShort:type port:port slot:slot value:value];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"module_value" object:nil userInfo:@{@"cmd":cmd}];
}

-(void)showPosView:(int)pos value:(int)v
{
    CGRect theRect = [self frame];
    //int x = theRect.origin.x+slider.frame.origin.x+v*slider.frame.size.width/(slider.maximumValue-slider.minimumValue);
    int x = theRect.origin.x+127+pos*0.22656;//127~243
    
    [popView setFrame:CGRectMake(x, theRect.origin.y-20.0, popView.frame.size.width, popView.frame.size.height)];
    [popView setText:[NSString stringWithFormat:@"%d",v]];
    [popView setTextColor:[UIColor colorWithRed:0.1 green:0.4 blue:0.9 alpha:1.0]];
    [UIView animateWithDuration:0.3
                     animations:^{
                         [popView setAlpha:1.f];
                     }
                     completion:^(BOOL finished){
                         // 动画结束时的处理
                     }];
    
    [timer invalidate];
    timer = nil;
    timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                             target:self
                                           selector:@selector(disPopView)
                                           userInfo:nil repeats:NO];
}

- (void)disPopView{
    [UIView animateWithDuration:0.5
                     animations:^{
                         [popView setAlpha:0.f];
                     }
                     completion:^(BOOL finished){
                         // 动画结束时的处理
                     }];
}


-(void)cancel{
    [super cancel];
    
    int type = [self.model.type intValue];
    int port = [self.model.port intValue];
    int slot = [self.model.slot intValue];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        float value = 0;
        NSData * cmd = [MeModule buildModuleWriteShort:type port:port slot:slot value:value];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"module_value" object:nil userInfo:@{@"cmd":cmd}];
        
    });


}


@end
