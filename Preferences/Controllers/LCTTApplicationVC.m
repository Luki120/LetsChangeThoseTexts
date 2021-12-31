#import "LCTTApplicationVC.h"


@implementation LCTTApplicationVC {

	NSString *application;

}


- (NSArray *)specifiers {

	if(!_specifiers) {

		_specifiers = [self loadSpecifiersFromPlistName:[NSString stringWithFormat:@"Applications/%@", application] target:self];

		for(PSSpecifier *specifier in _specifiers)

			if(specifier.detailControllerClass == LCTTMessagesVC.class)

				[specifier setProperty:application forKey:@"Application"];

	}

	return _specifiers;

}


- (void)setSpecifier:(PSSpecifier *)specifier {

	[super setSpecifier:specifier];

	application = [specifier propertyForKey:@"Application"];

}


- (void)viewDidLoad {

	[super viewDidLoad];

	((UITableView *)[self.view.subviews objectAtIndex:0]).keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

	UIBarButtonItem *killButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"Kill %@", application]
		style:UIBarButtonItemStylePlain
		target:self
		action:@selector(killApp)
	];

	if([application isEqualToString:@"Instagram"]) killButtonItem.tintColor = kIgTintColor;
	else if ([application isEqualToString:@"Twitter"]) killButtonItem.tintColor = kTwitterTintColor;
	self.navigationItem.rightBarButtonItem = killButtonItem;

}


- (void)killApp {

	AudioServicesPlaySystemSound(1521);

	pid_t pid;
	const char* args[] = {"killall", application.UTF8String, NULL};
	posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);

}


- (void)shatterThePrefsToPieces {

	AudioServicesPlaySystemSound(1521);

	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"LCTT" message:@"Do you want to start fresh?" preferredStyle:UIAlertControllerStyleAlert];

	UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Shoot" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {

		NSFileManager *fileManager = [NSFileManager defaultManager];

		[fileManager removeItemAtPath:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/me.luki.runtimeoverflow.lctt%@.plist", application.lowercaseString] error:NULL];
		[NSUserDefaults.standardUserDefaults removePersistentDomainForName:[NSString stringWithFormat:@"me.luki.runtimeoverflow.lctt%@messages", application.lowercaseString]];
		[NSUserDefaults.standardUserDefaults synchronize];

		[self crossDissolveBlur];

	}];

	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Meh" style:UIAlertActionStyleCancel handler:nil];

	[alertController addAction: confirmAction];
	[alertController addAction: cancelAction];

	[self presentViewController:alertController animated:YES completion:nil];


}


- (void)crossDissolveBlur {

	_UIBackdropViewSettings *settings = [_UIBackdropViewSettings settingsForStyle:2];

	_UIBackdropView *backdropView = [[_UIBackdropView alloc] initWithSettings:settings];
	backdropView.alpha = 0;
	backdropView.frame = self.view.bounds;
	backdropView.clipsToBounds = YES;
	backdropView.layer.masksToBounds = YES;
	[self.view addSubview:backdropView];

	[UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{

		backdropView.alpha = 1;

	} completion:^(BOOL finished) { [self popViewController]; }];

}


- (void)popViewController {

	[self.navigationController popViewControllerAnimated: YES];

	[self killApp];

}


- (id)readPreferenceValue:(PSSpecifier *)specifier {

	NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/me.luki.runtimeoverflow.lctt%@.plist", application.lowercaseString]];
	return (settings[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];

}


- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {

	NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/me.luki.runtimeoverflow.lctt%@.plist", application.lowercaseString]];
	if(!settings) settings = [NSMutableDictionary dictionary];
	[settings setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/me.luki.runtimeoverflow.lctt%@.plist", application.lowercaseString] atomically:YES];

}


#pragma mark Table View Data Source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath: indexPath];

	cell.textLabel.textColor = ([application isEqualToString:@"Instagram"]) ? kIgTintColor : kTwitterTintColor;
	cell.textLabel.highlightedTextColor = ([application isEqualToString:@"Instagram"]) ? kIgTintColor : kTwitterTintColor;

	return cell;

}


@end
