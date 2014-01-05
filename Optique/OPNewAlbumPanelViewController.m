//
//  OPNewAlbumPanelViewController.m
//  Optique
//
//  Created by James Dumay on 5/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPNewAlbumPanelViewController.h"
#import "OPPlaceHolderViewController.h"

@interface OPNewAlbumPanelViewController ()

@property (strong) OPPlaceHolderViewController *placeHolderViewController;
@property (strong) NSMutableArray *items;

@end

@implementation OPNewAlbumPanelViewController

-(id)initWithPhotoManager:(XPPhotoManager *)photoManager sidebar:(id<OPWindowSidebar>)sidebar
{
    self = [super initWithNibName:@"OPNewAlbumPanelViewController" bundle:nil];
    if (self) {
        _photoManager = photoManager;
        _sidebar = sidebar;
        _items = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.view.window makeFirstResponder:_albumNameTextField];
    
    _placeHolderViewController = [[OPPlaceHolderViewController alloc] initWithText:@"Drag photos here" image:[NSImage imageNamed:@"down"]];
    
    [_gridview reloadData];
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
    [_sidebar hideSidebar];
}

-(NSUInteger)numberOfItemsInGridView:(OEGridView *)gridView
{
    return _items.count;
}

-(OEGridViewCell *)gridView:(OEGridView *)gridView cellForItemAtIndex:(NSUInteger)index
{
    return nil;
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
            NSString *fileName = [fileURL lastPathComponent];
            NSLog(@"dropped %@", fileName);
            
            NSError *error;
            return error ? NO : YES;
        }
    }
    
    return NO;
}

@end
