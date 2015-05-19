//
//  MeJoystick.h
//  Makeblock_Iphone
//
//  Created by Riven on 14-9-5.
//  Copyright (c) 2014年 Makeblock. All rights reserved.
//

#import "MeModule.h"

@interface MeJoystick : MeModule
{
    UIPanGestureRecognizer * barDrag;
    NSTimeInterval lastTouchTime;
}
@property (weak, nonatomic) IBOutlet UIImageView *joystickBar;

@end
