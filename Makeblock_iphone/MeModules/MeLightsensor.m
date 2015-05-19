//
//  MeLightsensor.m
//  Makeblock_Iphone
//
//  Created by Riven on 14-9-5.
//  Copyright (c) 2014年 Makeblock. All rights reserved.
//

#import "MeLightsensor.h"

@implementation MeLightsensor
@synthesize ledSwitch;

-(void)setEnable:(BOOL)enable
{
    [ledSwitch setEnabled:enable];
    [super setEnable:enable];
}

-(NSData*)getQuery:(int)index
{
    int type = [self.model.type intValue];
    int port = [self.model.port intValue];
    int slot = [self.model.slot intValue];
    NSData * data = [MeModule buildModuleRead:type port:port slot:slot index:index];
    return data;
}

-(void)updateModuleValue:(float)value
{
    NSString * str = [NSString stringWithFormat:@"%.1f",value*0.976];
    [self.valueLabel setText:str];
}

- (IBAction)ledOnOff:(id)sender {
    int type = [self.model.type intValue];
    int port = [self.model.port intValue];
    int slot = [self.model.slot intValue];
    float value = [ledSwitch isOn]?1.0:0.0;
    NSData * cmd = [MeModule buildModuleWrite:type port:port slot:slot value:value];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"module_value" object:nil userInfo:@{@"cmd":cmd}];
}
@end
