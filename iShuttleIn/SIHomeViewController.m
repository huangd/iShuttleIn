//
//  SIHomeViewController.m
//  iShuttleIn
//
//  Created by Di Huang on 5/21/14.
//
//

#import <CoreLocation/CoreLocation.h>
#import "RNFrostedSidebar.h"

#import "SIHomeViewController.h"
#import "SIGeoLocation.h"
#import "SIDirection.h"
#import "SIShuttleInAPIClient.h"
#import "SIRouteTableViewController.h"
#import "SIStopTableViewController.h"


@interface SIHomeViewController () <CLLocationManagerDelegate, RNFrostedSidebarDelegate>

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *shuttleTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *shuttleDistanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *routeLabel;
@property (weak, nonatomic) IBOutlet UILabel *stopLabel;

@property (nonatomic) CLLocationManager *locationManager;

@property (nonatomic) SIGeoLocation *newarkShuttleStop;
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
    // Move at least 10 meters before update current location
//    self.locationManager.distanceFilter = 10;
    [self.locationManager startUpdatingLocation];
    self.shuttleInAPIClient = [[SIShuttleInAPIClient alloc] init];
    //Newark & Cedar Stop
    self.newarkShuttleStop = [[SIGeoLocation alloc] initWithLat:[NSNumber numberWithDouble:37.548981521142] lng:[NSNumber numberWithDouble:-122.043736875057]];
    //Get ETA
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(shuttleETA) userInfo:nil repeats:YES];
    
}

- (IBAction)tapBurger:(UIBarButtonItem *)sender {
    NSArray *images = @[
                        [UIImage imageNamed:@"gear"],
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
    self.routeLabel.text = [self.routeTableViewController.route objectForKey:@"ShortName"];
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
                    [self.navigationController pushViewController:self.routeTableViewController animated:NO];
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
                    [self.navigationController pushViewController:self.stopTableViewController animated:NO];
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
    self.routeLabel.text = [self.routeTableViewController.route objectForKey:@"ShortName"];
    self.stopLabel.text = [self.stopTableViewController.stop objectForKey:@"Name"];
    [self updateDirectionFrom:currentLocation to:self.shuttleStop];
}
@end
