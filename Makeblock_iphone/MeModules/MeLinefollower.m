//
//  MeLinefollower.m
//  Makeblock_Iphone
//
//  Created by Riven on 14-9-5.
//  Copyright (c) 2014年 Makeblock. All rights reserved.
//

#import "MeLinefollower.h"

@implementation MeLinefollower
@synthesize leftButton,rightButton;

-(void)setEnable:(BOOL)enable
{
    [leftButton setEnabled:enable];
    [rightButton setEnabled:enable];
    leftButton.highlighted = YES;
    rightButton.highlighted = YES;
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
    int io = (int)value;
    leftButton.highlighted = !(io&0x1);
    rightButton.highlighted = !((io&0x2)>>1);
}


@end
