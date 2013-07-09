//
//  OPFlickr.m
//  Optique
//
//  Created by James Dumay on 5/07/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPFlickrPlugin.h"
#import "NSImage+CGImage.h"
#import "OPFlickrPhotoSet.h"

@implementation OPFlickrPlugin

-(id<XPPhotoCollection>)createCollectionAtPath:(NSURL *)url metadata:(NSDictionary*)metadata photoManager:(XPPhotoManager *)photoManager
{
    return [[OPFlickrPhotoSet alloc] initWithDictionary:metadata photoManager:photoManager];
}

-(void)photoManagerWasCreated:(XPPhotoManager *)photoManager
{
    _flickrService = [[OPFlickrService alloc] initWithPhotoManager:photoManager];
    _flickrService.delegate = self;
    [_flickrService loadPhotoSets];
}

-(CALayer *)badgeLayerForCollection:(id<XPPhotoCollection>)collection
{
    if ([collection isKindOfClass:[OPFlickrPhotoSet class]])
    {
        NSBundle *bundle = [NSBundle bundleForClass:[OPFlickrPlugin class]];
        
        NSString *path = [bundle.resourcePath stringByAppendingPathComponent:@"flickr-large.png"];
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:path];
        
        XPBadgeLayer *layer = [XPBadgeLayer layer];
        XPBadgeLayer *imageLayer = [XPBadgeLayer layer];
        imageLayer.contents = (id)image.CGImageRef;
        imageLayer.bounds = NSMakeRect(0, 0, 24, 24);
        imageLayer.position = NSMakePoint(260.0, 155.0);
        
        [layer addSublayer:imageLayer];
        
        return layer;
    }
    return nil;
}

-(void)photoManager:(XPPhotoManager *)photoManager collectionViewController:(id<XPCollectionViewController>)controller
{
    XPPhotoManager * __weak weakPhotoManager = photoManager;
    
    XPMenuItem *uploadPhotoSet = [[XPMenuItem alloc] initWithTitle:@"Upload" keyEquivalent:@"" block:^(NSMenuItem *sender) {
        NSIndexSet *indexes = [controller selectedItems];
        
        [indexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop)
         {
             id collection = weakPhotoManager.allCollections[index];
             [_flickrService uploadPhotoAlbum:collection];
         }];
    }];
    
    XPMenuItem *downloadPhotoSet = [[XPMenuItem alloc] initWithTitle:@"Download" keyEquivalent:[NSString string] block:^(NSMenuItem *sender) {
        NSIndexSet *indexes = [controller selectedItems];
        
        [indexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop)
         {
             id collection = weakPhotoManager.allCollections[index];
             [_flickrService syncPhotoSetToDisk:collection];
         }];
    }];
    
    downloadPhotoSet.visibilityPredicate = [NSPredicate predicateWithBlock:^BOOL(NSArray *selectedItems, NSDictionary *bindings) {
        
        BOOL visible = YES;
        
        for (id<XPPhotoCollection> collection in selectedItems)
        {
            if (![collection isKindOfClass:[OPFlickrPhotoSet class]])
            {
                visible = NO;
                break;
            }
        }
        
        return visible;
    }];
    
    [[controller contextMenu] addItem:downloadPhotoSet];
    [[controller contextMenu] addItem:uploadPhotoSet];
}

-(NSArray *)debugMenuItems
{
    XPMenuItem *signin = [[XPMenuItem alloc] initWithTitle:@"Sign in" keyEquivalent:@"" block:^(NSMenuItem *sender) {
        NSWindow *mainWindow = [NSApp mainWindow];
        [_flickrService signin:mainWindow];
    }];
    
    XPMenuItem *signout = [[XPMenuItem alloc] initWithTitle:@"Sign out" keyEquivalent:@"" block:^(NSMenuItem *sender) {
        [_flickrService signout];
    }];
    
    XPMenuItem *reloadSets = [[XPMenuItem alloc] initWithTitle:@"Load all sets" keyEquivalent:@"" block:^(NSMenuItem *sender) {
        [_flickrService loadPhotoSets];
    }];
    
    return @[signin, signout, reloadSets];
}

-(void)serviceDidSignIn:(OPFlickrService *)service error:(NSError *)error
{
    if (!error)
    {
        [service loadPhotoSets];
    }
}

-(void)serviceRequestDidFail:(OPFlickrService *)service error:(NSError *)error
{
    if (error.code == 401)
    {
        NSLog(@"needs login");
    }
}

-(void)serviceDidSignOut:(OPFlickrService *)service
{
    for (OPFlickrPhotoSet *photoSet in _photoCollections)
    {
        [_delegate didRemovePhotoCollection:photoSet];
    }
}

-(void)service:(OPFlickrService *)service foundSet:(OPFlickrPhotoSet *)photoSet
{
    [_delegate didAddPhotoCollection:photoSet];
}

@end
