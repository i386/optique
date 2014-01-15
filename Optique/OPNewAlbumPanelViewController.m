//
//  OPNewAlbumPanelViewController.m
//  Optique
//
//  Created by James Dumay on 5/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPNewAlbumPanelViewController.h"
#import "OPPlaceHolderViewController.h"
#import "OPPhotoGridViewCell.h"
#import "OPImagePreviewService.h"

@interface OPNewAlbumPanelViewController ()

@property (strong) OPPlaceHolderViewController *placeHolderViewController;
@property (strong) NSMutableArray *items;

@end

@implementation OPNewAlbumPanelViewController

-(id)initWithPhotoManager:(XPPhotoManager *)photoManager sidebarController:(id<OPWindowSidebarController>)sidebarController
{
    self = [super initWithNibName:@"OPNewAlbumPanelViewController" bundle:nil];
    if (self) {
        _photoManager = photoManager;
        _sidebarController = sidebarController;
        _items = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    _placeHolderViewController = [[OPPlaceHolderViewController alloc] initWithText:@"Drag photos here" image:[NSImage imageNamed:@"down"]];
    
    [_gridview reloadData];
}

-(void)activate
{
    [self.view.window makeFirstResponder:_albumNameTextField];
}

- (NSString*)albumName
{
    return [_albumNameTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (IBAction)albumNameChanged:(id)sender
{
    NSString *name = [self albumName];
    
    [_doneButton setEnabled:![name isEqualToString:@""]];
    
    if ([name isEqualToString:@""])
    {
        [_doneButton setKBButtonType:BButtonTypeDefault];
        _doneButton.stringValue = @"Cancel";
    }
    else
    {
        [_doneButton setKBButtonType:BButtonTypePrimary];
        _doneButton.stringValue = @"Done";
    }
}

- (IBAction)done:(id)sender
{
    NSString *albumName = [self albumName];
    NSError *error;
    id<XPPhotoCollection> album = [_photoManager newAlbumWithName:albumName error:&error];
    if (album)
    {
        [_items each:^(id sender) {
            if ([sender conformsToProtocol:@protocol(XPPhoto)])
            {
                [album addPhoto:sender withCompletion:nil];
            }
            else if ([sender isKindOfClass:[NSURL class]])
            {
                NSLog(@"TODO: create me");
            }
            else
            {
                NSLog(@"Not sure what to do with item '%@' when creating album", [sender class]);
            }
        }];
        
        [_sidebarController hideSidebar];
    }
    else
    {
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
            
        }];
    }
}

-(NSUInteger)numberOfItemsInGridView:(OEGridView *)gridView
{
    return _items.count;
}

-(OEGridViewCell *)gridView:(OEGridView *)gridView cellForItemAtIndex:(NSUInteger)index
{
    OPPhotoGridViewCell *item = (OPPhotoGridViewCell *)[gridView cellForItemAtIndex:index makeIfNecessary:NO];
    if (!item)
    {
        item = (OPPhotoGridViewCell *)[gridView dequeueReusableCell];
    }
    
    if (!item)
    {
        item = [[OPPhotoGridViewCell alloc] init];
    }
    
    if (_items.count > 0)
    {
        id obj = _items[index];
        
        if ([obj isKindOfClass:[NSURL class]])
        {
            NSURL *url = (NSURL*)obj;
            
            item.representedObject = url;
            
            //TODO: preview this
            item.image = [[NSImage alloc] initWithContentsOfURL:url];
        }
        else if ([obj conformsToProtocol:@protocol(XPPhoto)])
        {
            OPPhotoGridViewCell * __weak weakItem = item;
            id<XPPhoto> __weak weakPhoto = obj;
            
            item.image = [[OPImagePreviewService defaultService] previewImageWithPhoto:(id<XPPhoto>)obj loaded:^(NSImage *image)
                          {
                              [self performBlockOnMainThread:^
                               {
                                   if (weakPhoto == weakItem.representedObject)
                                   {
                                       weakItem.image = image;
                                   }
                               }];
                          }];
            
            item.view.toolTip = [obj title];
            
            if (!item.badgeLayer)
            {
                //Get badge layer from exposure
                for (id<XPPhotoCollectionProvider> provider in [XPExposureService photoCollectionProviders])
                {
                    if ([provider respondsToSelector:@selector(badgeLayerForPhoto:)])
                    {
                        item.badgeLayer = [provider badgeLayerForPhoto:(id<XPPhoto>)obj];
                        if (item.badgeLayer)
                        {
                            break;
                        }
                    }
                }
            }
        }
    }
    
    return item;
}

-(NSView *)viewForNoItemsInGridView:(OEGridView *)gridView
{
    _placeHolderViewController.view.frame = gridView.frame;
    return _placeHolderViewController.view;
}

- (NSDragOperation)gridView:(OEGridView *)gridView validateDrop:(id<NSDraggingInfo>)sender
{
    return NSDragOperationCopy; // [self isFileDrop:sender] ? NSDragOperationCopy : NSDragOperationNone;
}

- (NSDragOperation)gridView:(OEGridView *)gridView draggingUpdated:(id<NSDraggingInfo>)sender
{
    return NSDragOperationCopy; // [self isFileDrop:sender] ? NSDragOperationCopy : NSDragOperationNone;
}

- (BOOL)gridView:(OEGridView *)gridView acceptDrop:(id<NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSFilenamesPboardType])
    {
        NSURL *fileURL = [NSURL URLFromPasteboard:pboard];
        
        BOOL isDir;
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileURL.path isDirectory:&isDir] && !isDir)
        {
            [_items addObject:fileURL];
            [_gridview reloadData];
            return YES;
        }
    }
    else if ([[pboard types] containsObject:XPPhotoPboardType])
    {
        __block BOOL reload = NO;
        
        [[pboard pasteboardItems] each:^(NSPasteboardItem *item) {
            
            NSData *data = [item dataForType:XPPhotoPboardType];
            if (data)
            {
                NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                
                id<XPPhotoCollection> collection = [_photoManager.allCollections match:^BOOL(id<XPPhotoCollection> obj) {
                    return [[obj title] isEqualToString:dict[@"collection-title"]];
                }];
                
                if (collection)
                {
                    id<XPPhoto> photo = [[collection allPhotos] match:^BOOL(id<XPPhoto> obj) {
                        return [[obj title] isEqualToString:dict[@"photo-title"]];
                    }];
                    
                    [_items addObject:photo];
                    reload = YES;
                }
            }
            
        }];
        
        if (reload)
        {
            [_gridview reloadData];
        }
        
    }
    
    return NO;
}

@end
