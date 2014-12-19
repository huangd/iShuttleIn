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
#import <AFNetworking+PromiseKit.h>


@interface SIShuttleInAPIClient ()

@property (nonatomic, copy) NSString *baseURLString;
@property (nonatomic) AFHTTPRequestOperationManager *httpRequestOperationManager;

@end

@implementation SIShuttleInAPIClient

+ (SIShuttleInAPIClient *)sharedShuttleInAPIClient {
  static SIShuttleInAPIClient *shared = nil;
  if (shared == nil) {
    shared = [[SIShuttleInAPIClient alloc] initPrivate];
  }
  return shared;
}

- (SIShuttleInAPIClient *)initPrivate {
  self = [super init];
  if (self) {
    self.baseURLString = @"http://www.shuttlein.dihuang.me/shuttle";
    self.httpRequestOperationManager = [AFHTTPRequestOperationManager manager];
  }
  return self;
  
}

- (instancetype)init {
  @throw [NSException exceptionWithName:@"Singleton" reason:@"should call sharedShuttleAPIClient" userInfo:nil];
}

#pragma mark -

- (AFHTTPRequestOperation *)directionFrom:(SIGeoLocation *)from
                                       to:(SIGeoLocation *)to
                                 callback:(void (^)(NSError *, SIDirection *))callback {
  if (from.lat == nil || from.lng == nil || to.lat == nil || to.lng == nil) {
    callback([NSError errorWithDomain:@"from, to is nil" code:0 userInfo:nil], nil);
    return nil;
  }
  
  NSDictionary *parameters = @{
                               @"from": @{
                                   @"lat": from.lat,
                                   @"lng": from.lng
                                   },
                               @"to": @{
                                   @"lat": to.lat,
                                   @"lng": to.lng
                                   }
                               };
  return [self.httpRequestOperationManager GET:[self.baseURLString stringByAppendingString:@"/directions"]
                                    parameters:parameters
                                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         NSLog(@"directionFromTo operation: %@", operation);
                                         [self successDirectionHandlerResponse:responseObject callback:callback];
                                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         if (callback) {
                                           callback(error, nil);
                                         }
                                       }];
}

- (AFHTTPRequestOperation *)shuttleETA:(NSNumber *)vehicleId to:(NSNumber *)stopId
                              callback:(void (^)(NSError *, SIDirection *))callback {
  return [self.httpRequestOperationManager GET:[self.baseURLString stringByAppendingString:[NSString stringWithFormat:@"/eta/%@/%@", vehicleId, stopId]]
                                    parameters:nil
                                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         NSLog(@"shuttleETA operation: %@", operation);
                                         [self successDirectionHandlerResponse:responseObject callback:callback];
                                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         if (callback) {
                                           callback(error, nil);
                                         }
                                       }];
}

- (AFHTTPRequestOperation *)routesCallback:(void (^)(NSError *, NSArray *))callback {
  return [self.httpRequestOperationManager GET:[self.baseURLString stringByAppendingString:@"/region/0/routes"]
                                    parameters:nil
                                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         NSLog(@"routesCallBack operation: %@", operation);
                                         if (callback) {
                                           callback(nil, responseObject);
                                         }
                                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         if (callback) {
                                           callback(error, nil);
                                         }
                                       }];
}

- (AFHTTPRequestOperation *)stopsForRoute:(NSNumber *)routeId
                                 callback:(void (^)(NSError *, NSArray *))callback {
  return [self.httpRequestOperationManager GET:[self.baseURLString stringByAppendingString:@"/routes/stops"]
                                    parameters:nil
                                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         NSLog(@"stopsForRoute opertaion: %@", operation);
                                         if (callback) {
                                           NSArray *routes = responseObject;
                                           NSArray *patterns;
                                           for (NSDictionary *route in routes) {
                                             if ([[route objectForKey:@"ID"] integerValue] == routeId.integerValue) {
                                               patterns = [route objectForKey:@"Patterns"];
                                             }
                                           };
                                           callback(nil, patterns);
                                         }
                                       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog(@"%@", operation);
                                         if (callback) {
                                           callback(error, nil);
                                         }
                                       }];
}

- (void)successDirectionHandlerResponse:(id)response
                               callback:(void (^)(NSError*, SIDirection *)) callback {
  if (callback) {
    SIDirection *direction = [[SIDirection alloc] init];
    direction.time = [(NSNumber *)[(NSArray *)[(NSDictionary *)response objectForKey:@"time"] objectAtIndex:1] intValue];
    direction.distance = [(NSString *)[(NSArray *)[(NSDictionary *)response objectForKey:@"distance"] objectAtIndex:1] doubleValue];
    callback(nil, direction);
  }
}

- (PMKPromise *)routesStops {
  return [self.httpRequestOperationManager GET:[self.baseURLString stringByAppendingString:@"/routes/stops"] parameters:nil];
}

@end
