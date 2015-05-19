//
//  MePirsensor.m
//  Makeblock_Iphone
//
//  Created by Riven on 14-9-5.
//  Copyright (c) 2014年 Makeblock. All rights reserved.
//

#import "MePirsensor.h"

@implementation MePirsensor
@synthesize onButton,offButton;

-(void)setEnable:(BOOL)enable
{
    [onButton setEnabled:enable];
    [offButton setEnabled:enable];
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
    if(!io){
        onButton.highlighted=YES;
        offButton.highlighted=NO;
    }else{
        onButton.highlighted=NO;
        offButton.highlighted=YES;
    }
}

@end
