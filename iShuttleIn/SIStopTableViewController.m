//
//  SIStopTableViewController.m
//  iShuttleIn
//
//  Created by Di Huang on 5/24/14.
//
//

#import "SIStopTableViewController.h"
#import "RNFrostedSidebar.h"
#import "SIShuttleInAPIClient.h"

@interface SIStopTableViewController () <RNFrostedSidebarDelegate>

@property (nonatomic) NSArray *stops;
@property (nonatomic) SIShuttleInAPIClient *shuttleInAPIClient;


@end

@implementation SIStopTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.hidesBackButton = NO;
        self.navigationItem.title = @"Stops";
        self.shuttleInAPIClient = [[SIShuttleInAPIClient alloc] init];
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.shuttleInAPIClient stopsForRoute:self.routeId
                                  callback:^(NSError *error, NSArray *stops) {
                                      self.stops = stops;
                                      [self.tableView reloadData];
                                      NSLog(@"Callback called with routes: %@", stops);
                                  }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.stops.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"stopTableViewCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:cellId];
    }
    cell.textLabel.text = [self trimStopName:[[self.stops objectAtIndex:indexPath.row] objectForKey:@"Name"]] ;
    return cell;
}

- (NSString *)trimStopName:(NSString *)name {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\(.*\\)"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    return [regex stringByReplacingMatchesInString:name
                                           options:0
                                             range:NSMakeRange(0, [name length])
                                      withTemplate:@""];
}

#pragma mark
#pragma mark Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.stop = [self.stops objectAtIndex:indexPath.row];
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)stopName {
    if (self.stop != nil) {
        return [self trimStopName:[self.stop objectForKey:@"Name"]];
    }
    return nil;
}
@end
