//
//  MeDcmotor.h
//  Makeblock_Iphone
//
//  Created by Riven on 14-9-5.
//  Copyright (c) 2014年 Makeblock. All rights reserved.
//

#import "MeModule.h"

@interface MeDcmotor : MeModule
{
    NSTimeInterval lastTouchTime;
}
@property (weak, nonatomic) IBOutlet UISlider *speedSlide;
- (IBAction)slideValueChanged:(id)sender;
- (IBAction)slideReset:(id)sender;

@end
