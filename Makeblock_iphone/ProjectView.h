//
//  ProjectView.h
//  Makeblock_Iphone
//
//  Created by Riven on 14-9-1.
//  Copyright (c) 2014年 Makeblock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWProjectCreateTableViewCell.h"
#import "MWProjectExampleTableViewCell.h"
#import "MWProjectHistoryTableViewCell.h"

@interface ProjectView : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITableView *projectList;
@property (strong,nonatomic) IBOutlet MWProjectCreateTableViewCell*createCell;
@property (strong,nonatomic) IBOutlet MWProjectExampleTableViewCell*exampleCell;
@property (strong,nonatomic) IBOutlet MWProjectHistoryTableViewCell*historyCell;
@property (strong,nonatomic) NSMutableArray *examples;
-(void)newLayout;
-(IBAction)openMenu:(id)sender;
@end
