//
//  MWVersionManager.m
//  Makeblock_iphone
//
//  Created by 虎子哥 on 15/2/26.
//  Copyright (c) 2015年 Makeblock. All rights reserved.
//

#import "MWVersionManager.h"
#import "MWFileManager.h"

static MWVersionManager *_instance;
@implementation MWVersionManager
+(MWVersionManager*)sharedManager{
    if(_instance==nil){
        _instance = [[MWVersionManager alloc]init];
    }
    return _instance;
}
-(void)start{
    self.data = [NSMutableData data];
    _hasNewOrionVersion = NO;
    _hasNewBotVersion = NO;
    
    self.orionVer = @"1.0.103";
    
    NSURLConnection *conn = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://makeblock.sinaapp.com/apps/app_config.xml"]] delegate:self];
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
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:_data];
    parser.delegate=self;
    [parser parse];
}
-(void)updateVersion:(NSString*)ver{
    if(_orionVer){
        if(ver){
            [[NSUserDefaults standardUserDefaults] setObject:ver forKey:@"orion_firmware_ver"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            _hasNewOrionVersion = [ver rangeOfString:_orionVer].length==0;
        }
    }
}
#pragma mark - xml parse
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
     if ([@"iphone" isEqualToString:elementName]) {//解析到一个videos标签
         self.firmwares = [NSMutableArray array];
     }else if ([@"firmware" isEqualToString:elementName]){
         [self.firmwares addObject:attributeDict];
     }
}
-(void)parserDidEndDocument:(NSXMLParser *)parser{
    for(NSDictionary *dict in _firmwares){
        if([[dict objectForKey:@"name"] isEqualToString:@"orion"]){
            NSString *lastVer = [[NSUserDefaults standardUserDefaults]objectForKey:@"orion_firmware_ver"];
            if(![lastVer isEqualToString:[dict objectForKey:@"ver"]]){
                _hasNewOrionVersion = YES;
            }
            self.orionURL = [dict objectForKey:NSLocalizedString(@"en", nil)];
            self.orionVer = [dict objectForKey:@"ver"];
        }
    }
}

@end
