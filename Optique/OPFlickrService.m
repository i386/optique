//
//  OPFlickrService.m
//  Optique
//
//  Created by James Dumay on 6/07/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPFlickrService.h"
#import <AFNetworking/AFNetworking.h>
#import <gtm-oauth/GTMHTTPFetcher.h>
#import "GTMOAuthAuthentication+UserPreferences.h"

#define fFlickrAPIKey             @"ab0746e0e054e9b7326023fd25c767e1"
#define fFlickrAPISecret          @"92360fbc2b26ecb0"

#define fFlickrRequestURL         @"http://www.flickr.com/services/oauth/request_token"
#define fFlickrAccessURL          @"http://www.flickr.com/services/oauth/access_token"
#define fFlickrAuthorizeURL       @"http://www.flickr.com/services/oauth/authorize?perms=delete"
#define fFlickrScope              @"http://www.flickr.com/"

#define fFlickrOAuthToken         @"flickr-oauth-token"
#define fFlickrServiceName        @"Flickr"

@implementation OPFlickrService

-(id)init
{
    self = [super init];
    if (self)
    {
        [self setupAuthentication];
    }
    return self;
}

-(void)signin:(NSWindow*)window
{
    // set the callback URL to which the site should redirect, and for which
    // the OAuth controller should look to determine when sign-in has
    // finished or been canceled
    //
    // This URL does not need to be for an actual web page
    [_authentication setCallback:@"http://whimsyapps.com/"];
    
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.whimsy.optique.Flickr"];
    
    // Display the autentication view
    _controller = [[GTMOAuthWindowController alloc]
                                                  initWithScope:fFlickrScope
                                                  language:nil
                                                  requestTokenURL:[NSURL URLWithString:fFlickrRequestURL]
                                                  authorizeTokenURL:[NSURL URLWithString:fFlickrAuthorizeURL]
                                                  accessTokenURL:[NSURL URLWithString:fFlickrAccessURL]
                                                  authentication:_authentication
                                                  appServiceName:fFlickrServiceName
                                                  resourceBundle:bundle];
    
    //TODO: Call deleagte
    
    [_controller signInSheetModalForWindow:window completionHandler:^(GTMOAuthAuthentication *auth, NSError *error)
    {
        if (error != nil)
        {
            NSLog(@"Auth failed. Code: %ld Info: %@", (long)error.code, error.userInfo);
            NSData *data = error.userInfo[@"data"];
            if (data)
            {
                NSLog(@"%@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
            }
            
            [_delegate serviceDidSignIn:self error:&error];
        }
        else
        {
#if DEBUG
            NSLog(@"Auth succeeded. Token: %@", _authentication.accessToken);
#endif
            [[[NSUserDefaultsController sharedUserDefaultsController] defaults] setObject:_authentication.accessToken forKey:fFlickrOAuthToken];
            
            if ([_authentication saveParamsToUserPreferencesForName:fFlickrServiceName])
            {
                [_delegate serviceDidSignIn:self error:nil];
                [self loadPhotoSets];
            }
        }
    }];
}

-(void)signout
{
    [_authentication removeParamsFromUserPreferencesForName:fFlickrServiceName];
    [self setupAuthentication];
    [_delegate serviceDidSignOut:self];
}

-(void)setupAuthentication
{
    _authentication = [[GTMOAuthAuthentication alloc] initWithSignatureMethod:kGTMOAuthSignatureMethodHMAC_SHA1 consumerKey:fFlickrAPIKey privateKey:fFlickrAPISecret];
    _authentication.serviceProvider = fFlickrServiceName;
    _authentication.shouldUseParamsToAuthorize = YES;
    
    if (![_authentication authorizeFromUserPreferencesForName:fFlickrServiceName])
    {
        //TODO: delegate not authorised
    }
}

//TODO: work with pages
-(void)loadPhotoSets
{
    NSString *urlAsString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=%@&format=json&api_key=%@&page=%i&nojsoncallback=1", @"flickr.photosets.getList", fFlickrAPIKey, 1];
    
    NSURL *url = [NSURL URLWithString:urlAsString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    [_authentication addResourceTokenHeaderToRequest:request];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSDictionary *result = (NSDictionary*)JSON;
        NSArray *photoSets = result[@"photosets"][@"photoset"];
        
        for (NSDictionary *photoSet in photoSets)
        {
            OPFlickrPhotoSet *flickrPhotoSet = [[OPFlickrPhotoSet alloc] initWithDictionary:photoSet];
            [_delegate service:self foundSet:flickrPhotoSet];
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"error: %@", error.userInfo);
    }];
    
    [operation start];
}

@end
