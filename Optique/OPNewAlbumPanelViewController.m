//
//  OPNewAlbumPanelViewController.m
//  Optique
//
//  Created by James Dumay on 5/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPNewAlbumPanelViewController.h"
#import "OPPlaceHolderViewController.h"
#import "OPItemGridViewCell.h"
#import "OPItemPreviewManager.h"

@interface OPNewAlbumPanelViewController ()

@property (strong) OPPlaceHolderViewController *placeHolderViewController;
@property (strong) NSMutableArray *items;

@end

@implementation OPNewAlbumPanelViewController

-(id)initWithCollectionManager:(XPCollectionManager *)collectionManager sidebarController:(id<OPWindowSidebarController>)sidebarController
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
    id<XPItemCollection> album = [_collectionManager newAlbumWithName:albumName error:&error];
    if (album)
    {
        [_items each:^(id sender) {
            if ([sender conformsToProtocol:@protocol(XPItem)])
            {
                [album addItem:sender withCompletion:nil];
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
            
            item.representedObject = url;
            
            //TODO: preview this
            item.image = [[NSImage alloc] initWithContentsOfURL:url];
        }
        else if ([obj conformsToProtocol:@protocol(XPItem)])
        {
            OPItemGridViewCell * __weak weakItem = item;
            id<XPItem> __weak weakPhoto = obj;
            
            [[OPItemPreviewManager defaultManager] previewItem:obj loaded:^(NSImage *image) {
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
    else if ([[pboard types] containsObject:XPItemPboardType])
    {
        __block BOOL reload = NO;
        
        [[pboard pasteboardItems] each:^(NSPasteboardItem *item) {
            
            NSData *data = [item dataForType:XPItemPboardType];
            if (data)
            {
                NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                
                id<XPItemCollection> collection = [_collectionManager.allCollections match:^BOOL(id<XPItemCollection> obj) {
                    return [[obj title] isEqualToString:dict[@"collection-title"]];
                }];
                
                if (collection)
                {
                    id<XPItem> item = [[collection allItems] match:^BOOL(id<XPItem> obj) {
                        return [[obj title] isEqualToString:dict[@"item-title"]];
                    }];
                    
                    [_items addObject:item];
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
