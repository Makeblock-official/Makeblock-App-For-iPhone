//
//  MeButton.m
//  Makeblock_Iphone
//
//  Created by Riven on 14-9-5.
//  Copyright (c) 2014年 Makeblock. All rights reserved.
//

#import "MeButton.h"

@implementation MeButton
@synthesize valueLabel;

-(NSData*)getQuery:(int)index
{
    // todo: no button follower at firmware
    int type = [self.model.type intValue];
    int port = [self.model.port intValue];
    int slot = [self.model.slot intValue];
    NSData * data = [MeModule buildModuleRead:type port:port slot:slot index:index];
    return data;
}

-(void)updateModuleValue:(float)value
{
    int adc = (int)value;
    if(adc<=5){
        [self.valueLabel setText:@"KEY1"];
    }else if(adc<=490){
        [self.valueLabel setText:@"KEY2"];
    }else if(adc<=653){
        [self.valueLabel setText:@"KEY3"];
    }else if(adc<=734){
        [self.valueLabel setText:@"KEY4"];
    }else{
        [self.valueLabel setText:@"None"];
    }

}
@end
