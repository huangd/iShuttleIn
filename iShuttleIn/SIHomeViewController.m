//
//  SIHomeViewController.m
//  iShuttleIn
//
//  Created by Di Huang on 5/21/14.
//
//

#import <CoreLocation/CoreLocation.h>
#import <RNFrostedSidebar.h>

#import "SIHomeViewController.h"
#import "SIGeoLocation.h"
#import "SIDirection.h"
#import "SIShuttleInAPIClient.h"
#import "SIRouteTableViewController.h"


@interface SIHomeViewController () <CLLocationManagerDelegate, RNFrostedSidebarDelegate>

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *shuttleTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *shuttleDistanceLabel;

@property (nonatomic) CLLocationManager *locationManager;

@property (nonatomic) SIGeoLocation *newarkShuttleStop;
@property (nonatomic) SIShuttleInAPIClient *shuttleInAPIClient;

@end

@implementation SIHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark
#pragma mark ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Setup CLLocationManager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    // Move at least 10 meters before update current location
    self.locationManager.distanceFilter = 10;
    [self.locationManager startUpdatingLocation];
    self.shuttleInAPIClient = [[SIShuttleInAPIClient alloc] init];
    //Newark & Cedar Stop
    self.newarkShuttleStop = [[SIGeoLocation alloc] initWithLat:37.548981521142 lng:-122.043736875057];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark iShuttle
- (void)updateDirectionFrom:(SIGeoLocation *)from
                         to:(SIGeoLocation *)to {
    if (to == nil) {
        to = self.newarkShuttleStop;
    }
    [self.shuttleInAPIClient directionFrom:from
                                        to:to
                                  callback: ^(NSError *error, SIDirection *direction){
                                      self.timeLabel.text = [NSString stringWithFormat:@"%d minutes", direction.time/60];
                                      self.distanceLabel.text = [NSString stringWithFormat:@"%g miles", direction.distance];
                                  }];
}

- (void)shuttleETA {
    [self.shuttleInAPIClient shuttleETA:1583
                                     to:self.newarkShuttleStop
                               callback:^(NSError *error, SIDirection *direction){
                                   self.shuttleTimeLabel.text = [NSString stringWithFormat:@"%d minutes", direction.time/60];
                                   self.shuttleDistanceLabel.text = [NSString stringWithFormat:@"%g miles", direction.distance];
                               }];
}

#pragma mark
#pragma RNFrostedSidebarDelegate
-(void)sidebar:(RNFrostedSidebar *)sidebar didTapItemAtIndex:(NSUInteger)index {
    if (index == 1) {
        UITableViewController *routeTableViewController = [[SIRouteTableViewController alloc] init];
        [self.navigationController pushViewController:routeTableViewController animated:YES];
    }
}

#pragma mark
#pragma mark CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error);
    NSLog(@"Failed to get current location");
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"Location: %@", [locations lastObject]);
    SIGeoLocation *currentLocation = [[SIGeoLocation alloc] initWithLat:[[locations lastObject] coordinate].latitude
                                                                    lng:[[locations lastObject] coordinate].longitude];
    [self updateDirectionFrom:currentLocation to:nil];
}
@end
