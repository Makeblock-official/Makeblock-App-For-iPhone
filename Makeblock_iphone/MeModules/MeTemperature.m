//
//  MeTemperature.m
//  Makeblock_Iphone
//
//  Created by Riven on 14-9-5.
//  Copyright (c) 2014年 Makeblock. All rights reserved.
//

#import "MeTemperature.h"

@implementation MeTemperature
@synthesize shouldSelectSlot;

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        shouldSelectSlot = YES;
    }
    return self;
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
    NSString * str = [NSString stringWithFormat:@"%.1f ℃",value];
    [self.valueLabel setText:str];
}

@end
