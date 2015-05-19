//
//  HelpViewController.h
//  Makeblock_iphone
//
//  Created by 虎子哥 on 14-9-11.
//  Copyright (c) 2014年 Makeblock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIWebViewDelegate>
@property (nonatomic,strong)NSMutableArray *list;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
