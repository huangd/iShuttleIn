//
//  SILocationManager.m
//  iShuttleIn
//
//  Created by Di Huang on 11/30/14.
//
//

#import <CoreLocation/CoreLocation.h>
#import "SILocationManager.h"

@interface SILocationManager () <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager* locationManager;

@end

@implementation SILocationManager

#pragma mark
#pragma mark Singleton
- (instancetype)init {
  @throw [NSException exceptionWithName:@"Singleton"
                                 reason:@"use [SILocationManager sharedLocationManager]"
                               userInfo:nil];
}

- (SILocationManager *)initPrivate {
  self = [super init];
  if (self != nil) {
    // Setup CLLocationManager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
      [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    // Set notification center observer to start/stop locationManager
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopLocationManager:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startLocationManager:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
  }
  return self;
}

+ (SILocationManager *)sharedLocationManager {
  static SILocationManager *shared = nil;
  if (shared == nil) {
    shared = [[SILocationManager alloc] initPrivate];
  }
  return shared;
}

#pragma mark
#pragma mark CLLocationManager delegate
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
  NSLog(@"Error: %@", error);
  NSLog(@"Failed to get current location");
  self.lastLocation = nil;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  SIGeoLocation *currentLocation = [[SIGeoLocation alloc] initWithLat:@([[locations lastObject] coordinate].latitude)
                                                                  lng:@([[locations lastObject] coordinate].longitude)];
  self.lastLocation = currentLocation;
}

#pragma mark
#pragma mark start/stop locationManger
- (void)startLocationManager:(NSNotification *)note {
  [self.locationManager startUpdatingLocation];
}

- (void)stopLocationManager:(NSNotification *)note {
  [self.locationManager stopUpdatingLocation];
}


@end
