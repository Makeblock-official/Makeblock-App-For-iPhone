//
//  MWCalendarUtil.m
//  Makeblock HD
//
//  Created by 虎子哥 on 14-3-28.
//  Copyright (c) 2014年 Makerworks. All rights reserved.
//

#import "MWCalendarUtil.h"

@implementation MWCalendarUtil
+(NSString*)stringFromDate:(NSDate*)date withFormat:(NSString *)format{
    NSDateFormatter *ftt = [[NSDateFormatter alloc]init];
    [ftt setDateFormat:format];
    return [ftt stringFromDate:date];
}
@end
