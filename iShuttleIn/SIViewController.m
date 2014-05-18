//
//  SIViewController.m
//  iShuttleIn
//
//  Created by Di Huang on 5/16/14.
//
//

#import "SIViewController.h"
#import "SIGeoLocation.h"
#import "SIDirection.h"
#import "SIShuttleInAPIClient.h"

// A class extension
@interface SIViewController ()

@property (weak, nonatomic) IBOutlet UIButton *shuttleInButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@property (nonatomic) SIGeoLocation *newarkShuttleStop;
@property (nonatomic) SIShuttleInAPIClient *shuttleInAPIClient;

@end

@implementation SIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.shuttleInAPIClient = [[SIShuttleInAPIClient alloc] init];
    //Newark & Cedar Stop
    self.newarkShuttleStop = [[SIGeoLocation alloc] initWithLat:37.548981521142 lng:-122.043736875057];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getDirection:(id)sender {
    SIGeoLocation *from = [[SIGeoLocation alloc] initWithLat:37.423310041785 lng:-122.071932256222];
    SIGeoLocation *to = self.newarkShuttleStop;
    [self.shuttleInAPIClient directionFrom:from
                                        to:to
                                  callback: ^(NSError *error, SIDirection *direction){
                                      self.timeLabel.text = [NSString stringWithFormat:@"%d minutes", direction.time/60];
                                      self.distanceLabel.text = [NSString stringWithFormat:@"%g miles", direction.distance];
                                  }];
}

@end
