//
//  MWProjectExampleTableViewCell.h
//  Makeblock HD
//
//  Created by 虎子哥 on 14-3-25.
//  Copyright (c) 2014年 Makerworks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MWProjectExampleTableViewCell : UITableViewCell
@property(nonatomic,weak)IBOutlet UIButton *leftButton;
@property(nonatomic,weak)IBOutlet UIButton *middleButton;
@property(nonatomic,weak)IBOutlet UIButton *rightButton;

@property(nonatomic,weak)IBOutlet UIImageView *rightImageView;
@property(nonatomic,weak)IBOutlet UIImageView *middleImageView;
@property(nonatomic,weak)IBOutlet UIImageView *leftImageView;

@property(nonatomic,weak)IBOutlet UILabel *leftLabel;
@property(nonatomic,weak)IBOutlet UILabel *rightLabel;
@property(nonatomic,weak)IBOutlet UILabel *middleLabel;

@property(nonatomic,assign)NSInteger row;
- (IBAction)rightHandle:(id)sender;
- (IBAction)middleHandle:(id)sender;
- (IBAction)leftHandle:(id)sender;
@end
