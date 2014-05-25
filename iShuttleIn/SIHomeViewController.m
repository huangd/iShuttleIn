//
//  SIHomeViewController.m
//  iShuttleIn
//
//  Created by Di Huang on 5/21/14.
//
//

#import <CoreLocation/CoreLocation.h>
#import <TTCounterLabel.h>
#import "RNFrostedSidebar.h"
#import "SICircle.h"
#import "SIStatusLine.h"

#import "SIHomeViewController.h"
#import "SIGeoLocation.h"
#import "SIDirection.h"
#import "SIShuttleInAPIClient.h"
#import "SIRouteTableViewController.h"
#import "SIStopTableViewController.h"


@interface SIHomeViewController () <CLLocationManagerDelegate, RNFrostedSidebarDelegate, TTCounterLabelDelegate>

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *shuttleTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *shuttleDistanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *stopLabel;
@property (weak, nonatomic) IBOutlet TTCounterLabel *counterLabel;

@property (nonatomic) SICircle *circle;
@property (nonatomic) SIStatusLine *statusLine;

@property (nonatomic) CLLocationManager *locationManager;

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
    }
    return self;
}

#pragma mark
#pragma mark ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Setup CLLocationManager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //    self.locationManager.distanceFilter = 10;
    [self.locationManager startUpdatingLocation];
    self.shuttleInAPIClient = [[SIShuttleInAPIClient alloc] init];
    //Get ETA
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(shuttleETA) userInfo:nil repeats:YES];
    
    [self setupCounterLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupCircle];
    [self setupStatusLine];
}

- (IBAction)tapBurger:(UIBarButtonItem *)sender {
    NSArray *images = @[
                        [UIImage imageNamed:@"globe"],
                        [UIImage imageNamed:@"profile"],
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
                                      self.timeLabel.text = [NSString stringWithFormat:@"%d minutes", direction.time/60];
                                      self.distanceLabel.text = [NSString stringWithFormat:@"%g miles", direction.distance];
                                  }];
}

- (void)shuttleETA {
    self.shuttleStop = [[SIGeoLocation alloc] initWithLat:[self.stopTableViewController.stop objectForKey:@"Latitude"]
                                                      lng:[self.stopTableViewController.stop objectForKey:@"Longitude"]];
    self.navigationItem.title = [self.routeTableViewController.route objectForKey:@"ShortName"];
    self.stopLabel.text = [self.stopTableViewController.stop objectForKey:@"Name"];
    
    [self.shuttleInAPIClient shuttleETA:self.routeTableViewController.vehicleId
                                     to:self.shuttleStop
                               callback:^(NSError *error, SIDirection *direction) {
                                   self.shuttleTimeLabel.text = [NSString stringWithFormat:@"%d minutes", direction.time/60];
                                   self.shuttleDistanceLabel.text = [NSString stringWithFormat:@"%g miles", direction.distance];
                               }];
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
                    self.stopTableViewController.routeId = self.routeTableViewController.routeId;
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
#pragma mark CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error);
    NSLog(@"Failed to get current location");
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    SIGeoLocation *currentLocation = [[SIGeoLocation alloc] initWithLat:@([[locations lastObject] coordinate].latitude)
                                                                    lng:@([[locations lastObject] coordinate].longitude)];
    self.shuttleStop = [[SIGeoLocation alloc] initWithLat:[self.stopTableViewController.stop objectForKey:@"Latitude"]
                                                      lng:[self.stopTableViewController.stop objectForKey:@"Longitude"]];
    self.navigationItem.title = [self.routeTableViewController.route objectForKey:@"ShortName"];
    self.stopLabel.text = [self.stopTableViewController.stop objectForKey:@"Name"];
    [self updateDirectionFrom:currentLocation to:self.shuttleStop];
}

#pragma mark
#pragma mark TTCounterLabel
- (void)setupCounterLabel {
    CGFloat numberFont = 40;
    CGFloat letterFont = 15;
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
    [self.counterLabel setStartValue:60000*10];
    [self.counterLabel start];
}

#pragma mark
#pragma mark SICircle
- (void)setupCircle {
    float radius = 80;
    CGRect counterLabelFrame = self.counterLabel.frame;
    CGPoint counterLabelCenterPoint = CGPointMake(counterLabelFrame.size.width/2+counterLabelFrame.origin.x,
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
    CGFloat lineLength = 280;
    CGFloat lineWidth = 15;
    self.statusLine = [[SIStatusLine alloc] initWithPosition:CGPointMake(self.view.frame.size.width/2 - lineLength/2,
                                                                         self.view.frame.size.height - 100)
                                                   lineWidth:lineWidth
                                                  lineLength:lineLength
                                             lineStrokeColor:[UIColor lightGrayColor]];
    [self.view addSubview:self.statusLine];
}
@end
