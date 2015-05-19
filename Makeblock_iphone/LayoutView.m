//
//  LayoutView.m
//  Makeblock_Iphone
//
//  Created by Riven on 14-9-2.
//  Copyright (c) 2014年 Makeblock. All rights reserved.
//

#import "LayoutView.h"
#import "MeUserData.h"
#import "UIPopoverController+iPhone.h"
#import "MeModules/MeModule.h"
#import "MeModules/MeUltrasonic.h"
#import "SWRevealViewController/SWRevealViewController.h"
#import "MeModulePopover.h"
#import "MeBlePopover.h"
#import "MWCoreDataManager.h"
#import "MWModuleModel.h"
#import "MobClick.h"
#import "MWUpdateFirmwareViewController.h"
#import "MWVersionManager.h"
@interface LayoutView ()

@end

@implementation LayoutView
@synthesize projIndex,sideBarBtn,runBtn,moduleList,popOver,blePopOver,timer;

CGFloat screenWidth,screenHeight;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    projIndex = [MeUserData share].selIndex;
    self.modAry = [NSMutableArray array];
    self.proj = [[MeUserData share] getProject:projIndex];
    // localize the datastruct, just keep mutable mechanism happy
    NSArray * mods = [[MWCoreDataManager sharedManager]modulesInProject:_proj.pid.intValue];
    self.moduleList = [NSMutableArray arrayWithCapacity:[mods count]];
    for (MWModuleModel * m in mods) {
        [moduleList addObject:m];
        [self addModuleToView:m];
    }
    self.scrollView.exclusiveTouch = NO;
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [sideBarBtn addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [runBtn addTarget:self action:@selector(runLayout:) forControlEvents:UIControlEventTouchUpInside];
    // update screen size
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    screenWidth = screenSize.width;
    screenHeight = screenSize.height;
    isRunning = NO;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"ProjectPage"];
    // init ble manager
    if([BLECentralManager sharedManager].activePeripheral!=nil){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"ble_icon" object:nil userInfo:@{@"connected":[NSNumber numberWithBool:YES]}];
    }else{
        [[BLECentralManager sharedManager] startScanning];
    }
    
    // message handler
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(sideBarAddModule:) name:@"addmodule" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateModulePosition:) name:@"updateposition" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moduleTagged:) name:@"module_taged" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moduleDelete:) name:@"module_delete" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moduleSetup:) name:@"module_setup" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(bleButtonHandler:) name:@"ble_button" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moduleValueChanged:) name:@"module_value" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deleteProject:) name:@"delete_project" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(renameProject:) name:@"rename_project" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeBLE:) name:@"change_ble" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(connectedBLE:) name:@"ble_connected" object:nil];
    
    [[BLECentralManager sharedManager] addDelegate:self];
}
-(void)viewDidUnload{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"addmodule" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"updateposition" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"module_taged" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"module_delete" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"module_setup" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"ble_button" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"module_value" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"delete_project" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"rename_project" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"ble_connected" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"change_ble" object:nil];
    [[BLECentralManager sharedManager] removeDelegate:self];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"ProjectPage"];
    [self stopLayout:nil];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"addmodule" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"updateposition" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"module_taged" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"module_delete" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"module_setup" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"ble_button" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"module_value" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"delete_project" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"rename_project" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"ble_connected" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"change_ble" object:nil];
    [[BLECentralManager sharedManager] removeDelegate:self];
}
-(void)addModuleToView:(MWModuleModel *)mod
{
    MeModule * module;
    //int modtype = [mod.type intValue];
//    NSLog(@"add module %d",mod.xib.intValue);
    
    module = [[[NSBundle mainBundle]loadNibNamed:@"MWModuleView" owner:self options:nil]objectAtIndex:mod.xib.intValue];
    float x = [mod.xPosition floatValue];
    float y = [mod.yPosition floatValue];
    int port = [mod.port intValue];
    [module setModel:mod];
    [module updatePosition:x y:y];
    [module.portLabel setText:port<9?[[NSString alloc] initWithFormat:@"%d",port]:[[NSString alloc] initWithFormat:@"M%d",port-8]];
    [_modAry addObject:module];
    [self.scrollView addSubview:module];
}

-(void)setProjectIndex:(int)index
{
    self.projIndex = index;
}
-(void)deleteProject:(NSNotification*)notification{
    [[MWCoreDataManager sharedManager]removeProject:self.proj];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)renameProject:(NSNotification*)notification{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:self.proj.name message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch(buttonIndex){
        case 0:
        {
        }
            break;
        case 1:{
            NSString *title = NSLocalizedString([alertView buttonTitleAtIndex:buttonIndex], nil);
            if([title isEqualToString:NSLocalizedString(@"Upgrade",nil)]){
                [self.timer invalidate];
                [self dismissViewControllerAnimated:NO completion:nil];
                MWUpdateFirmwareViewController *controller = [[MWUpdateFirmwareViewController alloc]init];
                controller.updateMessage = NSLocalizedString(@"", nil);
                [self presentViewController:controller animated:YES completion:nil];
            }else{
                UITextField *tf = [alertView textFieldAtIndex:0];
                [self.parentViewController.navigationItem setTitle:tf.text.length==0?self.proj.name:tf.text];
                self.proj.name = self.parentViewController.navigationItem.title;
                self.proj.updateTime = [NSDate date];
                [[MWCoreDataManager sharedManager] save];
            }
        }
            break;
    }
}
-(void)changeBLE:(NSNotification*)notification{
   
    if([BLECentralManager sharedManager].activePeripheral.connectedFinish==NO){
        [self runLayout:nil];
    }else{
        for(int i=0;i<_modAry.count;i++){
            MeModule *mod = [_modAry objectAtIndex:i];
            [mod cancel];
        }
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //code to be executed on the main queue after
            
            [[BLECentralManager sharedManager] disconnectPeripheral:[[BLECentralManager sharedManager] activePeripheral].activePeripheral];
        });
    }
}
-(void)moduleCreated:(NSNotification*)notification{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
    MWModuleModel *model = [[[MWCoreDataManager sharedManager]modulesInProject:_proj.pid.intValue]objectAtIndex:0];
    [moduleList addObject:model];
    [self addModuleToView:model];
    
}
-(void)sideBarAddModule:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moduleCreated:) name:NSManagedObjectContextDidSaveNotification object:nil];
    NSDictionary *moduleDict = [notification.userInfo objectForKey:@"module"];
    [[MWCoreDataManager sharedManager]addModule:_proj.pid.intValue withName:NSLocalizedString([moduleDict objectForKey:@"name"],nil) withProtocol:[moduleDict objectForKey:@"protocol"] withType:[[moduleDict objectForKey:@"type"] integerValue] withPort:[[moduleDict objectForKey:@"port"]integerValue] withSlot:[[moduleDict objectForKey:@"slot"]integerValue] withThumb:[moduleDict objectForKey:@"thumb"] withXib:[[moduleDict objectForKey:@"xib"] integerValue] withMenu:[[moduleDict objectForKey:@"menu"]integerValue]];
   
}

-(void)moduleTagged:(NSNotification*)notification
{
    MeModule * mod = [notification.userInfo objectForKey:@"module"];
    MeModulePopover *moduleSetting = [[MeModulePopover alloc] init];
    [moduleSetting setMod:mod];
//    UIPopoverController * pop = [[UIPopoverController alloc]initWithContentViewController:moduleSetting];
//    self.popOver = pop;
//    float w = moduleSetting.view.frame.size.width;
//    float h = moduleSetting.view.frame.size.height;
   
//    pop.delegate = self;
    
    // note that mandatory in landscape mode

    
//    float w = moduleSetting.view.frame.size.width;
//    float h = moduleSetting.view.frame.size.height;
//    pop.popoverContentSize = CGSizeMake(w, h);
//    moduleSetting.preferredContentSize = CGSizeMake(w,h);
//    moduleSetting.modalPresentationStyle = UIModalPresentationPopover;
//    moduleSetting.popoverPresentationController.permittedArrowDirections =UIPopoverArrowDirectionAny;
//    moduleSetting.popoverPresentationController.delegate = self;
//    moduleSetting.popoverPresentationController.sourceView = self.view;
       [self presentViewController:moduleSetting animated:YES completion:nil];
//    [pop presentPopoverFromRect:CGRectMake((screenHeight-w)/2,(screenWidth-h)/2, w, h) inView:self.scrollView permittedArrowDirections:0 animated:YES];
}
//- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
//    //return UIModalPresentationPopover;
//    return UIModalPresentationNone;
//}
-(void)moduleValueChanged:(NSNotification*)notification
{
    NSData * data = [notification.userInfo objectForKey:@"cmd"];
    [[BLECentralManager sharedManager].activePeripheral sendDataMandatory:data];
}

-(void)bleButtonHandler:(NSNotification*)notification
{
    MeBlePopover *blepop = [[MeBlePopover alloc] init];
//    UIPopoverController * pop = [[UIPopoverController alloc]initWithContentViewController:blepop];
//    float w = blepop.view.frame.size.width;
//    float h = blepop.view.frame.size.height;
//    self.blePopOver = pop; // forbit auto release of blepop
//    pop.popoverContentSize = CGSizeMake(w, h);
    //pop.delegate = self;
    // note that mandatory in landscape mode
//    [pop presentPopoverFromRect:CGRectMake((screenHeight-w)/2,(screenWidth-h)/2, w, h) inView:self.scrollView permittedArrowDirections:0 animated:YES];
    [self presentViewController:blepop animated:YES completion:nil];
}

-(void)moduleDelete:(NSNotification*)notification
{
//    if(self.popOver){
//        [self.popOver dismissPopoverAnimated:YES];
//    }
    MeModule * mod = [notification.userInfo objectForKey:@"module"];
    [mod removeFromProject];
    [moduleList removeObject:[mod modDict]];
    [_modAry removeObject:mod];
    [mod removeFromSuperview];
//    [proj setObject:moduleList forKey:@"moduleList"];
//    [[MeUserData share] updateProj:proj index:projIndex];
}

-(void)moduleSetup:(NSNotification*)notification
{
    if(self.popOver){
        [self.popOver dismissPopoverAnimated:YES];
    }
}

-(void)updateModulePosition:(NSNotification*)notification
{
//    [proj setObject:moduleList forKey:@"moduleList"];
//    [[MeUserData share] updateProj:proj index:projIndex];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)pc {
    self.popOver = nil;
}

- (void)runLayout:(id)sender
{
#if 1 // ui test purpose
    if([BLECentralManager sharedManager].activePeripheral==nil){
        [self bleButtonHandler:nil];
        return;
    }
#endif
    for(MeModule * m in _modAry){
        [m setEnable:YES];
    }
    [self.view removeGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [sideBarBtn removeTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [self startQueryTimer];
    isRunning = YES;
    [sideBarBtn setHidden:YES];
}

-(void)stopLayout:(id)sender
{
    [self.navigationItem setHidesBackButton:NO];
    [runBtn removeTarget:self action:@selector(stopLayout:) forControlEvents:UIControlEventTouchUpInside];
    [runBtn addTarget:self action:@selector(runLayout:) forControlEvents:UIControlEventTouchUpInside];
    [runBtn setImage:[UIImage imageNamed:@"run_button.png"] forState:UIControlStateNormal];
    for(MeModule * m in _modAry){
        [m setEnable:NO];
    }
    if(self.revealViewController){
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
        [sideBarBtn addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    }
    [sideBarBtn setHidden:NO];
    [self stopQueryTimer];
    isRunning = NO;
}

#pragma query timer
static int queryIndex=0;
-(void)startQueryTimer
{
    if([_modAry count]==0)
        return;
    
    [runBtn removeTarget:self action:@selector(runLayout:) forControlEvents:UIControlEventTouchUpInside];
    [runBtn addTarget:self action:@selector(stopLayout:) forControlEvents:UIControlEventTouchUpInside];
    [runBtn setImage:[UIImage imageNamed:@"pause_button.png"] forState:UIControlStateNormal];
    
    queryIndex = 0;
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5  target:self selector:@selector(doQueryVersion:) userInfo:nil  repeats:YES];
}

-(void)stopQueryTimer
{
    [_loopTimer invalidate];
    self.loopTimer = nil;
    [self.timer invalidate];
    self.timer = nil;
}
-(void)doQueryVersion:(NSTimer*)timer{
    if(self.loopTimer){
        return;
    }
    /*
     ff 55 len idx action device port slot data a
     0  1  2   3   4      5      6    7    8
     */
    unsigned char a[7]={0xff,0x55,3,VERSION_INDEX,READMODULE,0,'\n'};
    NSData * cmd = [NSData dataWithBytes:a length:7];
    
    [[BLECentralManager sharedManager].activePeripheral sendDataMandatory:cmd];
    queryIndex++;
    NSLog(@"do query version Index:%d",queryIndex);
    if(queryIndex>5){
        [self.timer invalidate];
        [self dismissViewControllerAnimated:NO completion:nil];
//        MWUpdateFirmwareViewController *controller = [[MWUpdateFirmwareViewController alloc]init];
//        controller.updateMessage = NSLocalizedString(@"Arduino firmware not found, need to update the firmware.", nil);
//        [self presentViewController:controller animated:YES completion:nil];
    }
}
-(void)doQuery:(NSTimer *)timer
{
    MeModule * mod = [_modAry objectAtIndex:queryIndex];
    NSData * cmd = [mod getQuery:queryIndex];
    if(cmd!=nil){
        [[BLECentralManager sharedManager].activePeripheral sendDataMandatory:cmd];
    }
    queryIndex++;
    if(queryIndex==[_modAry count]){
        queryIndex = 0;
    }
}

-(void)parseEcho:(NSData*)data
{
    const unsigned char * c = [data bytes];
    if(c[0]==0xff&&c[1]==0x55&&c[2]==VERSION_INDEX){
        if(self.loopTimer){
            return;
        }
        //ff5500d3 4d8a3f0d 0a
        float f = 1.0;
        if(c[3]==4){
            int len = c[4];
            char s[len];
            memcpy(s, c+5, len);
            //NSLog(@"version:%@",[NSString stringWithUTF8String:s]);
            NSLog(@"get version");
            [[MWVersionManager sharedManager]updateVersion:[NSString stringWithUTF8String:s]];
            if([MWVersionManager sharedManager].hasNewOrionVersion){
//                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Tips",nil) message:NSLocalizedString(@"A new version of firmware is available.",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"Upgrade",nil), nil];
//                [alert show];
            }
        }
        NSLog(@"version:%f",f);
        if(f>0){
            [self.loopTimer invalidate];
            float timerInterval=0.08;
            if([[BLECentralManager sharedManager].activePeripheral getBleMode]){
                NSLog(@"start query in dual mode");
                timerInterval = 0.05;
            }
            queryIndex = 0;
            self.loopTimer = [NSTimer scheduledTimerWithTimeInterval:timerInterval  target:self selector:@selector(doQuery:) userInfo:nil  repeats:YES];
        }
    }else{
        int index = c[2];
        if(data.length>5){
            if(_modAry.count>index){
                MeModule * mod = [_modAry objectAtIndex:index];
                if(mod!=nil){
                    if(c[3]==2){
                        float f;
                        [data getBytes:&f range:NSMakeRange(4, 4)];
                        [mod updateModuleValue:f];
                    }else if(c[3]==3){
                        short s;
                        [data getBytes:&s range:NSMakeRange(4, 2)];
                        [mod updateModuleValue:s];
                    }else if(c[3]==1){
                        [mod updateModuleValue:c[4]];
                    }
                }
            }
        }
    }
}
#pragma ble delegate
-(void)bleStateChanged{

}

-(void)bleReceivedData:(NSData *)data{
    if ([[[BLECentralManager sharedManager] activePeripheral] getBootloader]==YES) {
        return;
    };
    const unsigned char * c = [data bytes];
    if(c[0]!=0xff) return;
    [self parseEcho:data];
}

-(void)bleConnected{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ble_icon" object:nil userInfo:@{@"connected":[NSNumber numberWithBool:YES]}];
    [self runLayout:nil];
    [self.blePopOver dismissPopoverAnimated:YES];

}
-(void)bleDisconnected{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ble_icon" object:nil userInfo:@{@"connected":[NSNumber numberWithBool:NO]}];
    [[BLECentralManager sharedManager] startScanning];
    if (isRunning) {
        [self stopLayout:nil];
    }
}
-(void)connectedBLE:(NSNotification*)notification{
    if([[notification.userInfo objectForKey:@"connected"] boolValue]==YES){
        [self bleConnected];
    }
}
@end
