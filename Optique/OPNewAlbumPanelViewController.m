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

- (IBAction)albumNameChanged:(id)sender
{
    NSString *trimmedName = [_albumNameTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [_doneButton setEnabled:![trimmedName isEqualToString:@""]];
    
    if ([trimmedName isEqualToString:@""])
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
    [_sidebarController hideSidebar];
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
        NSURL *url = _items[index];
        item.representedObject = url;
        
        //TODO: preview this
        item.image = [[NSImage alloc] initWithContentsOfURL:url];
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
    //    NSEvent *event = [NSApp currentEvent];
    //
    //    NSPoint pointInView = [_gridView convertPoint:[event locationInWindow] fromView:nil];
    //    NSUInteger index = [_gridView indexForCellAtPoint:pointInView];
    //
    //    NSLog(@"Index of item: %lu %@", (unsigned long)index, event);
    
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
    
    return NO;
}

@end
