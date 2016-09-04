//
//  TescoNetworkLibraryTests.m
//  TescoNetworkLibraryTests
//
//  Created by Nalin Chhajer on 04/09/16.
//  Copyright © 2016 Tesco. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <URLMock.h>
#import <AFNetworking.h>
#import "TescoNetworkManager.h"


@interface TescoNetworkLibraryTests : XCTestCase <TescoNetworkConfigurationDelegate>

@property (nonatomic, strong) TescoNetworkManager *networkManager;

@end

@implementation TescoNetworkLibraryTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [UMKMockURLProtocol enable];
    [UMKMockURLProtocol setVerificationEnabled:YES];
    
    // Setup
    TescoNetworkConfiguration *config = [TescoNetworkConfiguration defaultNetworkConfiguration];
    config.delegate = self;
    config.baseURL = @"http://localhost:3030";
    config.protocolClasses = @[ [UMKMockURLProtocol class] ];
    self.networkManager = [TescoNetworkManager sharedManager];
    [self.networkManager setNetworkConfiguration:config];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [UMKMockURLProtocol setVerificationEnabled:NO];
    [UMKMockURLProtocol disable];
    [self.networkManager clearLoginToken];
}

- (void)testLoginAuthentication {
    XCTestExpectation *expectation = [self expectationWithDescription:@"login auth"];
    [UMKMockURLProtocol expectMockHTTPGetRequestWithURL:[NSURL URLWithString:@"http://localhost:3030/login?token=abcd1234"] responseStatusCode:200 responseJSON:@{@"token":@"acadad2533ha92h"}];
    
    [self performLoginForUserWithToken:@"acadad2533ha92h" onCompleton:^{
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testSingleRequestWithSuccess {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testSingleRequestWithSuccess"];
    [UMKMockURLProtocol expectMockHTTPGetRequestWithURL:[NSURL URLWithString:@"http://localhost:3030/login?token=abcd1234"] responseStatusCode:200 responseJSON:@{@"token":@"123"}];
    [self performLoginForUserWithToken:@"123" onCompleton:^{
        
        [UMKMockURLProtocol expectMockHTTPGetRequestWithURL:[NSURL URLWithString:[@"http://localhost:3030" stringByAppendingString:@"/profile"]] responseStatusCode:200 responseJSON:@{@"success":@"true"}];
        
        [self performGetRequestForUrl:@"/profile" onCompleton:^{
            XCTAssertEqualObjects(self.networkManager.networkConfiguration.basicAuthorizationToken, @"123", @"Token is not set");
            [expectation fulfill];
        }];
        
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

- (void)testSingleRequestWithFailure {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testSingleRequestWithFailure"];
    [UMKMockURLProtocol expectMockHTTPGetRequestWithURL:[NSURL URLWithString:@"http://localhost:3030/login?token=abcd1234"] responseStatusCode:200 responseJSON:@{@"token":@"123"}];
    [self performLoginForUserWithToken:@"123" onCompleton:^{
        
        [UMKMockURLProtocol expectMockHTTPGetRequestWithURL:[NSURL URLWithString:[@"http://localhost:3030" stringByAppendingString:@"/profile"]] responseStatusCode:401 responseJSON:@{@"success":@"false"}];
        
        [UMKMockURLProtocol expectMockHTTPGetRequestWithURL:[NSURL URLWithString:@"http://localhost:3030/login?token=abcd1234"] responseStatusCode:200 responseJSON:@{@"token":@"1234"}];
        
        [UMKMockURLProtocol expectMockHTTPGetRequestWithURL:[NSURL URLWithString:[@"http://localhost:3030" stringByAppendingString:@"/profile"]] responseStatusCode:200 responseJSON:@{@"success":@"true"}];
        
        [self performGetRequestForUrl:@"/profile" onCompleton:^{
            XCTAssertEqualObjects(self.networkManager.networkConfiguration.basicAuthorizationToken, @"1234", @"Token is not set");
            [expectation fulfill];
        }];
        
    }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}


- (void)testExample {
    XCTestExpectation *expectation = [self expectationWithDescription:@"login auth"];
    [UMKMockURLProtocol expectMockHTTPGetRequestWithURL:[NSURL URLWithString:@"http://localhost:3030/login?token=abcd1234"] responseStatusCode:200 responseJSON:@{@"token":@"acadad2533ha92h"}];
    
    NSURL *URL = [NSURL URLWithString:@"http://localhost:3030/login?token=abcd1234"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    request.HTTPMethod = @"GET";
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.protocolClasses = @[ [UMKMockURLProtocol class] ];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            XCTAssertNil(error, @"Error is not nil");
            [expectation fulfill];
        } else {
            NSLog(@"%@ %@", response, responseObject);
            XCTAssertNotNil(responseObject, @"responseObject is nil");
            [expectation fulfill];
        }
    }];
    [dataTask resume];
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
    
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

#pragma mark - private methods

- (void)performLoginForUserWithToken:(NSString *)token onCompleton:(void (^)(void))completionHandler {
    [self.networkManager performLoginWithOnCompletionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            XCTAssertNil(error, @"Error is not nil");
            completionHandler();
        } else {
            XCTAssertNotNil(responseObject, @"responseObject is nil");
            XCTAssertEqualObjects(self.networkManager.networkConfiguration.basicAuthorizationToken, token, @"Token is not set");
            completionHandler();
        }
    }];
}

- (void)performGetRequestForUrl:(NSString *)urlString onCompleton:(void (^)(void))completionHandler {
    [self.networkManager performGet:urlString completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            XCTAssertNil(error, @"Error is not nil");
            completionHandler();
        } else {
            NSLog(@"%@ %@", response, responseObject);
            XCTAssertNotNil(responseObject, @"responseObject is nil");
            completionHandler();
        }
    }];
}

- (NSURLRequest *)getRequestForLoginCredential:(TescoNetworkConfiguration *)config {
    NSURL *URL = [NSURL URLWithString:@"http://localhost:3030/login?token=abcd1234"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    request.HTTPMethod = @"GET";
    return request;
}

- (NSString *)getAuthTokenFromLoginResponse:(NSURLResponse *)response  responseObject:(id)responseObject {
    NSDictionary *dict = (NSDictionary *)responseObject;
    return dict[@"token"];
}


@end
