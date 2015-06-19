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
#import <PromiseKit.h>

@interface SIStopStore ()
@property (nonatomic) SIShuttleInAPIClient *shuttleInAPIClient;
@property (nonatomic) SILocationManager *locationManager;
@property (nonatomic) NSArray *routesStops;
@end

@implementation SIStopStore

NSDictionary *_stop;
NSDictionary *_route;
NSMutableDictionary *_selectedStops;
NSString *ROUTE_FILE_NAME = @"route.plist";
NSString *SELECTED_STOPS_FILE_NAME = @"selectedStops.plist";

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
  [self updateRoutesStops:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(updateRoutesStops:)
                                               name:UIApplicationWillEnterForegroundNotification
                                             object:nil];
  return self;
}

#pragma mark
#pragma mark Stop
- (NSDictionary *)stop {
  if (!_stop) {
    [self updateStop];
  }
  return _stop;
}

- (void)updateStop {
  _stop = nil;
  NSNumber *routeId = [self.route objectForKey:@"ID"];
  for (NSDictionary *route in self.routesStops) {
    if ([[route valueForKey:@"ID"] longValue] == [routeId longValue]) {
      NSArray *patterns = [route objectForKey:@"Patterns"];
      for (int i=0; i<patterns.count; i++) {
        NSDictionary *pattern = [patterns objectAtIndex:i];
        NSDictionary *currentLocations = [pattern objectForKey:@"currentLocations"];
        if (currentLocations.count > 0) {
          NSArray *stops = [pattern objectForKey:@"stops"];
          NSNumber *stopIndex = [self.selectedStops valueForKey:[@(i) stringValue]];
          if (stopIndex != nil) {
            _stop = [stops objectAtIndex:stopIndex.integerValue];
          }
        }
      };
    };
  };
}

#pragma mark
#pragma mark SelectedStops
- (NSDictionary *)selectedStops {
  if (!_selectedStops) {
    _selectedStops= [[NSMutableDictionary alloc] initWithContentsOfFile:[self filePath:SELECTED_STOPS_FILE_NAME]];
  }
  if (!_selectedStops) {
    _selectedStops = [[NSMutableDictionary alloc] init];
  }
  NSDictionary *selectedStopsForThisRoute = [_selectedStops valueForKey:[[_route valueForKey:@"ID"] stringValue]];
  if (!selectedStopsForThisRoute) {
    selectedStopsForThisRoute = [[NSDictionary alloc] init];
    NSString *routeId = [[_route valueForKey:@"ID"] stringValue];
    if (routeId != nil) {
      [_selectedStops setValue:selectedStopsForThisRoute forKey:routeId];
    }
  }
  return selectedStopsForThisRoute;
}

- (void)setSelectedStops:(NSDictionary *)selectedStopsForThisRoute {
  [_selectedStops setValue:selectedStopsForThisRoute forKey:[[_route valueForKey:@"ID"] stringValue]];
  BOOL hasSaved = [_selectedStops writeToFile:[self filePath:SELECTED_STOPS_FILE_NAME] atomically:YES];
  if (!hasSaved) {
    NSLog(@"Failed to save selectedStops %@", selectedStopsForThisRoute);
  }
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
  BOOL hasSaved = [_route writeToFile:[self filePath:ROUTE_FILE_NAME] atomically:YES];
  if (!hasSaved) {
    NSLog(@"Failed to save route %@", _route);
  }
  [self updateStop];
}

#pragma mark
#pragma mark SelectedStops

#pragma mark
#pragma mark Helper
- (NSString *)filePath:(NSString *)fileName {
  NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentDirectory = [documentDirectories firstObject];
  return [documentDirectory stringByAppendingPathComponent:fileName];
}

- (NSMutableDictionary *)removeNull:(NSDictionary *)json {
  NSMutableDictionary *newJson = [[NSMutableDictionary alloc] init];
  for (NSString *key in json.keyEnumerator) {
    if (![[json objectForKey:key] isKindOfClass:[NSNull class]]) {
      [newJson setValue:[json objectForKey:key] forKey:key];
    }
  };
  return newJson;
}

- (void)updateRoutesStops:(NSNotification *)note {
  [self.shuttleInAPIClient routesStops].then(^(id responseObject){
    self.routesStops = responseObject;
    [self updateStop];
  }).catch(^(NSError *error){
    NSLog(@"Error: %@", error.localizedDescription);
  });
}
@end
