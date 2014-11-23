//
//  SIStopStore.h
//  iShuttleIn
//
//  Created by Di Huang on 11/22/14.
//
//

#import <Foundation/Foundation.h>

@interface SIStopStore : NSObject

@property (nonatomic) NSDictionary *stop;
@property (nonatomic) NSDictionary *route;

//Notice that this is a class method and prefixed with a + instead of -
+ (instancetype)sharedStore;

@end
