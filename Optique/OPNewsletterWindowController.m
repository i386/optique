//
//  OPNewsletterWindowController.m
//  Optique
//
//  Created by James Dumay on 5/11/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "OPNewsletterWindowController.h"
#import "ChimpKit.h"

@interface OPNewsletterWindowController () <ChimpKitDelegate>

@property (strong) IBOutlet NSUserDefaultsController *userPrefs;

@end

@implementation OPNewsletterWindowController

-(id)init
{
    self = [super initWithWindowNibName:@"OPNewsletterWindowController"];
    if (self)
    {
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [_subscribeButton setKBButtonType:BButtonTypePrimary];
    [_subscribeButton setBoldText:YES];
}

- (IBAction)confirm:(id)sender
{
    ChimpKit *chimp = [[ChimpKit alloc] initWithDelegate:self andApiKey:nil];
    
    [chimp callApiMethod:@"lists/subscribe" withParams:nil];
}

- (IBAction)cancel:(id)sender
{
    [self writeToUserPrefs];
    [NSApp endSheet:self.window];
}

- (void)writeToUserPrefs
{
    [self.userPrefs.defaults setBool:YES forKey:@"shown-newsletter"];
}

-(void)ckRequestSucceeded:(ChimpKit *)ckRequest
{
    [self writeToUserPrefs];
    [NSApp endSheet:self.window];
}

-(void)ckRequestFailed:(ChimpKit *)ckRequest andError:(NSError *)error
{
    
}

-(void)ckRequestFailed:(NSError *)error
{
    
}

@end
