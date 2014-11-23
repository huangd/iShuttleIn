//
//  SIRouteTableViewController.m
//  iShuttleIn
//
//  Created by Di Huang on 5/20/14.
//
//

#import "SIRouteTableViewController.h"
#import "SIShuttleInAPIClient.h"
#import "SIStopStore.h"

@interface SIRouteTableViewController ()

@property (nonatomic) NSArray *routes;
@property (nonatomic) SIShuttleInAPIClient *shuttleInAPIClient;

@end

@implementation SIRouteTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.navigationItem.hidesBackButton = NO;
    self.navigationItem.title = @"Routes";
    self.shuttleInAPIClient = [[SIShuttleInAPIClient alloc] init];
    
  }
  return self;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  if (self.routes == nil) {
    [self.shuttleInAPIClient routesCallback:^(NSError *error, NSArray *routes) {
      self.routes = routes;
      [self.tableView reloadData];
    }];
  }
}

#pragma mark
#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.routes count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellId = @"routeTableViewCellId";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:cellId];
  }
  cell.textLabel.text = [[self.routes objectAtIndex:indexPath.row] objectForKey:@"ShortName"];
  return cell;
}


#pragma mark
#pragma mark Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  SIStopStore *sharedStore = [SIStopStore sharedStore];
  sharedStore.route = [self.routes objectAtIndex:indexPath.row];
  [self.navigationController popViewControllerAnimated:YES];
}


@end
