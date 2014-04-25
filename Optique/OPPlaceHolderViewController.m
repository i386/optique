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
    [super awakeFromNib];
    
    CNBaseView *baseView = (CNBaseView*)self.view;
    baseView.icon = _image;
    baseView.text = _text;
    baseView.iconVerticalOffset = 50.0f;
    
    
    self.view.postsFrameChangedNotifications = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidResize:) name:NSViewFrameDidChangeNotification object:self.view];
}

-(void)viewDidResize:(NSNotification*)notification
{
    CNBaseView *baseView = (CNBaseView*)self.view;
    baseView.textBoxWidth = self.view.frame.size.width - (self.view.frame.size.width * 0.4);
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:self];
}

@end
