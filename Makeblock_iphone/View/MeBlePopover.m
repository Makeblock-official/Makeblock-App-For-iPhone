//
//  MeBlePopover.m
//  Makeblock_Iphone
//
//  Created by Riven on 14-9-9.
//  Copyright (c) 2014年 Makeblock. All rights reserved.
//

#import "MeBlePopover.h"

@interface MeBlePopover ()

@end

@implementation MeBlePopover
@synthesize connectButton,disconnButton,bleDevice;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if([BLECentralManager sharedManager].activePeripheral==nil){
        [self.connectButton setTitle:NSLocalizedString(@"Connect",nil) forState:UIControlStateNormal];
    }else{
        [self.connectButton setTitle:NSLocalizedString(@"Disconnect",nil) forState:UIControlStateNormal];
    }
    [self.disconnButton setTitle:NSLocalizedString(@"Refresh", nil) forState:UIControlStateNormal];
    [self.backButton setTitle:NSLocalizedString(@"Back", nil) forState:UIControlStateNormal];
    [[BLECentralManager sharedManager] addDelegate:self];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[BLECentralManager sharedManager] removeDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    NSInteger count = [BLECentralManager sharedManager].peripherals.count;
    //NSLog(@"num of peri %ld",count);
    return count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if(row>=[BLECentralManager sharedManager].peripherals.count) // quick fix of array updated
        return @"";
    CBPeripheral *p = [[BLECentralManager sharedManager].peripherals objectAtIndex:row];
    NSString * uuidStr = [[NSString alloc] initWithFormat:@"%@",[p.identifier UUIDString]];
    //    NSArray *uuidAry = [uuidStr componentsSeparatedByString:@"-"];
    NSNumber * rssi = [[BLECentralManager sharedManager].rssiDict objectForKey:uuidStr];
    
    float dist = powf(10.0,((abs(rssi.intValue)-50.0)/50.0))*0.7;
    if([p isEqual:[BLECentralManager sharedManager].activePeripheral.activePeripheral]){
        NSString *s = [[NSString alloc] initWithFormat:@"> %@ ( %.1f m )",p.name,dist];//,[uuidAry objectAtIndex:1]];
        return s;
    }else{
        NSString *s = [[NSString alloc] initWithFormat:@"%@ ( %.1f m )",p.name,dist];//,[uuidAry objectAtIndex:1]];
        return s;
    }
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    selectedIndex = row;
}
- (IBAction)closeHandle:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"ble_connected" object:nil userInfo:@{@"connected":[NSNumber numberWithBool:isConnected]}];
        
    }];
}

- (IBAction)connectDevice:(id)sender {
    UIButton *bt = (UIButton*)sender;
    if([bt.titleLabel.text isEqualToString:NSLocalizedString(@"Connect",nil)]){
        if ([[BLECentralManager sharedManager].peripherals count]==0) {
            return;
        }
        [self.connectButton setTitle:NSLocalizedString(@"Connecting",nil) forState:UIControlStateNormal];
        CBPeripheral *p = [[BLECentralManager sharedManager].peripherals objectAtIndex:selectedIndex];
        [[BLECentralManager sharedManager] stopScanning];
        [[BLECentralManager sharedManager] connectPeripheral:p];
    }else if([bt.titleLabel.text isEqualToString:NSLocalizedString(@"Disconnect",nil)]){
        [[BLECentralManager sharedManager] disconnectPeripheral:[BLECentralManager sharedManager].activePeripheral.activePeripheral];
    }
}

- (IBAction)refreshBle:(id)sender {
    [[BLECentralManager sharedManager] startScanning];
}

-(void)bleStateChanged{
    [self.bleDevice reloadAllComponents];
}

-(void)bleConnected{
    isConnected = YES;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ble_icon" object:nil userInfo:@{@"connected":[NSNumber numberWithBool:isConnected]}];
    [self.connectButton setTitle:NSLocalizedString(@"Disconnect",nil) forState:UIControlStateNormal];
}
-(void)bleDisconnected{
    isConnected = NO;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ble_icon" object:nil userInfo:@{@"connected":[NSNumber numberWithBool:isConnected]}];
    [self.connectButton setTitle:NSLocalizedString(@"Connect",nil) forState:UIControlStateNormal];
    [[BLECentralManager sharedManager] startScanning];
    [self.bleDevice reloadAllComponents];
}
@end
