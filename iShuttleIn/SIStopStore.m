//
//  SIStopStore.m
//  iShuttleIn
//
//  Created by Di Huang on 11/22/14.
//
//

#import "SIStopStore.h"
#import "SIShuttleInAPIClient.h"
#import "SILocationManager.h"
#import "SIDirection.h"

@interface SIStopStore ()
@property (nonatomic) SIShuttleInAPIClient *shuttleInAPIClient;
@property (nonatomic) NSMutableArray *stops;
@property (nonatomic) SILocationManager *locationManager;
@end

@implementation SIStopStore

NSDictionary *_stop;
NSDictionary *_route;
NSString *STOPS_FILE_NAME = @"stops.plist";
NSString *ROUTE_FILE_NAME = @"route.plist";

#pragma mark
#pragma mark Singleton
+ (instancetype)sharedStore {
  static SIStopStore *sharedStore = nil;
  
  if (!sharedStore) {
    sharedStore = [[self alloc] initPrivate];
  }
  
  return sharedStore;
}

- (instancetype)init {
  @throw [NSException exceptionWithName:@"Singleton"
                                 reason:@"Use +[SIStopStore sharedStore]"
                               userInfo:nil];
}

//Here is the real(secret) initializer
- (instancetype)initPrivate {
  self = [super init];
  self.shuttleInAPIClient = [SIShuttleInAPIClient sharedShuttleInAPIClient];
  self.locationManager = [SILocationManager sharedLocationManager];
  
  // Set notification center observer to update/save stops
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(saveStops:)
                                               name:UIApplicationWillResignActiveNotification
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(updateStop:)
                                               name:UIApplicationWillEnterForegroundNotification
                                             object:nil];
  return self;
}

#pragma mark
#pragma mark Stop
- (NSDictionary *)stop {
  if (!_stop) {
    self.stops = [[NSMutableArray alloc] initWithContentsOfFile:[self filePath:STOPS_FILE_NAME]];
    if (self.stops == nil) {
      self.stops = [[NSMutableArray alloc] initWithCapacity:3];
    }
    _stop = self.stops.firstObject;
  }
  // Update stop distance everytime getStop is called
  [self updateStopDistance];
  return _stop;
}

- (void)setStop:(NSDictionary *)stop {
  _stop = [self removeNull:stop];
  [_stop setValue:0 forKey:@"distance"];
  [self.stops addObject:_stop];
  NSUInteger maxSavedStops = 3;
  if (self.stops.count == maxSavedStops) {
    [self.stops removeObjectAtIndex:0];
  }
  
  [self.stops writeToFile:[self filePath:STOPS_FILE_NAME] atomically:YES];
}

- (void)resetStops {
  _stop = nil;
  [self.stops removeAllObjects];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  [fileManager removeItemAtPath:[self filePath:STOPS_FILE_NAME] error:nil];
}

- (void)updateStopDistance {
  SIGeoLocation *lastLocation = self.locationManager.lastLocation;
  for (NSDictionary *stop in self.stops) {
    SIGeoLocation *stopLocation = [[SIGeoLocation alloc] initWithLat:[stop objectForKey:@"Latitude"]
                                                                 lng:[stop objectForKey:@"Longitude"]];
    [self.shuttleInAPIClient directionFrom:lastLocation
                                        to:stopLocation
                                  callback: ^(NSError *error, SIDirection *direction) {
                                    if (error == nil) {
                                      NSNumber *distance = [[NSNumber alloc] initWithDouble:direction.distance];
                                      [stop setValue:distance forKey:@"distance"];
                                    } else {
                                      // Set MAX_INT to indicate an error
                                      NSNumber *distance = [[NSNumber alloc] initWithInt: INT_MAX];
                                      [stop setValue:distance forKey:@"distance"];
                                    }
                                  }];
    
  };
}

#pragma mark
#pragma mark Route
- (NSDictionary *)route {
  if (!_route) {
    _route = [[NSDictionary alloc] initWithContentsOfFile:[self filePath:ROUTE_FILE_NAME]];
  }
  return _route;
}

- (void)setRoute:(NSDictionary *)route {
  _route = [self removeNull:route];
  [_route writeToFile:[self filePath:ROUTE_FILE_NAME] atomically:YES];
  [self resetStops];
}

#pragma mark
#pragma mark Helper
- (NSString *)filePath:(NSString *)fileName {
  NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentDirectory = [documentDirectories firstObject];
  return [documentDirectory stringByAppendingPathComponent:fileName];
}

- (NSDictionary *)removeNull:(NSDictionary *)json {
  NSDictionary *newJson = [[NSMutableDictionary alloc] init];
  for (NSString *key in json.keyEnumerator) {
    if (![[json objectForKey:key] isKindOfClass:[NSNull class]]) {
      [newJson setValue:[json objectForKey:key] forKey:key];
    }
  };
  return newJson;
}

#pragma mark
#pragma mark update stop based on currentLocation
- (void)saveStops:(NSNotification *)note {
  [self.stops sortUsingComparator:^(NSDictionary *stopOne, NSDictionary *stopTwo){
    NSNumber *distanceOne = [stopOne valueForKey:@"distance"];
    NSNumber *distanceTwo = [stopTwo valueForKey:@"distance"];
    if ( distanceOne.doubleValue <= distanceTwo.doubleValue) {
      return (NSComparisonResult)NSOrderedAscending;
    }
    return (NSComparisonResult)NSOrderedDescending;
  }];
  [self.stops writeToFile:[self filePath:STOPS_FILE_NAME] atomically:YES];
}

- (void)updateStop:(NSNotification *)note {
  self.stop = self.stops.firstObject;
}
@end
