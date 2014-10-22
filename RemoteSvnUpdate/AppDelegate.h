//
//  AppDelegate.h
//  RemoteSvnUpdate
//
//  Created by Matthew Higgins on 8/21/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "PreferencesControllerWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSView *mainView;
@property (assign) IBOutlet NSTableView *fileListTable;
@property (assign) IBOutlet NSButton *updateButton;
@property (assign) IBOutlet NSTextView *statusView;
@property (assign) IBOutlet NSMenuItem *prefsMenuItem;
@property (assign) IBOutlet NSProgressIndicator *progressBar;
@property (assign) IBOutlet NSPopUpButton *serverSelection;
@property (assign) IBOutlet NSTextField *serverLabel;

@property (retain)  PreferencesControllerWindowController *prefsWindow;
@property (strong) NSMutableArray *pathsToUpdate;
@property (strong) NSString *username;
@property (strong) NSString *password;
@property (strong) NSString *stgSshHost;
@property (strong) NSString *prodSshHost;
@property (strong) NSString *sshHost;
@property (strong) NSString *remoteSvnPath;
@property (strong) NSString *prodSvnPath;
@property (strong) NSString *stgSvnPath;

-(IBAction)updateButtonPressed:(id)sender;
-(IBAction)refreshButtonPressed:(id)sender;
-(IBAction)openPreferences:(id)sender;
-(IBAction)serverSelectionChanged:(id)sender;

@end
