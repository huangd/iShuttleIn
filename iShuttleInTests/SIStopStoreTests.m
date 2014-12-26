//
//  SIStopStoreTests.m
//  iShuttleIn
//
//  Created by Di Huang on 12/26/14.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SIStopStore.h"

@interface SIStopStore (test)
- (NSMutableDictionary *)removeNull:(NSDictionary *)json;
@end

@interface SIStopStoreTests : XCTestCase

@end

@implementation SIStopStoreTests

- (void)setUp {
  [super setUp];
  // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
}

- (void)testRemoveNull {
  // This is an example of a functional test case.
  XCTAssert(YES, @"Pass");
  SIStopStore *stopStore = [SIStopStore sharedStore];
  NSDictionary *jsonWithNull = [[NSDictionary alloc] initWithObjectsAndKeys:
                                [NSNull null], @"nullObject",
                                nil];
  NSDictionary *jsonWithoutNull = [stopStore removeNull:jsonWithNull];
  XCTAssertEqual(0, jsonWithoutNull.count, @"count should be 0");
}


@end
