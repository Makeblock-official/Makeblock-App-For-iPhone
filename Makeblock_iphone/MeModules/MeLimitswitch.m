//
//  MeLimitswitch.m
//  Makeblock_Iphone
//
//  Created by Riven on 14-9-5.
//  Copyright (c) 2014年 Makeblock. All rights reserved.
//

#import "MeLimitswitch.h"

@implementation MeLimitswitch
@synthesize shouldSelectSlot,onButton,offButton;
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        shouldSelectSlot = YES;
    }
    return self;
}

-(void)setEnable:(BOOL)enable
{
    [onButton setEnabled:enable];
    [offButton setEnabled:enable];
    [super setEnable:enable];
    onButton.highlighted=NO;
    offButton.highlighted=YES;
}

-(NSData*)getQuery:(int)index
{
    // todo: no line follower at firmware
    int type = [self.model.type intValue];
    int port = [self.model.port intValue];
    int slot = [self.model.slot intValue];
    NSData * data = [MeModule buildModuleRead:type port:port slot:slot index:index];
    return data;
}

-(void)updateModuleValue:(float)value
{
    int io = (int)value;
    int slot = [self.model.slot intValue];
    if(slot==SLOT_1){
        io&=0x1;
    }else{
        io&=0x2;
    }
    
    if(!io){
        onButton.highlighted=YES;
        offButton.highlighted=NO;
    }else{
        onButton.highlighted=NO;
        offButton.highlighted=YES;
    }
}

@end
