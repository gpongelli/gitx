//
//  PBRepositoryDocumentController.mm
//  GitX
//
//  Created by Ciarán Walsh on 15/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PBRepositoryDocumentController.h"
#import "PBGitRepository.h"
#import "PBGitRevList.h"
#import "PBEasyPipe.h"
#import "PBGitBinary.h"
#import "GitRepoFinder.h"
#import "PBCloneViewController.h"

#import <ObjectiveGit/GTRepository.h>

@implementation PBRepositoryDocumentController

- (void)cloneDocument:(id)sender {
	NSSavePanel *panel = [NSSavePanel savePanel];

	PBCloneViewController *cloneViewController = [[PBCloneViewController alloc] init];

	[panel setTitle:@"Clone Repository"];
	[panel setMessage:@"Choose the repository to clone and where to put it"];
	[panel setNameFieldLabel:@"Repository name:"];
	[panel setPrompt:@"Clone"];
	[panel setAccessoryView:cloneViewController.view];

	if ([panel runModal] != NSFileHandlingPanelOKButton) {
		return;
	}

	NSURL *localURL = panel.URL;
	NSURL *cloneURL = cloneViewController.URL;

	NSError *error = nil;
	BOOL success = [GTRepository cloneFromURL:cloneURL toWorkingDirectory:localURL options:nil error:&error transferProgressBlock:^(const git_transfer_progress *progress) {

	} checkoutProgressBlock:^(NSString *path, NSUInteger completedSteps, NSUInteger totalSteps) {

	}];

	if (!success) {
		[self presentError:error];
		return;
	}

	PBGitRepository *repo = [[PBGitRepository alloc] initWithContentsOfURL:localURL ofType:PBGitRepositoryDocumentType error:&error];
	if (!repo) {
		[self presentError:error];
		return;
	}

	[self addDocument:repo];
	[repo makeWindowControllers];
	[repo showWindows];
}

// This method is overridden to configure the open panel to only allow
// selection of directories
- (NSInteger)runModalOpenPanel:(NSOpenPanel *)openPanel forTypes:(NSArray *)extensions
{
	[openPanel setCanChooseFiles:NO];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setAllowedFileTypes:[NSArray arrayWithObject:@"git"]];
	return [openPanel runModal];
}

- (id)makeUntitledDocumentOfType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
	NSOpenPanel *op = [NSOpenPanel openPanel];

	[op setCanChooseFiles:NO];
	[op setCanChooseDirectories:YES];
	[op setAllowsMultipleSelection:NO];
	[op setTitle:@"Create Repository"];
	[op setMessage:@"Choose the name and location of the repository:"];
	[op setNameFieldLabel:@"Repository name:"];
	[op setPrompt:@"Create"];
	// TODO: Bare setting ?
	if ([op runModal] != NSFileHandlingPanelOKButton) {
		*outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil];
		return nil;
	}

	BOOL success = [GTRepository initializeEmptyRepositoryAtFileURL:[op URL] error:outError];
	if (!success)
		return nil; // Repo creation failed

	return [[PBGitRepository alloc] initWithContentsOfURL:[op URL] ofType:PBGitRepositoryDocumentType error:outError];
}

- (BOOL)validateMenuItem:(NSMenuItem *)item
{
	if ([item action] == @selector(newDocument:))
		return ([PBGitBinary path] != nil);
	return [super validateMenuItem:item];
}

@end
