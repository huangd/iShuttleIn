//
//  SIAppDelegate.h
//  iShuttleIn
//
//  Created by Di Huang on 5/16/14.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface SIAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic) CLLocationManager *locationManager;

@end
