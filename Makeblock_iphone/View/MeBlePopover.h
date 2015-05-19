//
//  MeBlePopover.h
//  Makeblock_Iphone
//
//  Created by Riven on 14-9-9.
//  Copyright (c) 2014年 Makeblock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLECentralManager.h"

@interface MeBlePopover : UIViewController <UIPickerViewDataSource,UIPickerViewDelegate,BLEControllerDelegate>
{
    NSInteger selectedIndex;
    BOOL isConnected;
}
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UIButton *disconnButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIPickerView *bleDevice;
- (IBAction)connectDevice:(id)sender;
- (IBAction)refreshBle:(id)sender;


@end
