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
#import "OPFlickrPhoto.h"
#import "OPLocalPhoto.h"

#define fFlickrAPIKey             @"ab0746e0e054e9b7326023fd25c767e1"
#define fFlickrAPISecret          @"92360fbc2b26ecb0"

#define fFlickrRequestURL         @"http://www.flickr.com/services/oauth/request_token"
#define fFlickrAccessURL          @"http://www.flickr.com/services/oauth/access_token"
#define fFlickrAuthorizeURL       @"http://www.flickr.com/services/oauth/authorize?perms=delete"
#define fFlickrScope              @"http://www.flickr.com/"

#define fFlickrOAuthToken         @"flickr-oauth-token"
#define fFlickrServiceName        @"Flickr"
#define fFlickrExposureIdentifier @"com.whimsy.optique.Flickr"

@implementation OPFlickrService

-(id)initWithPhotoManager:(XPPhotoManager *)photoManager
{
    self = [super init];
    if (self)
    {
        _photoManager = photoManager;
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
            
            [_delegate serviceDidSignIn:self error:error];
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
    NSString *urlAsString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?nojsoncallback=1&method=%@&format=json&api_key=%@&page=%i", @"flickr.photosets.getList", fFlickrAPIKey, 1];
    
    NSURL *url = [NSURL URLWithString:urlAsString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    [_authentication addResourceTokenHeaderToRequest:request];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSDictionary *result = (NSDictionary*)JSON;
        NSArray *photoSets = result[@"photosets"][@"photoset"];
        
        for (NSDictionary *photoSet in photoSets)
        {
            OPFlickrPhotoSet *flickrPhotoSet = [[OPFlickrPhotoSet alloc] initWithDictionary:photoSet photoManager:_photoManager];
            [self loadPhotosForSet:flickrPhotoSet];
            
            [_delegate service:self foundSet:flickrPhotoSet];
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [_delegate serviceRequestDidFail:self error:error];
    }];
    
    [operation start];
}

-(void)loadPhotosForSet:(OPFlickrPhotoSet*)photoSet
{
    NSString *urlAsString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?nojsoncallback=1&method=%@&format=json&api_key=%@&page=%i&photoset_id=%@&extras=%@", @"flickr.photosets.getPhotos", fFlickrAPIKey, 1, photoSet.flickrId, @"url_o,date_taken"];
    
    NSURL *url = [NSURL URLWithString:urlAsString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0f];
    
    [_authentication addResourceTokenHeaderToRequest:request];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSDictionary *result = (NSDictionary*)JSON;
        NSArray *photos = result[@"photoset"][@"photo"];
        
        for (NSDictionary *dict in photos)
        {
            OPFlickrPhoto *photo = [[OPFlickrPhoto alloc] initWithDictionary:dict photoSet:photoSet];
            [photoSet addPhoto:photo];
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [_delegate serviceRequestDidFail:self error:error];
    }];
    
    [operation start];
    [operation waitUntilFinished];
}

-(void)syncPhotoSetToDisk:(OPFlickrPhotoSet *)photoSet
{
    NSError *error;
    [_photoManager createLocalPhotoCollectionWithPrototype:photoSet identifier:fFlickrExposureIdentifier error:&error];
    if (!error)
    {
        for (OPFlickrPhoto *photo in photoSet.allPhotos)
        {
            [photo download];
        }
    }
    else
    {
        NSLog(@"Error syncing album '%@'. Reason: %@", photoSet.title, error);
    }
}

-(void)uploadPhotoAlbum:(id<XPPhotoCollection>)photoAlbum
{
    [self uploadPhotos:photoAlbum];
}

-(void)uploadPhotos:(id<XPPhotoCollection>)album
{
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://up.flickr.com"]];
    
    for (OPLocalPhoto *photo in album.allPhotos)
    {
        NSDictionary *params = @{@"title": photo.title};
        NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"/services/upload/?format=json" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileURL:photo.url name:@"photo" error:nil];
        }];
        
        [_authentication addResourceTokenHeaderToRequest:request];
        
        [request setTimeoutInterval:5];
        
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            
            NSDictionary *result = (NSDictionary*)JSON;
            
            NSLog(@"result %@", result);
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            [_delegate serviceRequestDidFail:self error:error];
        }];
        
        [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            
            NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
            CGFloat progress = ((CGFloat)totalBytesWritten) / totalBytesExpectedToWrite * 100;
            NSLog(@"Progress: %@", [NSString stringWithFormat:@"%0.1f %%", progress]);
        }];
        
        [operation start];
        [operation waitUntilFinished];
    }
}

@end
