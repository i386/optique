//
//  OPNavigationBar.m
//  Optique
//
//  Created by James Dumay on 27/03/13.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPNavigationBar.h"

#import "OPNavigationBarButton.h"

@implementation OPNavigationBar

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSImage *bgImage = [NSImage imageNamed:@"toolbarbg"];
    [bgImage drawInRect:self.bounds fromRect:NSMakeRect(0.0f, 0.0f, bgImage.size.width, bgImage.size.height) operation:NSCompositeSourceOver fraction:100.0];
}

-(void)awakeFromNib
{
    OPNavigationBarButton *button  = (OPNavigationBarButton*)_backButton;
    [button setTextColor:[NSColor whiteColor]];
}

-(void)setTitle:(NSString *)title
{
    _viewLabel.stringValue = title;
}

-(void)hideBackButton:(BOOL)hide
{
    [_backButton setHidden:hide];
}

-(void)backClicked:(id)sender
{
    [_navigationController popToPreviousViewController];
}

@end
