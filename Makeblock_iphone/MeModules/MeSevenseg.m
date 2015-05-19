//
//  MeSevenseg.m
//  Makeblock_Iphone
//
//  Created by Riven on 14-9-5.
//  Copyright (c) 2014年 Makeblock. All rights reserved.
//

#import "MeSevenseg.h"

@implementation MeSevenseg
@synthesize numberTxt,timeSyncButton;

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        //numberTxt.delegate = self;
    }
    return self;
}

-(void)setEnable:(BOOL)enable
{
    [numberTxt setEnabled:enable];
    [timeSyncButton setEnabled:enable];
    if(enable){
        tap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(dismissKeyboard)];
        
        [self.superview addGestureRecognizer:tap];
    }else{
        [self.superview removeGestureRecognizer:tap];
        [self.timer invalidate];
    }
    
    [super setEnable:enable];
}

-(void)dismissKeyboard {
    [self endEditing:YES];
}

- (IBAction)digitOnChanged:(id)sender {
    NSString * numstr = [numberTxt text];
    float value = [numstr floatValue];
    int type = [self.model.type intValue];
    int port = [self.model.port intValue];
    int slot = [self.model.slot intValue];
    NSData * cmd = [MeModule buildModuleWrite:type port:port slot:slot value:value];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"module_value" object:nil userInfo:@{@"cmd":cmd}];
}

- (IBAction)timeSync:(id)sender {
    BOOL enTimer = [timeSyncButton isOn];
    if(enTimer){
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerHandle:) userInfo:nil repeats:YES];
    }else{
        [self.timer invalidate];
    }
}

-(void)timerHandle:(id)sender{
    NSCalendar * cal=[NSCalendar currentCalendar];
    NSUInteger unitFlags=NSMinuteCalendarUnit|NSHourCalendarUnit|NSSecondCalendarUnit;
    NSDate * senddate=[NSDate date];
    NSDateComponents * comp= [cal components:unitFlags fromDate:senddate];
    [numberTxt setText:[NSString stringWithFormat:@"%.2f",comp.hour+comp.minute/100.0]];
    float value = comp.hour+comp.minute/100.0;
    int type = [self.model.type intValue];
    int port = [self.model.port intValue];
    int slot = [self.model.slot intValue];
    NSData * cmd = [MeModule buildModuleWrite:type port:port slot:slot value:value];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"module_value" object:nil userInfo:@{@"cmd":cmd}];
}

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    if([textField.text rangeOfString:@"."].location!=NSNotFound){
        return newLength <= 5;
    }else{
        return newLength <= 4;
    }
}
@end
