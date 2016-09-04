//
//  TescoNetworkManager.h
//  TescoNetworkLibrary
//
//  Created by Nalin Chhajer on 04/09/16.
//  Copyright © 2016 Tesco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TescoNetworkConfiguration.h"

@interface TescoNetworkManager : NSObject

@property (nonatomic, strong) TescoNetworkConfiguration *networkConfiguration;

+ (id)sharedManager;

- (void)performGet:(NSString *)relativeString completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;

- (void)performLoginWithOnCompletionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;

- (void)clearLoginToken;
@end
