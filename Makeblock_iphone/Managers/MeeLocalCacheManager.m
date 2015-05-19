//
//  MeeLocalCacheManager.m
//  LocalCacheDemo
//
//  Created by 虎子哥 on 6/13/14.
//  Copyright (c) 2014 Xeecos. All rights reserved.
//

#import "MeeLocalCacheManager.h"
#import <CommonCrypto/CommonDigest.h>


@implementation MeeLocalCacheManager
static MeeLocalCacheManager*_instance;

+(MeeLocalCacheManager*)sharedManager{
    if (_instance == nil) {
        _instance = [[MeeLocalCacheManager alloc]init];
    }
    return _instance;
}
- (NSDictionary *)cachePaths
{
	return [NSDictionary dictionary];
}

- (NSString *)mimeTypeForPath:(NSString *)path
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[self infoPath:path]];
	return [dict objectForKey:@"MIMEType"];
}
- (NSString *)encodingForPath:(NSString *)path
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[self infoPath:path]];
	return [dict objectForKey:@"textEncoding"];
}
- (BOOL)fileExist:(NSString*)path{
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}
-(NSData*)fileData:(NSString*)path{
    return [[NSFileManager defaultManager] contentsAtPath:path];
}
-(NSString *) md5Path:(NSString*)name
{
    const char *original_str = [name UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, (unsigned int)strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++){
        if(i==2){
            //[hash appendString:@"/"];
        }
        [hash appendFormat:@"%02X", result[i]];
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"webdata"];
    NSFileManager *manager = [NSFileManager defaultManager];
    if(![manager contentsOfDirectoryAtPath:documentsDirectory error:nil]){
        [manager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return [documentsDirectory stringByAppendingPathComponent:[hash lowercaseString]];
}
- (NSString *)cachePath:(NSString *)path {
    return [self md5Path:path];
}
- (NSString *)infoPath:(NSString *)path {
    return [self md5Path:[NSString stringWithFormat:@"%@-info", path]];
}
- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request{
	NSString *pathString = [[request URL] absoluteString];
    NSData *data = [cachedResponse data];
    NSURLResponse *response = cachedResponse.response;
    if(data){
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]], @"time",
                              response.MIMEType, @"MIMEType",
                              response.textEncodingName, @"textEncoding", nil];
        
        [[NSFileManager defaultManager] createFileAtPath:[self cachePath:pathString] contents:data attributes:nil];
        [dict writeToFile:[self infoPath:pathString] atomically:YES];
    }
}
- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request
{
	NSString *pathString = [[request URL] absoluteString];
	if (![self fileExist:[self cachePath:pathString]])
	{
        return [super cachedResponseForRequest:request];
	}else{
        NSData *data = [self fileData:[self cachePath:pathString]];
        NSURLResponse *response = [[NSURLResponse alloc]initWithURL:[request URL] MIMEType:[self mimeTypeForPath:pathString]expectedContentLength:[data length] textEncodingName:[self encodingForPath:pathString]];
        return [[NSCachedURLResponse alloc] initWithResponse:response data:data];
    }
}
-(BOOL)clean{
    NSString *document = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]stringByAppendingPathComponent:@"webdata"];
    
    NSFileManager *manager = [NSFileManager defaultManager];

    if(![manager contentsOfDirectoryAtPath:document error:nil]){
        [manager createDirectoryAtPath:document withIntermediateDirectories:NO attributes:nil error:nil];
    }
    BOOL result = [[NSFileManager defaultManager] removeItemAtPath:document error:nil];
    return result;
}

@end
