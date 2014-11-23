//
//  SIStopStore.m
//  iShuttleIn
//
//  Created by Di Huang on 11/22/14.
//
//

#import "SIStopStore.h"

@implementation SIStopStore

NSDictionary *_stop;
NSDictionary *_route;
NSString *AM_STOP_FILE_NAME = @"amStop.plist";
NSString *PM_STOP_FILE_NAME = @"pmStop.plist";
NSString *ROUTE_FILE_NAME = @"route.plist";

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
  return self;
}

- (NSDictionary *)stop {
  if (!_stop) {
    NSInteger currentHour = [self getCurrentHour];
    if (currentHour <= 12) {
      _stop = [[NSDictionary alloc] initWithContentsOfFile:[SIStopStore filePath:AM_STOP_FILE_NAME]];
    } else {
      _stop = [[NSDictionary alloc] initWithContentsOfFile:[SIStopStore filePath:PM_STOP_FILE_NAME]];
    }
  }
  return _stop;
}

- (void)setStop:(NSDictionary *)stop {
  _stop = [self removeNull:stop];
  NSInteger currentHour = [self getCurrentHour];
  if (currentHour <= 12) {
    [_stop writeToFile:[SIStopStore filePath:AM_STOP_FILE_NAME] atomically:YES];
  } else {
    [_stop writeToFile:[SIStopStore filePath:PM_STOP_FILE_NAME] atomically:YES];
  }
  
}

- (NSDictionary *)route {
  if (!_route) {
    _route = [[NSDictionary alloc] initWithContentsOfFile:[SIStopStore filePath:ROUTE_FILE_NAME]];
  }
  return _route;
}

- (void)setRoute:(NSDictionary *)route {
  _route = [self removeNull:route];
  [_route writeToFile:[SIStopStore filePath:ROUTE_FILE_NAME] atomically:YES];
  self.stop = [[NSDictionary alloc] init];
}

+ (NSString *)filePath:(NSString *)fileName {
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

- (NSInteger)getCurrentHour {
  NSDate *date = [NSDate date];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  dateFormatter.dateFormat = @"H";
  NSString *hourString = [dateFormatter stringFromDate:date];
  NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
  [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
  NSNumber *hour = [numberFormatter numberFromString:hourString];
  return hour.integerValue;
}

@end
