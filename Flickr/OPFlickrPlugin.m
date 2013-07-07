//
//  OPFlickr.m
//  Optique
//
//  Created by James Dumay on 5/07/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPFlickrPlugin.h"

@implementation OPFlickrPlugin

-(id)init
{
    self = [super init];
    if (self)
    {
        _flickrService = [[OPFlickrService alloc] init];
        _flickrService.delegate = self;
    }
    return self;
}

-(NSArray *)debugMenuItems
{
    XPMenuItem *signin = [[XPMenuItem alloc] initWithTitle:@"Signin" keyEquivalent:@"" block:^(NSMenuItem *sender) {
        NSWindow *mainWindow = [NSApp mainWindow];
        [_flickrService signin:mainWindow];
    }];
    
    XPMenuItem *signout = [[XPMenuItem alloc] initWithTitle:@"Signout" keyEquivalent:@"" block:^(NSMenuItem *sender) {
        [_flickrService signout];
    }];
    
    XPMenuItem *reloadSets = [[XPMenuItem alloc] initWithTitle:@"Reload sets" keyEquivalent:@"" block:^(NSMenuItem *sender) {
        [_flickrService loadPhotoSets];
    }];
    
    return @[signin, signout, reloadSets];
}

-(void)serviceDidSignIn:(OPFlickrService *)service error:(NSError *__autoreleasing *)error
{
    
}

-(void)serviceDidSignOut:(OPFlickrService *)service
{
    
}

-(void)service:(OPFlickrService *)service foundSet:(OPFlickrPhotoSet *)photoSet
{
    [_delegate didAddPhotoCollection:photoSet];
}

@end
