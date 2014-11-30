//
//  SIHomeViewController.m
//  iShuttleIn
//
//  Created by Di Huang on 5/21/14.
//
//

#import <CoreLocation/CoreLocation.h>
#import <TTCounterLabel.h>
#import "SIAppDelegate.h"
#import "RNFrostedSidebar.h"
#import "SICircle.h"
#import "SIStatusLine.h"

#import "SIHomeViewController.h"
#import "SIGeoLocation.h"
#import "SIDirection.h"
#import "SIShuttleInAPIClient.h"
#import "SIRouteTableViewController.h"
#import "SIStopTableViewController.h"
#import "SIStopStore.h"
#import "SILocationManager.h"


@interface SIHomeViewController () <RNFrostedSidebarDelegate, TTCounterLabelDelegate>

@property (nonatomic) TTCounterLabel *timeLabel;
@property (nonatomic) UILabel *distanceLabel;
@property (nonatomic) TTCounterLabel *shuttleTimeLabel;
@property (nonatomic) UILabel *shuttleDistanceLabel;
@property (nonatomic) UILabel *stopLabel;
@property (nonatomic) TTCounterLabel *counterLabel;

@property (nonatomic) SICircle *circle;
@property (nonatomic) SIStatusLine *statusLine;
@property (nonatomic) SIDirection *youDirection;
@property (nonatomic) SIDirection *shuttleDirection;

@property (nonatomic) SILocationManager *locationManager;

@property (nonatomic) SIGeoLocation *shuttleStop;
@property (nonatomic) SIShuttleInAPIClient *shuttleInAPIClient;

@property (nonatomic) SIRouteTableViewController *routeTableViewController;
@property (nonatomic) SIStopTableViewController *stopTableViewController;

@end

@implementation SIHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    UIBarButtonItem *burger = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"burger.png"]
                                                               style:UIBarButtonItemStylePlain
                                                              target:self action:@selector(tapBurger:)];
    self.navigationItem.leftBarButtonItem = burger;
    self.shuttleInAPIClient = [SIShuttleInAPIClient sharedShuttleInAPIClient];
  }
  return self;
}

#pragma mark
#pragma mark ViewController
- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Setup and configure view objects
  // Setup order matters
  [self setupCounterLabel];
  [self setupCircle];
  [self setupStatusLine];
  [self setupTimeLabel];
  [self setupDistanceLabel];
  [self setupStopLabel];
  
  // Setup SILocationManager
  self.locationManager = [SILocationManager sharedLocationManager];

  // Get ETA
  [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(updateETA) userInfo:nil repeats:YES];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self updateETA];
  [self setNavigationItemTitle];
  [self setStopName];
}

- (IBAction)tapBurger:(UIBarButtonItem *)sender {
  NSArray *images = @[
                      [UIImage imageNamed:@"bus"],
                      [UIImage imageNamed:@"marker"],
                      ];
  
  RNFrostedSidebar *callout = [[RNFrostedSidebar alloc] initWithImages:images];
  callout.delegate = self;
  [callout show];
}

#pragma mark
#pragma mark iShuttle
- (void)updateDirectionFrom:(SIGeoLocation *)from
                         to:(SIGeoLocation *)to {
  [self.shuttleInAPIClient directionFrom:from
                                      to:to
                                callback: ^(NSError *error, SIDirection *direction) {
                                  if (error == nil) {
                                    self.youDirection = direction;
                                    [self.timeLabel setStartValue:direction.time*1000];
                                    self.distanceLabel.text = [NSString stringWithFormat:@"%.1f", direction.distance];
                                  } else {
                                    // Clear the current data
                                    // This could happen when user changes route
                                    self.youDirection = nil;
                                    [self.timeLabel setStartValue:0];
                                    self.distanceLabel.text = nil;
                                  }
                                }];
}

#pragma mark
#pragma mark ETA
- (void)shuttleETA {
  SIStopStore *sharedStore = [SIStopStore sharedStore];
  self.shuttleStop = [[SIGeoLocation alloc] initWithLat:[sharedStore.stop objectForKey:@"Latitude"]
                                                    lng:[sharedStore.stop objectForKey:@"Longitude"]];
  [self setNavigationItemTitle];
  [self setStopName];
  NSNumber *vehicleId = [[SIStopStore sharedStore].route objectForKey:@"ID"];
  
  [self.shuttleInAPIClient shuttleETA:vehicleId
                                   to:self.shuttleStop
                             callback:^(NSError *error, SIDirection *direction) {
                               if (error == nil) {
                                 self.shuttleDirection = direction;
                                 [self.shuttleTimeLabel setStartValue:direction.time*1000];
                                 self.shuttleDistanceLabel.text = [NSString stringWithFormat:@"%.1f", direction.distance];
                                 //Update counterLabel
                                 int timeDiff = self.shuttleDirection.time - self.youDirection.time;
                                 if (timeDiff > 0) {
                                   [self.counterLabel stop];
                                   self.counterLabel.startValue = timeDiff*1000;
                                   [self.counterLabel start];
                                 } else {
                                   //TODO: send out an warning as it is possible not to catch the shuttle
                                   [self.counterLabel stop];
                                   self.counterLabel.startValue = 0;
                                 }
                               } else {
                                 // Clear the current data
                                 self.shuttleDirection = nil;
                                 [self.shuttleTimeLabel setStartValue:0];
                                 self.shuttleDistanceLabel.text = nil;
                                 [self.counterLabel stop];
                                 self.counterLabel.startValue = 0;
                               }
                             }];
}

- (void)youETA {
  SIGeoLocation *currentLocation = self.locationManager.lastLocation;
  NSDictionary *stop = [SIStopStore sharedStore].stop;
  self.shuttleStop = [[SIGeoLocation alloc] initWithLat:[stop objectForKey:@"Latitude"]
                                                    lng:[stop objectForKey:@"Longitude"]];
  [self setStopName];
  [self updateDirectionFrom:currentLocation to:self.shuttleStop];
}

- (void)updateETA {
  [self shuttleETA];
  [self youETA];
}

#pragma mark
#pragma RNFrostedSidebarDelegate
-(void)sidebar:(RNFrostedSidebar *)sidebar didTapItemAtIndex:(NSUInteger)index {
  switch (index) {
    case 0: {
      [sidebar dismissAnimated:YES completion:^(BOOL finished) {
        if (finished) {
          if (self.routeTableViewController == nil) {
            self.routeTableViewController = [[SIRouteTableViewController alloc] init];
          }
          [self.navigationController pushViewController:self.routeTableViewController animated:YES];
        }
      }];
      break;
    }
    case 1: {
      [sidebar dismissAnimated:YES completion:^(BOOL finished) {
        if (finished) {
          if (self.stopTableViewController == nil) {
            self.stopTableViewController = [[SIStopTableViewController alloc] init];
          }
          [self.navigationController pushViewController:self.stopTableViewController animated:YES];
        }
      }];
      break;
    }
    default: {
      [sidebar dismissAnimated:YES];
      break;
    }
  }
}


#pragma mark
#pragma mark TTCounterLabel
- (void)setupCounterLabel {
  CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
  CGFloat screenHeight = UIScreen.mainScreen.bounds.size.height;
  // Scale frameWidth and frameHeight based on the width
  // of the device. 320 is the default width for iPhone4
  CGFloat frameWidth = 280*(screenWidth/320);
  CGFloat frameHeight = 212*(screenWidth/320);
  CGFloat frameX = (screenWidth - frameWidth) / 2;
  CGFloat frameY = (screenHeight - frameHeight) * 0.35;
  self.counterLabel = [[TTCounterLabel alloc] initWithFrame:CGRectMake(frameX, frameY, frameWidth, frameHeight)];
  [self.view addSubview:self.counterLabel];
  
  // Scale numberFont and letterFont based on the width
  // of the device. 320 is the default width for iPhone4
  CGFloat numberFont = 65*(screenWidth/320);
  CGFloat letterFont = 25*(screenWidth/320);
  [self.counterLabel setBoldFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:numberFont]];
  [self.counterLabel setRegularFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:numberFont]];
  // The font property of the label is used as the font for H,M,S and MS
  [self.counterLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:letterFont]];
  // Default label properties
  self.counterLabel.textColor = [UIColor darkGrayColor];
  // After making any changes we need to call update appearance
  [self.counterLabel updateApperance];
  
  self.counterLabel.countDirection = kCountDirectionDown;
  self.counterLabel.displayMode = kDisplayModeSeconds;
}

- (void)setupTimeLabel {
  CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
  CGFloat labelWidth = 80;
  CGFloat labelHeight = 30;
  self.timeLabel = [[TTCounterLabel alloc] initWithFrame:CGRectMake(screenWidth/4-labelWidth/2,
                                                                    self.statusLine.frame.origin.y+labelHeight,
                                                                    labelWidth, labelHeight)];
  [self.view addSubview:self.timeLabel];
  self.shuttleTimeLabel = [[TTCounterLabel alloc] initWithFrame:CGRectMake(screenWidth*0.75-labelWidth/2,
                                                                           self.statusLine.frame.origin.y+labelHeight,
                                                                           labelWidth, labelHeight)];
  [self.view addSubview:self.shuttleTimeLabel];
  
  CGFloat numberFont = 20;
  CGFloat letterFont = 12;
  [self.timeLabel setBoldFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:numberFont]];
  [self.timeLabel setRegularFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:numberFont]];
  // The font property of the label is used as the font for H,M,S and MS
  [self.timeLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:letterFont]];
  // Default label properties
  self.timeLabel.textColor = [UIColor darkGrayColor];
  // After making any changes we need to call update appearance
  [self.timeLabel updateApperance];
  self.timeLabel.countDirection = kCountDirectionDown;
  self.timeLabel.displayMode = kDisplayModeSeconds;
  
  [self.shuttleTimeLabel setBoldFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:numberFont]];
  [self.shuttleTimeLabel setRegularFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:numberFont]];
  // The font property of the label is used as the font for H,M,S and MS
  [self.shuttleTimeLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:letterFont]];
  // Default label properties
  self.shuttleTimeLabel.textColor = [UIColor darkGrayColor];
  // After making any changes we need to call update appearance
  [self.shuttleTimeLabel updateApperance];
  self.shuttleTimeLabel.countDirection = kCountDirectionDown;
  self.shuttleTimeLabel.displayMode = kDisplayModeSeconds;
  
}

- (void)setupDistanceLabel {
  CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
  CGFloat labelWidth = 80;
  CGFloat labelHeight = 30;
  CGFloat fontSize = 18;
  // Setup distanceLabel
  self.distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/4-labelWidth/2,
                                                                 self.statusLine.frame.origin.y,
                                                                 labelWidth, labelHeight)];
  self.distanceLabel.textColor = [UIColor darkGrayColor];
  self.distanceLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:fontSize];
  self.distanceLabel.textAlignment = NSTextAlignmentCenter;
  [self.view addSubview:self.distanceLabel];
  
  // Setup shuttleDistanceLabel
  self.shuttleDistanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth*0.75-labelWidth/2,
                                                                        self.statusLine.frame.origin.y,
                                                                        labelWidth, labelHeight)];
  self.shuttleDistanceLabel.textColor = [UIColor darkGrayColor];
  self.shuttleDistanceLabel.textAlignment = NSTextAlignmentCenter;
  [self.view addSubview:self.shuttleDistanceLabel];
}

- (void)setupStopLabel {
  CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
  CGFloat screenHeigth = UIScreen.mainScreen.bounds.size.height;
  CGFloat labelWidth = screenWidth-40;
  CGFloat labelHeight = screenHeigth/27;
  self.stopLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/2-labelWidth/2,
                                                                 screenHeigth*0.75,
                                                                 labelWidth, labelHeight)];
  self.stopLabel.textColor = [UIColor darkGrayColor];
  self.stopLabel.textAlignment = NSTextAlignmentCenter;
  [self.view addSubview:self.stopLabel];
  
}


#pragma mark
#pragma mark SICircle
- (void)setupCircle {
  CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
  CGFloat radius = screenWidth / 2.5;
  CGRect counterLabelFrame = self.counterLabel.frame;
  CGPoint counterLabelCenterPoint = CGPointMake(screenWidth / 2,
                                                counterLabelFrame.size.height/2+counterLabelFrame.origin.y);
  self.circle = [[SICircle alloc] initWithPosition:CGPointMake(counterLabelCenterPoint.x-radius,
                                                               counterLabelCenterPoint.y-radius+5)
                                            radius:radius
                                    internalRadius:radius-5
                                 circleStrokeColor:[UIColor lightGrayColor]];
  [self.view addSubview:self.circle];
  
}

#pragma mark
#pragma mark SIStatusLine
- (void)setupStatusLine {
  CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
  CGFloat screenHeigth = UIScreen.mainScreen.bounds.size.height;
  CGFloat lineLength = screenWidth-20;
  CGFloat lineWidth = 8;
  self.statusLine = [[SIStatusLine alloc] initWithPosition:CGPointMake(screenWidth/2 - lineLength/2,
                                                                       screenHeigth * 0.85)
                                                 lineWidth:lineWidth
                                                lineLength:lineLength
                                                  iconSize:25
                                           lineStrokeColor:[UIColor lightGrayColor]];
  [self.view addSubview:self.statusLine];
}

#pragma mark
#pragma mark Set route and stop label
- (void)setNavigationItemTitle {
  NSDictionary *route = [[SIStopStore sharedStore] route];
  if (route == nil) {
    self.navigationItem.title = @"Choose a route";
  } else {
    self.navigationItem.title = [route objectForKey:@"ShortName"];
  }
}

- (void)setStopName {
  NSString *stopName = [SIStopTableViewController stopName];
  if (stopName == nil) {
    self.stopLabel.text = @"Choose a stop";
  } else {
    self.stopLabel.text = stopName;
  }
}

@end
