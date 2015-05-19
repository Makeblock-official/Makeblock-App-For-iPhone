//
//  AboutViewController.m
//  Makeblock_iphone
//
//  Created by 虎子哥 on 14-9-11.
//  Copyright (c) 2014年 Makeblock. All rights reserved.
//

#import "AboutViewController.h"
#import "MobClick.h"
@interface AboutViewController ()

@end

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.list = [NSMutableArray array];
        [_list addObject:@{@"url":[NSString stringWithFormat:@"%@",NSLocalizedString(@"http://doc.makeblock.cc/about-us-iphone/",nil)],@"title":NSLocalizedString(@"Who We Are",nil)}];
        [_list addObject:@{@"url":[NSString stringWithFormat:@"%@",NSLocalizedString(@"http://doc.makeblock.cc/share-iphone/",nil)],@"title":NSLocalizedString(@"Share",nil)}];
        [_list addObject:@{@"url":[NSString stringWithFormat:@"%@",NSLocalizedString(@"http://doc.makeblock.cc/acknowledgements-iphone/",nil)],@"title":NSLocalizedString(@"Acknowledgement",nil)}];
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"HelpPage"];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"HelpPage"];
}

- (void)viewDidLoad
{
    self.title = NSLocalizedString(@"About", nil);
    [_closeButton setTitle:NSLocalizedString(@"X Close", nil) forState:UIControlStateNormal];
    [super viewDidLoad];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[[_list objectAtIndex:0] objectForKey:@"url"]]]];
    [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    [_closeButton addTarget:self action:@selector(closeHandle:) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view from its nib.
    [self closeHandle:nil];
}
-(void)closeHandle:(id)sender{
    [_subWebView setHidden:YES];
    [_subWebView loadHTMLString:@"" baseURL:nil];
    [_closeButton setHidden:YES];
    [self.subView setHidden:YES];
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSInteger loc = [request.URL.relativeString rangeOfString:@"www.makeblock.cc"].length;
    BOOL isOpenSite = loc >0;
    //    NSLog(@"%d",loc);
    if(isOpenSite){
        [[UIApplication sharedApplication]openURL:request.URL];
        return NO;
    }
    loc = [request.URL.relativeString rangeOfString:@"s.jiathis.com"].length;
    if(loc>0){
        [self.subWebView setHidden:NO];
        [self.subView setHidden:NO];
        [self.subWebView loadRequest:request];
        [_closeButton setHidden:NO];
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
