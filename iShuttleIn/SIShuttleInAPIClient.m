//
//  SIShuttleInAPIClient.m
//  iShuttleIn
//
//  Created by Di Huang on 5/17/14.
//
//

#import "SIShuttleInAPIClient.h"
#import "SIGeoLocation.h"
#import "SIDirection.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>

@interface SIShuttleInAPIClient ()

@property (nonatomic, copy) NSString *baseURLString;

@end

@implementation SIShuttleInAPIClient

- (instancetype)init {
    self = [super init];
    if (self) {
        self.baseURLString = @"http://www.shuttlein.dihuang.me/shuttle";
    }
    return self;
}

#pragma mark -

- (AFHTTPRequestOperation *)directionFrom:(SIGeoLocation *)from
                                       to:(SIGeoLocation *)to
                                 callback:(void (^)(NSError *, SIDirection *))callback {
    NSDictionary *parameters = @{
                                 @"from": @{
                                         @"lat": [NSNumber numberWithDouble:from.lat],
                                         @"lng": [NSNumber numberWithDouble:from.lng]
                                         },
                                 @"to": @{
                                         @"lat": [NSNumber numberWithDouble:to.lat],
                                         @"lng": [NSNumber numberWithDouble:to.lng]
                                         }
                                 };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    return [manager GET:[self.baseURLString stringByAppendingString:@"/directions"]
             parameters:parameters
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"Request: %@", operation.description);
                    if (callback) {
                        SIDirection *direction = [[SIDirection alloc] init];
                        direction.time = [(NSNumber *)[(NSArray *)[(NSDictionary *)responseObject objectForKey:@"time"] objectAtIndex:1] intValue];
                        direction.distance = [(NSString *)[(NSArray *)[(NSDictionary *)responseObject objectForKey:@"distance"] objectAtIndex:1] doubleValue];
                        callback(nil, direction);
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    if (callback) {
                        callback(error, nil);
                    }
                }];
}


@end
