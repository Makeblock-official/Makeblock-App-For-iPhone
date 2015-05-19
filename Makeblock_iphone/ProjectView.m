//
//  ProjectView.m
//  Makeblock_Iphone
//
//  Created by Riven on 14-9-1.
//  Copyright (c) 2014年 Makeblock. All rights reserved.
//

#import "ProjectView.h"
#import "ProjectCell.h"
#import "LayoutView.h"
#import "MeUserData.h"
#import "HelpViewController.h"
#import "AboutViewController.h"
#import "MWProjectModel.h"
#import "MWCalendarUtil.h"
#import "MWCoreDataManager.h"
#import "MWNotification.h"
#import "MobClick.h"

@implementation ProjectView
@synthesize projectList;

NSArray * projects;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.examples = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Examples" ofType:@"plist"]];
    self.projectList.allowsMultipleSelectionDuringEditing = NO;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Back",nil) style:UIBarButtonItemStyleBordered target:self action:@selector(backHandle:)];
}
-(void)backHandle:(id)sender{
    
}
-(void)viewWillAppear:(BOOL)animated{
    projects = [[MeUserData share] getProjectList];
    [projectList reloadData];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(selectExample:) name:EXAMPLE_SELECTED object:nil];
    [MobClick beginLogPageView:@"ProjectsPage"];
    [super viewWillAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:EXAMPLE_SELECTED object:nil];
    
    [MobClick endLogPageView:@"ProjectsPage"];
}
-(void)viewDidAppear:(BOOL)animated{
    [self.tabBarController.tabBar setHidden:NO];
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName=nil;
    switch (section)
    {
        case 0:
            //NSLocalizedString(@"Projects", @"Projects");
            break;
        case 1:
        {
            if([projects count]>0){
                sectionName = NSLocalizedString(@"History", nil);
            }
        }
            break;
        default:
            sectionName = NSLocalizedString(@"Examples", nil);
            break;
    }
    return sectionName;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return [projects count];
            break;
        case 2:
            return 3;
            break;
    }
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if(indexPath.section==0) {
//        static NSString * CellIdentifier = @"projectcell";
//        ProjectCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        NSMutableDictionary * proj =[projects objectAtIndex:indexPath.row];
//        [cell.ProjectName setText:[proj objectForKey:@"name"]];
//        [cell.ModifyDate setText:[proj objectForKey:@"updateTime"]];
//        return cell;
//    }else{
//        static NSString * CellIdentifier = @"projectcell";
//        ProjectCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        [cell.ProjectName setText:@"B"];
//        return cell;
//    }
    if(indexPath.section==0) {
        MWProjectCreateTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"createCell"];
        if(cell==nil){
            
            [[NSBundle mainBundle]loadNibNamed:@"MWProjectCreateTableViewCell" owner:self options:nil];
            cell = self.createCell;
            _createCell = nil;
        }
        cell.infoLabel.text = [NSString stringWithFormat:@"%@ >",NSLocalizedString(@"Create New Project", nil)];
        return cell;
    }else if(indexPath.section==1){
        MWProjectHistoryTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"historyCell"];
        if(cell==nil){
            
            [[NSBundle mainBundle]loadNibNamed:@"MWProjectHistoryTableViewCell" owner:self options:nil];
            cell = self.historyCell;
            _historyCell = nil;
        }

        //        [cell.ProjectName setText:[proj objectForKey:@"name"]];
        //        [cell.ModifyDate setText:[proj objectForKey:@"updateTime"]];

        MWProjectModel *model = [projects objectAtIndex:indexPath.row];
        cell.titleLabel.text = model.name;
        cell.dateLabel.text = [MWCalendarUtil stringFromDate:model.updateTime withFormat:@"YYYY/MM/dd hh:mm"];;
        cell.dateLabel.text = [MWCalendarUtil stringFromDate:model.updateTime withFormat:@"YYYY/MM/dd hh:mm"];
        return cell;
    }else{
        MWProjectExampleTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"exampleCell"];
        if(cell==nil){
            
            [[NSBundle mainBundle]loadNibNamed:@"MWProjectExampleTableViewCell" owner:self options:nil];
            cell = self.exampleCell;
            _exampleCell = nil;
        }
        NSDictionary *example = [_examples objectAtIndex:indexPath.row*3];
        [cell.leftImageView setImage:[UIImage imageNamed:[example objectForKey:@"thumb"]]];
        [cell.leftLabel setText:NSLocalizedString([example objectForKey:@"name"],nil)];
        if(indexPath.row*3+1<_examples.count){
            example = [_examples objectAtIndex:indexPath.row*3+1];
            [cell.middleImageView setImage:[UIImage imageNamed:[example objectForKey:@"thumb"]]];
            [cell.middleLabel setText:NSLocalizedString([example objectForKey:@"name"],nil)];
        }
        if(indexPath.row*3+2<_examples.count){
            example = [_examples objectAtIndex:indexPath.row*3+2];
            [cell.rightImageView setImage:[UIImage imageNamed:[example objectForKey:@"thumb"]]];
            [cell.rightLabel setText:NSLocalizedString([example objectForKey:@"name"],nil)];
        }
        cell.row = indexPath.row;
        return cell;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0){
        return 60.0;
    }else if(indexPath.section==1){
        return 60.0;
    }
    return 160.0;
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.section==1;
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    int index = (int)[projectList indexPathForSelectedRow].row;
    [[MeUserData share] selIndex:index];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0){
        [self newLayout];
    }else if(indexPath.section==1){
        [self performSegueWithIdentifier:@"pushtoproject" sender:self];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if(indexPath.section==1){
            MWProjectModel *model = [projects objectAtIndex:indexPath.row];
            [[MWCoreDataManager sharedManager] removeProject:model];
            [[MWCoreDataManager sharedManager] save];
            projects = [[MWCoreDataManager sharedManager]allProjects];
            // Delete the row from the data source.
            [tableView reloadData];
            [projectList reloadData];
        }
    }
}

-(void)newLayout
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Project's Name",nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}
-(void)selectExample:(NSNotification*)notification{
    int index = [[notification.userInfo objectForKey:@"index"] intValue];
    
    NSDictionary *example = [_examples objectAtIndex:index];
    MWProjectModel *proj = [[MWCoreDataManager sharedManager]addProject:NSLocalizedString([example objectForKey:@"name"],nil) withTag:@"" withType:1];
    NSArray *modules = [example objectForKey:@"modules"];
    for(int i=0;i<modules.count;i++){
        NSDictionary *module = [modules objectAtIndex:i];
        MWModuleModel *mod = [[MWCoreDataManager sharedManager]addModule:proj.pid.intValue withName:[module objectForKey:@"name"] withProtocol:[module objectForKey:@"protocol"] withType:[[module objectForKey:@"type"] intValue] withPort:[[module objectForKey:@"port"] intValue] withSlot:[[module objectForKey:@"slot"] intValue] withThumb:[module objectForKey:@"thumb"] withXib:[[module objectForKey:@"xib"] intValue] withMenu:[[module objectForKey:@"menu"] intValue]];
        
        [mod setXPosition:[module objectForKey:@"xPosition"]];
        [mod setYPosition:[module objectForKey:@"yPosition"]];
    }
    [[MWCoreDataManager sharedManager]save];
    [self performSegueWithIdentifier:@"pushtoproject" sender:self];

}
#pragma mark - IBActions
-(IBAction)openMenu:(id)sender{
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"Back",nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Help",nil),NSLocalizedString(@"About",nil), nil];
    [sheet showInView:self.view];
}
#pragma mark - action sheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:{
            HelpViewController *controller = [[HelpViewController alloc]init];
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 1:{
            AboutViewController *controller = [[AboutViewController alloc]init];
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        default:
            break;
    }
}
#pragma mark - alert view
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch(buttonIndex){
        case 0:
        {
            [self.projectList reloadData];
        }
        break;
        case 1:{
            
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(projectCreated:) name:NSManagedObjectContextDidSaveNotification object:nil];
            UITextField *tf = [alertView textFieldAtIndex:0];
            NSString * layoutName = [tf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [[MeUserData share]newProject:layoutName];
//            NSIndexPath* selectedCellIndexPath= [NSIndexPath indexPathForRow:index inSection:0];
//            [projectList selectRowAtIndexPath:selectedCellIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            
        }
        break;
    }
}

-(void)projectCreated:(NSNotification*)notification{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
    [projectList reloadData];
    [self performSegueWithIdentifier:@"pushtoproject" sender:self];
}


@end
