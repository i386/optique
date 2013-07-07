//
//  GTMOAuthAuthentication+UserPreferences.h
//  Optique
//
//  Created by James Dumay on 7/07/2013.
//  Copyright (c) 2013 James Dumay. All rights reserved.
//

#import <gtm-oauth/GTMOAuthAuthentication.h>

@interface GTMOAuthAuthentication (UserPreferences)

- (BOOL)authorizeFromUserPreferencesForName:(NSString *)appServiceName;

// Delete the stored access token and secret, useful for "signing
// out"
- (BOOL)removeParamsFromUserPreferencesForName:(NSString *)appServiceName;

// Store the access token and secret, typically used immediately after
// signing in
- (BOOL)saveParamsToUserPreferencesForName:(NSString *)appServiceName;

@end
