//
//  HelpViewController.m
//  Makeblock_iphone
//
//  Created by 虎子哥 on 14-9-11.
//  Copyright (c) 2014年 Makeblock. All rights reserved.
//

#import "HelpViewController.h"
#import "MobClick.h"
@interface HelpViewController ()

@end

@implementation HelpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.list = [NSMutableArray array];
        [_list addObject:@{@"url":[NSString stringWithFormat:@"%@?",NSLocalizedString(@"http://doc.makeblock.cc/getting-started-iphone/",nil)],@"title":NSLocalizedString(@"Getting Started",nil)}];
        [_list addObject:@{@"url":[NSString stringWithFormat:@"%@?",NSLocalizedString(@"http://doc.makeblock.cc/how-it-works-iphone/",nil)],@"title":NSLocalizedString(@"How It Works",nil)}];
        [_list addObject:@{@"url":[NSString stringWithFormat:@"%@?",NSLocalizedString(@"http://doc.makeblock.cc/faq-iphone/",nil)],@"title":NSLocalizedString(@"FAQ",nil)}];
        [_list addObject:@{@"url":NSLocalizedString(@"http://doc.makeblock.cc/feedback-iphone/",nil),@"title":NSLocalizedString(@"Feedback",nil)}];
    }
    return self;
}

- (void)viewDidLoad
{
    self.title = NSLocalizedString(@"Help", nil);
    [super viewDidLoad];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[_list objectAtIndex:0] objectForKey:@"url"]]]];
    [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"HelpPage"];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"HelpPage"];
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSInteger len = [request.URL.relativeString rangeOfString:@"bbs.makeblock.cc"].length+[request.URL.relativeString rangeOfString:@"forum.makeblock.cc"].length;
    if(len>0){
        [[UIApplication sharedApplication]openURL:request.URL];
        return NO;
    }
    
    return YES;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _list.count;
}
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return 1;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell==nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [[_list objectAtIndex:indexPath.row] objectForKey:@"title"];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[_list objectAtIndex:indexPath.row] objectForKey:@"url"]]]];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
