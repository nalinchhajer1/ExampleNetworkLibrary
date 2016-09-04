## Tesco Network library

The main file of the project is inside the folder `TescoNetworkLib`. This lib takes care of below features

* It handles all 401's and refresh token from server.
* Login can be `post request`/`get request` or any http method.
* Provide your own login parser for parsing token.
* Easy way to provide different url for staging, testing or production.

### How to install

Download the code from git and do `pod install`

### How to use

In you app delegate method, initialize the network library using

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    TescoNetworkConfiguration *config = [TescoNetworkConfiguration defaultNetworkConfiguration];
    config.delegate = self;
    config.baseURL = @"http://localhost:3030";
    [[TescoNetworkManager sharedManager] setNetworkConfiguration:config];
    return YES;
}

# pragma mark - TescoNetworkConfigurationDelegate
// perform login request
- (NSURLRequest *)getRequestForLoginCredential:(TescoNetworkConfiguration *)config {
    NSURL *URL = [NSURL URLWithString:@"http://localhost:3030/login?token=abcd1234"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    request.HTTPMethod = @"GET";
    return request;
}

// parse login response
- (NSString *)getAuthTokenFromLoginResponse:(NSURLResponse *)response  responseObject:(id)responseObject {
    NSDictionary *dict = (NSDictionary *)responseObject;
    return dict[@"token"];
}

```

Now feel free to use any get end-point in your view controller with following code

```objective-c
 [[TescoNetworkManager sharedManager] performGet:@"/profile" completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"%@ %@", response, responseObject);
        }
    }];
```
