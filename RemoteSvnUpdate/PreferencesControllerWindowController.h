//
//  PreferencesControllerWindowController.h
//  RemoteSvnUpdate
//
//  Created by Matthew Higgins on 8/21/14.
//  Copyright (c) 2014 Matthew Higgins. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferencesControllerWindowController : NSWindowController

@property (assign) IBOutlet NSTextField *usernameField;
@property (assign) IBOutlet NSTextField *passwordField;
@property (assign) IBOutlet NSTextField *stgSshHostField;
@property (assign) IBOutlet NSTextField *prodSshHostField;
@property (assign) IBOutlet NSTextField *stgSvnPathField;
@property (assign) IBOutlet NSTextField *prodSvnPathField;

@property (assign) IBOutlet NSButton *saveButton;


-(IBAction)saveButtonPressed:(id)sender;


@end
