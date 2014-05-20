//
//  SIShuttleInAPIClient.h
//  iShuttleIn
//
//  Created by Di Huang on 5/17/14.
//
//

#import <Foundation/Foundation.h>
@class SIDirection;
@class SIGeoLocation;
@class AFHTTPRequestOperation;

@interface SIShuttleInAPIClient : NSObject

- (AFHTTPRequestOperation *)directionFrom:(SIGeoLocation *)from
                            to:(SIGeoLocation *)to
                      callback:(void (^)(NSError *error, SIDirection *direction))callback;

- (AFHTTPRequestOperation *)shuttleETA:(int)vehicleId
                                    to:(SIGeoLocation *)to
                              callback:(void (^)(NSError *error, SIDirection *direction))callback;

@end
