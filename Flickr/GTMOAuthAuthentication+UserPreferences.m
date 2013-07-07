//
//  GTMOAuthAuthentication+UserPreferences.m
//  Optique
//
//  Created by James Dumay on 7/07/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import "GTMOAuthAuthentication+UserPreferences.h"

@implementation GTMOAuthAuthentication (UserPreferences)

-(BOOL)authorizeFromUserPreferencesForName:(NSString *)appServiceName
{
    NSString *key = [self keyForAppServiceName:appServiceName];
    
    self.token = nil;
    self.hasAccessToken = NO;
    
    NSString *password = [[[NSUserDefaultsController sharedUserDefaultsController] defaults] objectForKey:key];
    if (password)
    {
        self.hasAccessToken = YES;
        [self setKeysForResponseString:password];
        return YES;
    }
    
    return NO;
}

-(BOOL)saveParamsToUserPreferencesForName:(NSString *)appServiceName
{
    NSString *key = [self keyForAppServiceName:appServiceName];
    
    [self removeParamsFromUserPreferencesForName:appServiceName];
    
    [[[NSUserDefaultsController sharedUserDefaultsController] defaults] setObject:[self persistenceResponseString] forKey:key];

    return YES;
}

-(BOOL)removeParamsFromUserPreferencesForName:(NSString *)appServiceName
{
    NSString *key = [self keyForAppServiceName:appServiceName];
    
    [[[NSUserDefaultsController sharedUserDefaultsController] defaults] removeObjectForKey:key];
    
    return YES;
}

-(NSString*)keyForAppServiceName:(NSString*)appServiceName
{
    return [NSString stringWithFormat:@"oauth-access-key-%@", appServiceName];
}

@end
