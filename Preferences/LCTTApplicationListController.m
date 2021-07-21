#include "LCTTApplicationListController.h"
#import "LCTTMessagesController.h"


@implementation LCTTApplicationListController

- (NSArray *)specifiers {

	if (!_specifiers) {

		_specifiers = [self loadSpecifiersFromPlistName:[NSString stringWithFormat:@"Applications/%@", application] target:self];

		for(PSSpecifier *specifier in _specifiers) if(specifier.detailControllerClass == LCTTMessagesController.class) [specifier setProperty:application forKey:@"Application"];

	}

	return _specifiers;

}

-(void)setSpecifier:(PSSpecifier*)specifier {

	[super setSpecifier:specifier];

	application = [specifier propertyForKey:@"Application"];

}



- (void)viewDidLoad {

	[super viewDidLoad];

	((UITableView *)[self.view.subviews objectAtIndex:0]).keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

	UIBarButtonItem *killButton = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"Kill %@", application]
									style:UIBarButtonItemStylePlain
									target:self
									action:@selector(kill:)];
	killButton.tintColor = [UIColor colorWithRed: 0.84 green: 0.16 blue: 0.46 alpha: 1.00];
	self.navigationItem.rightBarButtonItem = killButton;

}


- (id)readPreferenceValue:(PSSpecifier*)specifier {

	NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/me.luki.runtimeoverflow.lctt%@.plist", application.lowercaseString]];
	return (settings[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];

}


- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {

	NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/me.luki.runtimeoverflow.lctt%@.plist", application.lowercaseString]];
	if(!settings) settings = [NSMutableDictionary dictionary];
	[settings setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/me.luki.runtimeoverflow.lctt%@.plist", application.lowercaseString] atomically:YES];

}


- (void)kill:(id)sender {

	AudioServicesPlaySystemSound(1521);

	pid_t pid;
	const char* args[] = {"killall", application.UTF8String, NULL};
	posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);

}


- (void)shatterThePrefsToPieces {

	AudioServicesPlaySystemSound(1521);

	UIAlertController* resetAlert = [UIAlertController alertControllerWithTitle:@"LCTT"
														message:@"Do you want to start fresh?"
														preferredStyle:UIAlertControllerStyleAlert];

	UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"Shoot" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {

  NSFileManager *fileManager = [NSFileManager defaultManager];
			
		[fileManager removeItemAtPath:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/me.luki.runtimeoverflow.lctt%@.plist", application.lowercaseString] error:NULL];
		[NSUserDefaults.standardUserDefaults removePersistentDomainForName:[NSString stringWithFormat:@"me.luki.runtimeoverflow.lctt%@messages", application.lowercaseString]];
		[NSUserDefaults.standardUserDefaults synchronize];

		[self.navigationController popViewControllerAnimated:true];
    
	}];

	UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Meh" style:UIAlertActionStyleCancel handler:nil];

	[resetAlert addAction:confirmAction];
	[resetAlert addAction:cancelAction];

	[self presentViewController:resetAlert animated:YES completion:nil];


}

- (void)blurEffect {

	_UIBackdropViewSettings *settings = [_UIBackdropViewSettings settingsForStyle:2];

	_UIBackdropView *backdropView = [[_UIBackdropView alloc] initWithSettings:settings];
	backdropView.layer.masksToBounds = YES;
	backdropView.clipsToBounds = YES;
	backdropView.alpha = 0;
	backdropView.frame = self.view.bounds;
	[self.view addSubview:backdropView];

	[UIView animateWithDuration:1.8 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{

		[backdropView setAlpha:1.0];

	} completion:^(BOOL finished) {

		[self killApps];

	}];

}


- (void)killApps {

	AudioServicesPlaySystemSound(1521);

	pid_t pid;
	const char* args[] = {"killall", "Preferences", NULL};
	posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);

}

@end