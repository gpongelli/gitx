//
//  PBCloneViewController.h
//  GitX
//
//  Created by Etienne on 02/03/2014.
//
//

#import <Cocoa/Cocoa.h>

@interface PBCloneViewController : NSViewController <NSOpenSavePanelDelegate>

@property (readonly) NSURL *URL;
@property (readonly, strong) IBOutlet NSTextField *remoteURLField;
@property (readonly, strong) IBOutlet NSPathControl *localURLPath;

- (IBAction)chooseLocation:(id)sender;

@end
