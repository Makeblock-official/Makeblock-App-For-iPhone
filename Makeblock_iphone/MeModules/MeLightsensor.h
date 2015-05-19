//
//  MeLightsensor.h
//  Makeblock_Iphone
//
//  Created by Riven on 14-9-5.
//  Copyright (c) 2014年 Makeblock. All rights reserved.
//

#import "MeModule.h"

@interface MeLightsensor : MeModule
@property (weak, nonatomic) IBOutlet UISwitch *ledSwitch;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
- (IBAction)ledOnOff:(id)sender;

@end
