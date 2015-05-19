//
//  MeModulePopover.h
//  Makeblock_Iphone
//
//  Created by Riven on 14-9-5.
//  Copyright (c) 2014年 Makeblock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeModule.h"

@interface MeModulePopover : UIViewController <UIPickerViewDataSource,UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *BtnDelete;
@property (weak, nonatomic) IBOutlet UIButton *BtnOk;
@property (weak, nonatomic) IBOutlet UILabel *NameLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property MeModule * mod;
- (IBAction)deleteModule:(id)sender;
- (IBAction)commitChange:(id)sender;
@end
