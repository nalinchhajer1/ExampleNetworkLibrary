//
//  TescoNetworkManager.m
//  TescoNetworkLibrary
//
//  Created by Nalin Chhajer on 04/09/16.
//  Copyright © 2016 Tesco. All rights reserved.
//

#import "TescoNetworkManager.h"
#import <AFNetworking.h>

@interface TescoNetworkManager ()

@property (nonatomic, strong) AFURLSessionManager *sessionManager;
@property (nonatomic, strong) NSMutableArray *reLoginQueue;
@property (nonatomic, assign) BOOL performingRelogin; // To batch continuous request

@end

@implementation TescoNetworkManager

+ (id)sharedManager {
    static TescoNetworkManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        self.reLoginQueue = [[NSMutableArray alloc] init];
        [self setNetworkConfiguration:nil];
    }
    return self;
}

- (void)clearLoginToken {
    self.networkConfiguration.basicAuthorizationToken = nil;
}

/**
 
 Example for Get request
 
 **/
- (void)performGet:(NSString *)urlString completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler {
    NSURL *URL = [self urlWithBaseURLForString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    request.HTTPMethod = @"GET";
    [self executeURLRequest:request completionHandler:completionHandler];
}



/***
 
 Supports testing this library
 
 ***/
- (void)setNetworkConfiguration:(TescoNetworkConfiguration *)networkConfiguration {
    _networkConfiguration = networkConfiguration;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.protocolClasses = networkConfiguration.protocolClasses;
    self.sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
}

/***
 
 Method for this class to learn on how to login, can be used in any ways. I have tried making it generic so GET/POST request login/ any url can be used.
 
 **/
- (void)performLoginWithOnCompletionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler {
    if (self.networkConfiguration) {
        NSURLRequest *request = [self.networkConfiguration.delegate getRequestForLoginCredential:self.networkConfiguration];
        NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            if (httpResponse.statusCode == 200) {
                NSString *token = [self.networkConfiguration.delegate getAuthTokenFromLoginResponse:response responseObject:responseObject];
                self.networkConfiguration.basicAuthorizationToken = token;
            }
            completionHandler(response, responseObject, error);
        }];
        [dataTask resume];
    }
    else {
        NSLog(@"Network configuration is not set. Please call [self setNetworkConfiguration:]");
        completionHandler(nil, nil, [NSError errorWithDomain:@"INVALID" code:500 userInfo:@{@"message":@"Tesco Network configuration is not set"}]);
    }
}

#pragma mark private methods

- (NSURL *)urlWithBaseURLForString:(NSString *)urlString {
    NSURL *relativeurl = nil;
    if (self.networkConfiguration && ![urlString hasPrefix:@"http"]) {
        relativeurl = [NSURL URLWithString:self.networkConfiguration.baseURL];
    }
    NSURL *URL = [NSURL URLWithString:urlString relativeToURL:relativeurl];
    return URL;
}

/**
 
 Handles a flag `autoLoginEnabled` from networkConfiguration. Stores all possible 401 and execute it once login is sucess.
 
 **/
- (void)executeURLRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler {
    if (self.performingRelogin && self.networkConfiguration.autoLoginEnabled) {
        [self.reLoginQueue addObject:@{@"request":request,@"completionHandler":completionHandler}];
    }
    else {
        if (self.networkConfiguration.basicAuthorizationToken) {
            NSMutableURLRequest *mutableRequest = [request mutableCopy];
            [mutableRequest addValue:[NSString stringWithFormat:@"BASIC %@",self.networkConfiguration.basicAuthorizationToken] forHTTPHeaderField:@"Authorization"];
            request = [mutableRequest copy];
        }
        NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            if (httpResponse.statusCode == 401) {
                if (self.networkConfiguration.autoLoginEnabled) {
                    [self.reLoginQueue addObject:@{@"request":request,@"completionHandler":completionHandler}];
                    [self performReloginForFailedRequest];
                }
                else {
                    completionHandler(response, responseObject, error);
                }
            }
            else {
                completionHandler(response, responseObject, error);
            }
        }];
        [dataTask resume];
    }
}

- (void)performReloginForFailedRequest {
    self.performingRelogin = true;
    [self performLoginWithOnCompletionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        self.performingRelogin = false;
        for (NSDictionary *object in self.reLoginQueue) {
            [self executeURLRequest:object[@"request"] completionHandler:object[@"completionHandler"]];
        }
        self.reLoginQueue = [[NSMutableArray alloc] init];
        
    }];
}


@end
