//
//  LayoutView.h
//  Makeblock_Iphone
//
//  Created by Riven on 14-9-2.
//  Copyright (c) 2014年 Makeblock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLECentralManager.h"
#import "MWProjectModel.h"


@interface LayoutView : UIViewController <UIPopoverControllerDelegate,BLEControllerDelegate,UIAlertViewDelegate>
{
    BOOL isRunning;
}
@property (nonatomic) int projIndex;
@property NSMutableArray * moduleList;

@property (nonatomic,strong)MWProjectModel * proj;
@property (nonatomic,strong)NSMutableArray * modAry;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *sideBarBtn;
@property (weak, nonatomic) IBOutlet UIButton *runBtn;
@property (nonatomic,strong) UIPopoverController *popOver;
@property (nonatomic,strong) UIPopoverController *blePopOver;
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,strong)NSTimer *loopTimer;

-(void)setProjectIndex:(int)index;

@end
