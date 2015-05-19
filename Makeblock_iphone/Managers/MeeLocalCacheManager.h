//
//  MeeLocalCacheManager.h
//  LocalCacheDemo
//
//  Created by 虎子哥 on 6/13/14.
//  Copyright (c) 2014 Xeecos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MeeLocalCacheManager :  NSURLCache
{
	NSMutableDictionary *cachedResponses;
}
+(MeeLocalCacheManager*)sharedManager;
-(BOOL)clean;
@end
