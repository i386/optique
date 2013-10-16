//
//  OPPlaceHolderViewController.m
//  Optique
//
//  Created by James Dumay on 16/10/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPPlaceHolderViewController.h"
#import <CNBaseView/CNBaseView.h>

@interface OPPlaceHolderViewController ()

@property (strong) NSString *text;
@property (strong) NSImage *image;

@end

@implementation OPPlaceHolderViewController


-(id)initWithText:(NSString *)text image:(NSImage*)image
{
    self = [super initWithNibName:@"OPPlaceHolderViewController" bundle:nil];
    if (self) {
        _text = text;
        _image = image;
    }
    return self;
}

-(void)awakeFromNib
{
    CNBaseView *baseView = (CNBaseView*)self.view;
    baseView.icon = _image;
    baseView.text = _text;
    baseView.textBoxWidth = 600.0f;
    baseView.iconVerticalOffset = 50.0f;
}

@end
