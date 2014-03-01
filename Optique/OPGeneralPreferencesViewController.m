//
//  OPGeneralPreferencesViewController.m
//  Optique
//
//  Created by James Dumay on 1/03/2014.
//  Copyright (c) 2014 James Dumay. All rights reserved.
//

#import "OPGeneralPreferencesViewController.h"

@interface OPGeneralPreferencesViewController ()

@end

@implementation OPGeneralPreferencesViewController

- (id)init
{
    self = [super initWithNibName:@"OPGeneralPreferencesViewController" bundle:nil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(NSString *)identifier
{
    return @"general";
}

-(NSString *)toolbarItemLabel
{
    return @"General";
}

-(NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
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
