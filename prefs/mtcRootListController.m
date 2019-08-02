#include "mtcRootListController.h"
#include <spawn.h>

@implementation mtcRootListController
@synthesize respringButton;

- (instancetype)init {

	self = [super init];

	if (self) {

		self.respringButton = [[UIBarButtonItem alloc] initWithTitle:@"Respring"

			style:UIBarButtonItemStylePlain
			target:self
			action:@selector(respring)];

		self.respringButton.tintColor = [UIColor blackColor];

		self.navigationItem.rightBarButtonItem = self.respringButton;

	}

	return self;

}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

- (void)respring {

	pid_t pid;

	int status;

	const char* args[] = {"killall", "-9", "backboardd", NULL};

	posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);

	waitpid(pid, &status, WEXITED);

}

- (void)twitter {

	[[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"https://twitter.com/mtac8"]];

}

- (void)donate {

	[[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"https://paypal.me/mtac"]]; 

}

@end
