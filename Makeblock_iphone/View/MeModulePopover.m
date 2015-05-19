//
//  MeModulePopover.m
//  Makeblock_Iphone
//
//  Created by Riven on 14-9-5.
//  Copyright (c) 2014年 Makeblock. All rights reserved.
//

#import "MeModulePopover.h"
#import "MWCoreDataManager.h"
@interface MeModulePopover ()

@end

@implementation MeModulePopover
@synthesize mod;

NSArray * portAry;
NSArray * slotAry;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        portAry = @[@"PORT 1",@"PORT 2",@"PORT 3",@"PORT 4",@"PORT 5",@"PORT 6",@"PORT 7",@"PORT 8",@"M1",@"M2"];
        slotAry = @[@"SLOT 1",@"SLOT 2"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.BtnDelete setTitle:NSLocalizedString(@"Delete",nil) forState:UIControlStateNormal];
    [self.BtnDelete setTitle:NSLocalizedString(@"Delete",nil) forState:UIControlStateHighlighted];
    [self.BtnOk setTitle:NSLocalizedString(@"Save",nil) forState:UIControlStateNormal];
    [self.BtnOk setTitle:NSLocalizedString(@"Save",nil) forState:UIControlStateHighlighted];
    int type = [mod.model.type intValue];
    if(type==DEV_JOYSTICK){
        [self.BtnOk setTitle:NSLocalizedString(@"Back",nil) forState:UIControlStateNormal];
        [self.BtnOk setTitle:NSLocalizedString(@"Back",nil) forState:UIControlStateHighlighted];
    }

    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    int port = mod.model.port.intValue;
    int slot = mod.model.slot.intValue;
    [_picker selectRow:port-1 inComponent:0 animated:NO];
    if(slot>0){
        [_picker selectRow:slot-1 inComponent:1 animated:NO];
    }
    NSLog(@"%f %f",self.view.frame.size.width,self.view.frame.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)deleteModule:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"module_delete" object:nil userInfo:@{@"module":mod}];
    }];
}
- (IBAction)commitChange:(id)sender {
    mod.model.port = [NSNumber numberWithInteger:[_picker selectedRowInComponent:0]+1];
    if(_picker.numberOfComponents>1){
        mod.model.slot = [NSNumber numberWithInteger:[_picker selectedRowInComponent:1]+1];
    }
    int port = (int)[_picker selectedRowInComponent:0]+1;
    [mod.portLabel setText:port<9?[[NSString alloc] initWithFormat:@"%d",port]:[[NSString alloc] initWithFormat:@"M%d",port-8]];
    [[MWCoreDataManager sharedManager]save];
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"module_setup" object:nil userInfo:nil];
    }];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    int slot = mod.model.slot.intValue;
    return slot>0?2:1;
}
// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    int type = [mod.model.type intValue];
//    dLog(@"type:%d",type);
    if(type==DEV_JOYSTICK){
        return 0;
    }
    if (component==0) {
        if(type==DEV_DCMOTOR){
            return 10;
        }
        return 8;
    }else if(component==1){
        int slot = mod.model.slot.intValue;
        if (slot>0) {
            return 2;
        }
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (component==0) {
        return [portAry objectAtIndex:row];
    }else{
        return [slotAry objectAtIndex:row];
    }
}

@end
