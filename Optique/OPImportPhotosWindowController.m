//
//  OPImportPhotosWindowController.m
//  Optique
//
//  Created by James Dumay on 20/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPImportPhotosWindowController.h"

@interface OPImportPhotosWindowController ()

@property (strong) NSArray *photos;
@property (weak) XPPhotoManager *photoManager;
@property (strong) NSArray *collections;
@property (weak) IBOutlet NSComboBox *albumSelectionBox;
@property (assign) int imported;
@property (weak) IBOutlet NSButton *importButton;
@property (strong) XPCompletionBlock completionBlock;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

@end

@implementation OPImportPhotosWindowController

-(id)initWithPhotos:(NSArray *)photos photoManager:(XPPhotoManager*)photoManager whenCompleted:(XPCompletionBlock)block
{
    self = [super init];
    if (self)
    {
        _photos = photos;
        _photoManager = photoManager;
        _collections = [_photoManager.allCollections filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id<XPPhotoCollection> evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject collectionType] == kPhotoCollectionLocal;
        }]];
        _completionBlock = block;
    }
    return self;
}

-(NSString *)windowNibName
{
    return @"OPImportPhotosWindowController";
}

- (IBAction)importPhotos:(id)sender
{
    id<XPPhotoCollection> selected = [_collections match:^BOOL(id<XPPhotoCollection> obj) {
        return [[obj title] isEqualToString:_albumSelectionBox.stringValue];
    }];
    
    if (selected)
    {
        [self startImport:selected];
    }
    else
    {
        NSError *error;
        id<XPPhotoCollection> album = [_photoManager newAlbumWithName:_albumSelectionBox.stringValue error:&error];
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

-(void)startImport:(id<XPPhotoCollection>)collection
{
    [_importButton setEnabled:NO];
    [_progressIndicator startAnimation:self];
    
    [self performBlockInBackground:^{
        for (id<XPPhoto> photo in _photos)
        {
            [photo requestLocalCopy:[collection path] whenDone:^(NSError *error) {
                [self updateImported:photo];
            }];
        }
    }];
}

-(void)updateImported:(id<XPPhoto>)photo
{
    _imported++;
    if (_imported == _photos.count)
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
        id<XPPhotoCollection> collection = _collections[i];
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
