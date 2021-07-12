#include "LCTTRootListController.h"

static NSString *prefsKeys = @"/var/mobile/Library/Preferences/me.luki.runtimeoverflow.lcttprefs.plist";


@implementation LCTTRootListController

- (NSArray *)specifiers {

	if (!_specifiers) {

		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	
	}

	return _specifiers;

}


- (instancetype)init {

    self = [super init];

    if (self) {


		self.killButton = [[UIBarButtonItem alloc] initWithTitle:@"Kill Instagram"
									style:UIBarButtonItemStylePlain
									target:self
									action:@selector(killInstagram:)];
		self.killButton.tintColor = [UIColor systemPinkColor];
		self.navigationItem.rightBarButtonItem = self.killButton;


    }

	return self;

}



- (void)viewDidLoad {

	[super viewDidLoad];

	((UITableView *)[self.view.subviews objectAtIndex:0]).keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

}


- (id)readPreferenceValue:(PSSpecifier*)specifier {

    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:prefsKeys]];
    return (settings[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];

}


- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {

    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:prefsKeys]];
    [settings setObject:value forKey:specifier.properties[@"key"]];
    [settings writeToFile:prefsKeys atomically:YES];

}


- (void)killInstagram:(id)sender {

    AudioServicesPlaySystemSound(1521);

    pid_t pid;
    const char* args[] = {"killall", "Instagram", NULL};
    posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);

}


- (void)shatterThePrefsToPieces {

	AudioServicesPlaySystemSound(1521);

	UIAlertController* resetAlert = [UIAlertController alertControllerWithTitle:@"LCTT"
	message:@"Do you want to start fresh?"
	preferredStyle:UIAlertControllerStyleAlert];
    
	UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"Shoot" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {

	NSError *error;
	NSFileManager *fileManager = [NSFileManager defaultManager];
        
	BOOL success = [fileManager removeItemAtPath:@"var/mobile/Library/Preferences/me.luki.runtimeoverflow.lcttprefs.plist" error:&error];
        
	if(success) [self killApps];
        
	}];

	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Meh" style:UIAlertActionStyleCancel handler:nil];

	[resetAlert addAction:confirmAction];
	[resetAlert addAction:cancelAction];

	[self presentViewController:resetAlert animated:YES completion:nil];


}


- (void)killApps {

	AudioServicesPlaySystemSound(1521);

	pid_t pid;
	const char* args[] = {"killall", "Preferences", NULL};
	posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);

}

@end