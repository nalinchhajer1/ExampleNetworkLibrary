//
//  TescoNetworkConfiguration.h
//  TescoNetworkLibrary
//
//  Created by Nalin Chhajer on 04/09/16.
//  Copyright © 2016 Tesco. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Setup baseurl and login credential to be used on any request operations.
 **/

@protocol TescoNetworkConfigurationDelegate;

@interface TescoNetworkConfiguration : NSObject

@property (nonatomic, strong) NSString *baseURL;

@property (nonatomic, assign, readonly) BOOL autoLoginEnabled;
@property (nonatomic, strong) NSString *basicAuthorizationToken;
@property (nonatomic, assign) id<TescoNetworkConfigurationDelegate> delegate;

@property (nonatomic, strong) NSArray<Class> *protocolClasses;

+ (TescoNetworkConfiguration *)defaultNetworkConfiguration;


@end

@protocol TescoNetworkConfigurationDelegate <NSObject>
@required
- (NSURLRequest *)getRequestForLoginCredential:(TescoNetworkConfiguration *)config;
- (NSString *)getAuthTokenFromLoginResponse:(NSURLResponse *)response  responseObject:(id)responseObject;

@end