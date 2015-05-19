//
//  MeSevenseg.h
//  Makeblock_Iphone
//
//  Created by Riven on 14-9-5.
//  Copyright (c) 2014年 Makeblock. All rights reserved.
//

#import "MeModule.h"

@interface MeSevenseg : MeModule<UITextFieldDelegate>
{
    UITapGestureRecognizer *tap;
}
@property (weak, nonatomic) IBOutlet UITextField *numberTxt;
@property (weak, nonatomic) IBOutlet UISwitch *timeSyncButton;
@property (nonatomic,strong)NSTimer *timer;

- (IBAction)digitOnChanged:(id)sender;
- (IBAction)timeSync:(id)sender;

@end
