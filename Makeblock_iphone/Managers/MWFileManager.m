//
//  MWFileManager.m
//  Makeblock_iphone
//
//  Created by 虎子哥 on 15/2/26.
//  Copyright (c) 2015年 Makeblock. All rights reserved.
//

#import "MWFileManager.h"
static MWFileManager *_instance;
@implementation MWFileManager
+(MWFileManager*)sharedManager{
    if(_instance==nil){
        _instance = [[MWFileManager alloc]init];
    }
    return _instance;
}
-(void)start:(NSString*)path delegate:(id<MWFileDelegate>)delegate{
    NSLog(@"hex path:%@",path);
    self.delegate = delegate;
    self.data = [NSMutableData data];
    NSURLConnection *conn = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:path]] delegate:self];
    [conn start];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_data appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    //    NSString *result = [NSString stringWithUTF8String:_data.bytes];
    //    NSLog(@"result:%@",result);
    if(self.delegate){
        [_delegate loadedFile:_data];
    }
}
@end