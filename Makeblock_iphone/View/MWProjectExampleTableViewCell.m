//
//  MWProjectExampleTableViewCell.m
//  Makeblock HD
//
//  Created by 虎子哥 on 14-3-25.
//  Copyright (c) 2014年 Makerworks. All rights reserved.
//

#import "MWProjectExampleTableViewCell.h"
#import "MWNotification.h"
@implementation MWProjectExampleTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:NO animated:animated];

    // Configure the view for the selected state
}
-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:NO animated:animated];
}

- (IBAction)rightHandle:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:EXAMPLE_SELECTED object:nil userInfo:@{@"index":[NSNumber numberWithInt:(int)_row*3+2]}];
}

- (IBAction)middleHandle:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:EXAMPLE_SELECTED object:nil userInfo:@{@"index":[NSNumber numberWithInt:(int)_row*3+1]}];
}

- (IBAction)leftHandle:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:EXAMPLE_SELECTED object:nil userInfo:@{@"index":[NSNumber numberWithInt:(int)_row*3]}];
}
@end
