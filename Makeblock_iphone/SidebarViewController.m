//
//  SidebarViewController.m
//  Makeblock_Iphone
//
//  Created by Riven on 14-9-4.
//  Copyright (c) 2014年 Makeblock. All rights reserved.
//

#import "SidebarViewController.h"
#import "SidebarModuleCell.h"
#import "SWRevealViewController.h"
#import "MeModules/MeModule.h"
#import "LayoutView.h"

@implementation SidebarViewController

- (void)viewDidLoad
{
    self.modules = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MakeblockModules" ofType:@"plist"]];
    [super viewDidLoad];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _modules.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"Modules", @"Modules");
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * CellIdentifier = @"sidebarcell";
    
    SidebarModuleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil){
        cell = [[SidebarModuleCell alloc]init];
    }
//    [cell.modLabel setText:[MeModule getModuleString:moduleItems[indexPath.row]]];
//    [cell.modImage setImage:[UIImage imageNamed:[MeModule getModuleImageString:moduleItems[indexPath.row]]]];
    cell.modLabel.text = NSLocalizedString([[_modules objectAtIndex:indexPath.row] objectForKey:@"name"], nil);
    [cell.modImage setImage:[UIImage imageNamed:[[_modules objectAtIndex:indexPath.row] objectForKey:@"thumb"]]];
    return cell;
}

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
    // Set the title of navigation bar by using the menu items
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    //UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
    
    // Set the photo if it navigates to the PhotoView
    if ([segue.identifier isEqualToString:@"addmodule"]) {
        //LayoutView * layoutview = (LayoutView*)segue.destinationViewController;
        //[layoutview sideBarAddModule:moduleItems[indexPath.row]];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"addmodule" object:nil userInfo:@{@"module":[_modules objectAtIndex:indexPath.row]}];
    }
    
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue*) segue;
        
        swSegue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc) {
            // no navigation for scroll view
            //UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
            //[navController setViewControllers: @[dvc] animated: NO ];
            [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
        };
        
        
    }
    
}


@end
