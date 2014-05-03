//
//  OPNewAlbumPanelViewController.m
//  Optique
//
//  Created by James Dumay on 5/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import <Carbon/Carbon.h>
#import "OPNewAlbumPanelViewController.h"
#import "OPPlaceHolderViewController.h"
#import "OPItemGridViewCell.h"
#import "OPItemPreviewManager.h"
#import "NSColor+Optique.h"
#import "NSURL+ImageType.h"
#import "NSURL+Renamer.h"
#import "NSData+WriteImage.h"

@interface OPNewAlbumPanelViewController ()

@property (strong) OPPlaceHolderViewController *placeHolderViewController;
@property (strong) NSMutableArray *items;

@end

@implementation OPNewAlbumPanelViewController

-(id)initWithCollectionManager:(XPCollectionManager *)collectionManager sidebarController:(id<XPSidebarController>)sidebarController
{
    self = [super initWithNibName:@"OPNewAlbumPanelViewController" bundle:nil];
    if (self) {
        _collectionManager = collectionManager;
        _sidebarController = sidebarController;
        _items = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    _gridview.ignoreSizePreference = YES;
    
    _placeHolderViewController = [[OPPlaceHolderViewController alloc] initWithText:@"Drag photos here" image:[NSImage imageNamed:@"down"]];
    
    [_doneButton setKBButtonType:BButtonTypePrimary];
    [_doneButton setEnabled:NO];
    
    [_gridview reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumNameChanged:) name:NSControlTextDidChangeNotification object:_albumNameTextField];
    
    [_gridview setItemSize:NSMakeSize(_gridview.itemSize.width / 2.5, _gridview.itemSize.height / 2.5)];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSControlTextDidChangeNotification object:_albumNameTextField];
}

-(void)activate
{
    [self.view.window makeFirstResponder:_albumNameTextField];
}

- (NSString*)albumName
{
    return [_albumNameTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)albumNameChanged:(NSNotification*)notification
{
    NSString *name = [self albumName];
    
    [_doneButton setEnabled:![name isEqualToString:@""]];
    
    if ([name isEqualToString:@""])
    {
        [_doneButton setEnabled:NO];
    }
    else
    {
        [_doneButton setEnabled:YES];
    }
}

- (IBAction)cancel:(id)sender
{
    [_sidebarController hideSidebar];
}

- (IBAction)done:(id)sender
{
    NSString *albumName = [self albumName];
    NSError *error;
    
    id<XPItemCollection> album = [_collectionManager newAlbumWithName:albumName error:&error];
    if (album)
    {
        [_items bk_each:^(id sender) {
            if ([sender conformsToProtocol:@protocol(XPItem)])
            {
                [album moveItem:sender withCompletion:nil];
            }
            else if ([sender isKindOfClass:[NSURL class]])
            {
                id<XPItem> item = [XPExposureService itemForURL:sender collection:album];
                [album copyItem:item withCompletion:^(NSError *error) {
#if DEBUG
                    NSLog(@"Added url %@ to collection %@", item, album);
#endif
                }];
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
    OPItemGridViewCell *item = (OPItemGridViewCell *)[gridView cellForItemAtIndex:index makeIfNecessary:NO];
    if (!item)
    {
        item = (OPItemGridViewCell *)[gridView dequeueReusableCell];
    }
    
    if (!item)
    {
        item = [[OPItemGridViewCell alloc] init];
    }
    
    if (_items.count > 0)
    {
        id obj = _items[index];
        
        if ([obj isKindOfClass:[NSURL class]])
        {
            NSURL *url = (NSURL*)obj;
            
            //TODO: preview this
            item.image = [[NSImage alloc] initWithContentsOfURL:url];
        }
        else if ([obj conformsToProtocol:@protocol(XPItem)])
        {
            OPItemGridViewCell * __weak weakItem = item;
            id<XPItem> __weak weakPhoto = obj;
            
            item.representedObject = weakPhoto;
            
            [[OPItemPreviewManager defaultManager] previewItem:obj size:_gridview.itemSize loaded:^(NSImage *image) {
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
                for (id<XPItemCollectionProvider> provider in [XPExposureService itemCollectionProviders])
                {
                    if ([provider respondsToSelector:@selector(badgeLayerForPhoto:)])
                    {
                        item.badgeLayer = [provider badgeLayerForItem:(id<XPItem>)obj];
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

-(BOOL)gridView:(OEGridView *)gridView keyDown:(NSEvent *)event
{
    if ([event keyCode] == kVK_Delete || [event keyCode] == kVK_ForwardDelete)
    {
        [_items removeObjectsAtIndexes:[gridView selectionIndexes]];
        [_gridview reloadData];
        return YES;
    }
    return NO;
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
    if ([[self albumName] isEqualToString:@""])
    {
        [_albumNameTextField becomeFirstResponder];
    }
    
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    for (NSString *type in [NSImage imagePasteboardTypes])
    {
        NSURL *fileURL = [NSURL URLFromPasteboard:pboard];
        NSData *data = [pboard dataForType:type];
        
        NSString *fileName = fileURL ? fileURL.pathExtension : @"Copied image.png";
        
        if (data)
        {
            NSURL *destURL = [[NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]] URLWithUniqueNameIfExistsAtParent];
            
            CFStringRef uti = [destURL imageUTI];
            
            if ([data writeImage:destURL withUTI:uti])
            {
                return YES;
            }
        }
    }
    
    if ( [[pboard types] containsObject:NSFilenamesPboardType])
    {
        NSURL *fileURL = [NSURL URLFromPasteboard:pboard];
        
        BOOL isDir;
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileURL.path isDirectory:&isDir] && !isDir)
        {
            if (![_items containsObject:fileURL])
            {
                [_items addObject:fileURL];
                [_gridview reloadData];
                return YES;
            }
        }
    }
    else if ([[pboard types] containsObject:XPItemPboardType])
    {
        __block BOOL reload = NO;
        
        [[pboard pasteboardItems] bk_each:^(NSPasteboardItem *item) {
            
            NSData *data = [item dataForType:XPItemPboardType];
            if (data)
            {
                NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                
                id<XPItemCollection> collection = [_collectionManager.allCollections bk_match:^BOOL(id<XPItemCollection> obj) {
                    return [[obj title] isEqualToString:dict[@"collection-title"]];
                }];
                
                if (collection)
                {
                    id<XPItem> item = [[collection allItems] bk_match:^BOOL(id<XPItem> obj) {
                        return [[obj title] isEqualToString:dict[@"item-title"]];
                    }];
                    
                    
                    if (![_items containsObject:item])
                    {
                        [_items addObject:item];
                        reload = YES;
                    }
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

-(void)closed
{
    //TODO: delete all tmp files
}

@end
