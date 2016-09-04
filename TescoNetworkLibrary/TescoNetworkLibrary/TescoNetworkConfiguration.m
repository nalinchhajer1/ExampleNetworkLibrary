//
//  TescoNetworkConfiguration.m
//  TescoNetworkLibrary
//
//  Created by Nalin Chhajer on 04/09/16.
//  Copyright © 2016 Tesco. All rights reserved.
//

#import "TescoNetworkConfiguration.h"

@implementation TescoNetworkConfiguration

+ (TescoNetworkConfiguration *)defaultNetworkConfiguration {
    TescoNetworkConfiguration * config = [[TescoNetworkConfiguration alloc] init];
    return config;
}

- (void)setBasicAuthorizationToken:(NSString *)basicAuthorizationToken {
    _basicAuthorizationToken = basicAuthorizationToken;
    if (basicAuthorizationToken) {
        _autoLoginEnabled = true;
    }
    else {
        _autoLoginEnabled = false;
    }
}

@end
