//
//  PreferencesControllerWindowController.m
//  RemoteSvnUpdate
//
//  Created by Matthew Higgins on 8/21/14.
//  Copyright (c) 2014 Matthew Higgins. All rights reserved.
//

#import "PreferencesControllerWindowController.h"

@interface PreferencesControllerWindowController ()

@end


@implementation PreferencesControllerWindowController

@synthesize usernameField;
@synthesize passwordField;
@synthesize stgSshHostField;
@synthesize prodSshHostField;
@synthesize stgSvnPathField;
@synthesize prodSvnPathField;


- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.usernameField.stringValue = [defaults objectForKey:@"username"];
    self.passwordField.stringValue = [defaults objectForKey:@"password"];
    self.stgSshHostField.stringValue = [defaults objectForKey:@"stgSshHost"];
    self.prodSshHostField.stringValue = [defaults objectForKey:@"prodSshHost"];
    self.stgSvnPathField.stringValue = [defaults objectForKey:@"stgSvnPath"];
    self.prodSvnPathField.stringValue = [defaults objectForKey:@"prodSvnPath"];


}
-(IBAction)saveButtonPressed:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:usernameField.stringValue forKey:@"username"];
    [defaults setObject:passwordField.stringValue forKey:@"password"];
    [defaults setObject:self.stgSshHostField.stringValue forKey:@"stgSshHost"];
    [defaults setObject:self.prodSshHostField.stringValue forKey:@"prodSshHost"];
    [defaults setObject:self.stgSvnPathField.stringValue forKey:@"stgSvnPath"];
    [defaults setObject:self.prodSvnPathField.stringValue forKey:@"prodSvnPath"];

    [defaults synchronize];
    [self close];
}
@end
