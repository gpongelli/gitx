//
//  PBCloneViewController.m
//  GitX
//
//  Created by Etienne on 02/03/2014.
//
//

#import "PBCloneViewController.h"

@interface PBCloneViewController ()
@property (strong) IBOutlet NSTextField *remoteURLField;
@property (strong) IBOutlet NSPathControl *localURLPath;
@end

@implementation PBCloneViewController

- (id)init {
    return [self initWithNibName:@"PBCloneViewController" bundle:[NSBundle mainBundle]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib
{
    [self.localURLPath setHidden:YES];
}

- (IBAction)chooseLocation:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];

    [panel setDelegate:self];
    [panel setAllowsMultipleSelection:NO];
	[panel setCanChooseDirectories:YES];
    [panel setAllowedFileTypes:@[@"git"]];

    if ([panel runModal] == NSFileHandlingPanelOKButton) {
        if ([panel.URL isFileURL]) {
            self.localURLPath.URL = panel.URL;
            [self.localURLPath setHidden:NO];
            self.remoteURLField.stringValue = @"";
            [self.remoteURLField setHidden:YES];
        } else {
            self.localURLPath.URL = nil;
            [self.localURLPath setHidden:YES];
            self.remoteURLField.stringValue = panel.URL.absoluteString;
            [self.remoteURLField setHidden:NO];
        }
    }
}

- (NSURL *)URL
{
    NSString *location = self.remoteURLField.stringValue;
    if (![location isEqualToString:@""])
        return [NSURL URLWithString:location];

    return self.localURLPath.URL;
}

#pragma mark -
#pragma mark NSOpenSavePanelDelegate

- (BOOL)panel:(id)sender validateURL:(NSURL *)url error:(NSError **)outError
{
    char out_path[MAXPATHLEN];
    int res = git_repository_discover(out_path, MAXPATHLEN, url.fileSystemRepresentation, 0, url.fileSystemRepresentation);
    if (res != GIT_OK) {
        if (outError) *outError = [NSError git_errorFor:res];
        return NO;
    }
    return YES;
}

@end
