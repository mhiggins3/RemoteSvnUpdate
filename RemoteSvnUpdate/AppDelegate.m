//
//  AppDelegate.m
//  RemoteSvnUpdate
//
//  Created by Matthew Higgins on 8/21/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize pathsToUpdate;
@synthesize fileListTable;
@synthesize statusView;
@synthesize prefsWindow;
@synthesize username;
@synthesize password;
@synthesize stgSshHost;
@synthesize prodSshHost;
@synthesize sshHost;
@synthesize remoteSvnPath;
@synthesize prodSvnPath;
@synthesize stgSvnPath;
@synthesize progressBar;
@synthesize serverSelection;
@synthesize serverLabel;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    self.fileListTable.delegate = self;
    self.fileListTable.dataSource = self;
    [self.serverSelection removeAllItems];
    [self.serverSelection addItemWithTitle:@"Staging"];
    [self.serverSelection addItemWithTitle:@"Production"];

    [self refreshSettings];
    [self testMissingSettings];
   
    
}

-(void) testMissingSettings
{
    if(!self.username || !self.password || !self.sshHost || !self.remoteSvnPath){
        [self openPreferences:self];
    } else {
        [self updateFileList];
    }
}
-(void) refreshSettings
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    self.username = [settings objectForKey:@"username"];
    self.password = [settings objectForKey:@"password"];
    self.stgSshHost = [settings objectForKey:@"stgSshHost"];
    self.prodSshHost = [settings objectForKey:@"prodSshHost"];
    self.stgSvnPath = [settings objectForKey:@"stgSvnPath"];
    self.prodSvnPath = [settings objectForKey:@"prodSvnPath"];
    [self setRemoteHostValues];
  
}
-(void) setRemoteHostValues
{
    if([[self.serverSelection titleOfSelectedItem] isEqualToString:@"Production"]){
        self.sshHost = self.prodSshHost;
        self.remoteSvnPath = self.prodSvnPath;
        [self.serverLabel setTextColor:[NSColor redColor]];
        [self.serverLabel setStringValue:@"Production"];
    } else {
        self.sshHost = self.stgSshHost;
        self.remoteSvnPath = self.stgSvnPath;
        [self.serverLabel setTextColor:[NSColor blueColor]];
        [self.serverLabel setStringValue:@"Staging"];
    }
    NSLog(@"Set ssh host to %@ and path to %@", self.sshHost, self.remoteSvnPath);
}
-(IBAction)serverSelectionChanged:(id)sender
{
    [self setRemoteHostValues];
    [self testMissingSettings];
}
-(IBAction)openPreferences:(id)sender
{
    if(!self.prefsWindow){
        NSLog(@"Made it here");
        self.prefsWindow = [[PreferencesControllerWindowController alloc]initWithWindowNibName:@"PreferencesControllerWindowController"];
    }
    [self.prefsWindow showWindow:self];
}

-(void) updateFileList
{
    [self clearFileListView];
    [self appendToStatusView:@"Updating File List" isError:NO];
    [progressBar startAnimation:self];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
  
        
        [self refreshSettings];
        NSPipe *stdOut = [NSPipe pipe];
        NSFileHandle *stdOutFile = stdOut.fileHandleForReading;
        NSPipe *stdErr = [NSPipe pipe];
        
        
        
        NSTask *task = [[NSTask alloc] init];
        NSString *usernameString = [NSString stringWithFormat:@"'%@'", self.username];
        NSString *passwordString = [NSString stringWithFormat:@"'%@'", self.password];
        
        task.launchPath = @"/usr/bin/ssh";
        task.arguments = @[@"-q", self.sshHost, @"svn", @"status", @"-u", self.remoteSvnPath, @"--username", usernameString, @"--password", passwordString, @"--no-auth-cache"];
        task.standardOutput = stdOut;
        task.standardError = stdErr;

        [task launch];


        NSData *stdOutdata = [stdOutFile readDataToEndOfFile];
        [stdOutFile closeFile];
        NSString *svnOutput = [[NSString alloc] initWithData: stdOutdata encoding: NSUTF8StringEncoding];
        NSLog(@"Done Running command ");
        [progressBar stopAnimation:self];
        [self performSelectorOnMainThread:@selector(updateFileListView:)
                               withObject:svnOutput waitUntilDone:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self appendToStatusView:@"Done checking for updates" isError:NO];
        });
    
    });
}



-(void) updateFileListView: (NSString *) commandResult
{
    NSLog(@"Update file list view");
    self.pathsToUpdate = [[NSMutableArray alloc] init];
    NSArray *updateLines = [commandResult componentsSeparatedByString:@"\n"];
    for (NSString *line in updateLines) {
        if([line rangeOfString:@"/"].location != NSNotFound && [line rangeOfString:@" M "].location == NSNotFound){
            long indexOfSlash = [line rangeOfString:@"/"].location;
            NSString *path = [line substringFromIndex:indexOfSlash];
            [self.pathsToUpdate addObject:path];
            [fileListTable reloadData];
        }
    }
    if(self.pathsToUpdate.count == 0){
        [self appendToStatusView:@"No Changes Found" isError:NO];
    }
   
}
-(void) clearFileListView
{
    self.pathsToUpdate = [[NSMutableArray alloc] init];
    [fileListTable reloadData];

}
-(void) updateFileAtPath:(NSString *) path
{
    [self refreshSettings];
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *file = pipe.fileHandleForReading;
    
    NSTask *task = [[NSTask alloc] init];
    NSString *usernameString = [NSString stringWithFormat:@"'%@'", self.username];
    NSString *passwordString = [NSString stringWithFormat:@"'%@'", self.password];
    task.launchPath = @"/usr/bin/ssh";
    task.arguments = @[@"-q", self.sshHost, @"svn", @"update", path, @"--username", usernameString, @"--password", passwordString, @"--no-auth-cache"];
    task.standardOutput = pipe;
    
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    [file closeFile];
    NSString *svnOutput = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    [self appendToStatusView:svnOutput isError:NO];
    NSLog(@"Upddate status: %@", svnOutput);
    
}
-(IBAction)updateButtonPressed:(id)sender
{
    [self refreshSettings];
    NSIndexSet *indexSet = [self.fileListTable selectedRowIndexes];
    long currentIndex = [indexSet firstIndex];
    while (currentIndex != NSNotFound) {
        [self updateFileAtPath:[pathsToUpdate objectAtIndex:currentIndex]];
        currentIndex = [indexSet indexGreaterThanIndex: currentIndex];
    }
    [self updateFileList];
}
-(IBAction)refreshButtonPressed:(id)sender
{
    [self updateFileList];
}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.pathsToUpdate.count;
}

- (void)appendToStatusView:(NSString*)text isError:(BOOL)isError
{
    
        NSString *textToAppend = [NSString stringWithFormat:@"%@\n", text];
    if(isError){
        self.statusView.textColor = [NSColor colorWithSRGBRed:204/255.0f green:0.0f blue:0.0f alpha:1];
    } else {
        self.statusView.textColor = [NSColor colorWithSRGBRed:0.0f green:100.0f/255.0f blue:0.0f alpha:1];
    }
        [self.statusView insertText:textToAppend];
        [self.statusView scrollRangeToVisible:NSMakeRange([[self.statusView string] length], 0)];

}
- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    
    NSTextField *result = [tableView makeViewWithIdentifier:@"MyView" owner:self];
    if (result == nil) {
        
        result = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, tableColumn.width, 15)];
        [result setEditable:NO];
        result.identifier = @"MyView";
    }
    
    result.stringValue = [self.pathsToUpdate objectAtIndex:row];
    
    return result;
    
}
- (void)tableViewSelectionDidChange:(NSNotification *) notification
{
    NSIndexSet *selectedRows = [self.fileListTable selectedRowIndexes];
    if(selectedRows.count > 0){
        [selectedRows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            
            // *stop = YES; to stop iteration early
        }];
    }
}
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 25.0f;
}


@end
