//
//  OPImportPhotosWindowController.m
//  Optique
//
//  Created by James Dumay on 20/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPImportItemsWindowController.h"

@interface OPImportItemsWindowController ()

@property (strong) NSArray *items;
@property (weak) XPCollectionManager *collectionManager;
@property (strong) NSArray *collections;
@property (weak) IBOutlet NSComboBox *albumSelectionBox;
@property (assign) int imported;
@property (weak) IBOutlet NSButton *importButton;
@property (strong) XPCompletionBlock completionBlock;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

@end

@implementation OPImportItemsWindowController

-(id)initWithItems:(NSArray *)items collectionManager:(XPCollectionManager*)collectionManager whenCompleted:(XPCompletionBlock)block
{
    self = [super init];
    if (self)
    {
        _items = items;
        _collectionManager = collectionManager;
        _collections = [_collectionManager.allCollections filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id<XPItemCollection> evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject collectionType] == XPItemCollectionLocal;
        }]];
        _completionBlock = block;
    }
    return self;
}

-(NSString *)windowNibName
{
    return @"OPImportItemsWindowController";
}

- (IBAction)importPhotos:(id)sender
{
    id<XPItemCollection> selected = [_collections bk_match:^BOOL(id<XPItemCollection> obj) {
        return [[obj title] isEqualToString:_albumSelectionBox.stringValue];
    }];
    
    if (selected)
    {
        [self startImport:selected];
    }
    else
    {
        NSError *error;
        id<XPItemCollection> album = [_collectionManager newAlbumWithName:_albumSelectionBox.stringValue error:&error];
        if (error)
        {
            [self.window orderOut:nil];
            [NSApp endSheet:self.window];
            
            NSAlert *alert = [NSAlert alertWithError:error];
            [alert addButtonWithTitle:@"OK"];
            
            [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
                [NSApp beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
                    
                }];
            }];
        }
        else
        {
            [self startImport:album];
        }
    }
}

-(void)startImport:(id<XPItemCollection>)collection
{
    [_importButton setEnabled:NO];
    [_progressIndicator startAnimation:self];
    
    [self performBlockInBackground:^{
        for (id<XPItem> item in _items)
        {
            [item requestLocalCopy:[collection path] whenDone:^(NSError *error) {
                [self updateImported:item];
            }];
        }
    }];
}

-(void)updateImported:(id<XPItem>)item
{
    _imported++;
    if (_imported == _items.count)
    {
        //Close window
        [self.window orderOut:nil];
        [NSApp endSheet:self.window];
        
        //Deselect
        _completionBlock(nil);
    }
}

- (IBAction)cancelImport:(id)sender
{
    [self.window orderOut:nil];
    [NSApp endSheet:self.window];
}

-(NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    return _collections.count;
}

-(id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
    return [_collections[index] title];
}

-(NSUInteger)comboBox:(NSComboBox *)aComboBox indexOfItemWithStringValue:(NSString *)string
{
    for (int i = 0; i < _collections.count; i++)
    {
        id<XPItemCollection> collection = _collections[i];
        if ([string isEqualToString:[collection title]])
        {
            return i;
        }
    }
    return NSNotFound;
}

-(NSString *)comboBox:(NSComboBox *)aComboBox completedString:(NSString *)string
{
    return string;
}

-(void)awakeFromNib
{
    [_progressIndicator setDisplayedWhenStopped:NO];
}

@end
