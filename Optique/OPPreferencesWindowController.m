//
//  OPPreferencesWindowController.m
//  Optique
//
//  Created by James Dumay on 27/01/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPPreferencesWindowController.h"

@interface OPPreferencesWindowController ()

@end

@implementation OPPreferencesWindowController

- (id)init
{
    self = [super initWithWindowNibName:@"OPPreferencesWindowController"];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    NSUInteger factor = [[NSUserDefaults standardUserDefaults] integerForKey:@"ItemSize"];
    [self updateSizeLabel:factor];
    
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:@"ItemSize"
                                               options:NSKeyValueObservingOptionNew
                                               context:NULL];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSNumber *factor = (NSNumber*)change[@"new"];
    [self updateSizeLabel:[factor unsignedIntegerValue]];
}

-(void)updateSizeLabel:(NSUInteger)factor
{
    switch (factor) {
        case 0:
            _sizeLabel.stringValue = @"Extra small";
            break;
            
        case 25:
            _sizeLabel.stringValue = @"Small";
            break;
            
        case 75:
            _sizeLabel.stringValue = @"Large";
            break;
            
        case 100:
            _sizeLabel.stringValue = @"Extra large";
            break;
            
        default:
            _sizeLabel.stringValue = @"Normal";
            break;
    }
}

@end
