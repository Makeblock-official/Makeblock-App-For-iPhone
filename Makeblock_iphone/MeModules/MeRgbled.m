//
//  MeRgbled.m
//  Makeblock_Iphone
//
//  Created by Riven on 14-9-5.
//  Copyright (c) 2014年 Makeblock. All rights reserved.
//

#import "MeRgbled.h"

@implementation MeRgbled
@synthesize shouldSelectSlot,redSlide,greenSlide,blueSlide;
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        shouldSelectSlot = YES;
    }
    return self;
}

-(void)setEnable:(BOOL)enable
{
    [redSlide setEnabled:enable];
    [greenSlide setEnabled:enable];
    [blueSlide setEnabled:enable];

    [super setEnable:enable];
}


- (IBAction)rgbValueChanged:(id)sender {
    int red = (int)[redSlide value];
    int green = (int)[greenSlide value];
    int blue = (int)[blueSlide value];
    int type = [self.model.type intValue];
    int port = [self.model.port intValue];
    int slot = [self.model.slot intValue];
    NSLog(@"type:%d\r\r",type);
    NSData * cmd = [MeModule buildModuleWriteRGB:type port:port slot:slot index:0 r:red g:green b:blue];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"module_value" object:nil userInfo:@{@"cmd":cmd}];
}
@end
