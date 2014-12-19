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
#import "SIStopStore.h"

@interface SIStopTableViewController () <RNFrostedSidebarDelegate>

@property (nonatomic) NSArray *patterns;
@property (nonatomic) SIShuttleInAPIClient *shuttleInAPIClient;
@property (nonatomic) NSMutableDictionary *selectedStops;


@end

@implementation SIStopTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.navigationItem.hidesBackButton = NO;
    self.navigationItem.title = @"Stops";
    self.shuttleInAPIClient = [SIShuttleInAPIClient sharedShuttleInAPIClient];
  }
  return self;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  NSNumber *routeId = [[SIStopStore sharedStore].route objectForKey:@"ID"];
  self.selectedStops = [[NSMutableDictionary alloc] initWithDictionary:[SIStopStore sharedStore].selectedStops];
  [self.shuttleInAPIClient stopsForRoute:routeId
                                callback:^(NSError *error, NSArray *patterns) {
                                  self.patterns = patterns;
                                  [self.tableView reloadData];
                                  NSLog(@"Callback called with routes: %@", self.patterns);
                                }];
}

+ (NSString *)trimStopName:(NSString *)name {
  if (name == nil) {
    return nil;
  }
  NSError *error = nil;
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\(.*\\)"
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:&error];
  return [regex stringByReplacingMatchesInString:name
                                         options:0
                                           range:NSMakeRange(0, [name length])
                                    withTemplate:@""];
}

+ (NSString *)stopName {
  NSDictionary *stop = [SIStopStore sharedStore].stop;
  if ( stop != nil) {
    return [self trimStopName:[stop objectForKey:@"Name"]];
  }
  return nil;
}

#pragma mark
#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return self.patterns.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSDictionary *pattern = [self.patterns objectAtIndex:section];
  return [(NSArray *)[pattern objectForKey:@"stops"] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellId = @"stopTableViewCellId";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:cellId];
  }
  
  NSDictionary *pattern = [self.patterns objectAtIndex:indexPath.section];
  NSArray *stops = [pattern objectForKey:@"stops"];
  NSDictionary *stop = [stops objectAtIndex:indexPath.row];
  cell.textLabel.text = [SIStopTableViewController trimStopName:[stop objectForKey:@"Name"]];
  if ([self.selectedStops valueForKey:[@(indexPath.section) stringValue]] != nil
      && [[self.selectedStops valueForKey:[@(indexPath.section) stringValue]] integerValue] == indexPath.row) {
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
  } else {
    cell.accessoryType = UITableViewCellAccessoryNone;
  }
  return cell;
}

#pragma mark
#pragma mark Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self.selectedStops setValue:@(indexPath.row)
                         forKey:[@(indexPath.section) stringValue]];
  [self.tableView reloadData];
  [SIStopStore sharedStore].selectedStops = self.selectedStops;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  NSDictionary *pattern = [self.patterns objectAtIndex:section];
  return [pattern objectForKey:@"Directionality"];
}

@end
