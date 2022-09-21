#import "LCTTApplicationVC.h"


@implementation LCTTApplicationVC {

	NSString *application;

}

#define kAppDictionary [NSString stringWithFormat:@"/var/mobile/Library/Preferences/me.luki.runtimeoverflow.lctt%@.plist", application.lowercaseString]

- (NSArray *)specifiers {

	if(_specifiers) return nil;
	_specifiers = [self loadSpecifiersFromPlistName:[NSString stringWithFormat:@"Applications/%@", application] target:self];

	for(PSSpecifier *specifier in _specifiers)

		if(specifier.detailControllerClass == [LCTTMessagesVC class])

			[specifier setProperty:application forKey:@"Application"];

	return _specifiers;

}


- (void)setSpecifier:(PSSpecifier *)specifier {

	[super setSpecifier: specifier];
	application = [specifier propertyForKey:@"Application"];

}


- (void)viewDidLoad {

	[super viewDidLoad];
	self.table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

	UIBarButtonItem *killButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"Kill %@", application]
		style:UIBarButtonItemStylePlain
		target:self
		action:@selector(didTapKillAppButton)
	];
	killButtonItem.tintColor = [application isEqualToString: @"Instagram"] ? kIgTintColor : kTwitterTintColor;
	self.navigationItem.rightBarButtonItem = killButtonItem;

}


- (void)didTapKillAppButton {

	AudioServicesPlaySystemSound(1521);

	pid_t pid;
	const char* args[] = {"killall", application.UTF8String, NULL};
	posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);

}


- (void)shatterThePrefsToPieces {

	AudioServicesPlaySystemSound(1521);

	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"LCTT" message:@"Do you want to start fresh?" preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Shoot" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

		[[NSFileManager defaultManager] removeItemAtPath:kAppDictionary error: nil];
		[NSUserDefaults.standardUserDefaults removePersistentDomainForName: kPersistentDomainName];

		[self crossDissolveBlur];

	}];
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Meh" style:UIAlertActionStyleDefault handler:nil];

	[alertController addAction: confirmAction];
	[alertController addAction: cancelAction];

	[self presentViewController:alertController animated:YES completion:nil];

}


- (void)crossDissolveBlur {

	_UIBackdropViewSettings *settings = [_UIBackdropViewSettings settingsForStyle:2];

	_UIBackdropView *backdropView = [[_UIBackdropView alloc] initWithFrame:CGRectZero autosizesToFitSuperview:YES settings:settings];
	backdropView.alpha = 0;
	backdropView.clipsToBounds = YES;
	[self.view addSubview: backdropView];

	[UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{

		backdropView.alpha = 1;

	} completion:^(BOOL finished) { [self popVC]; }];

}


- (void)popVC {

	[self.navigationController popViewControllerAnimated: YES];
	[self didTapKillAppButton];

}


- (id)readPreferenceValue:(PSSpecifier *)specifier {

	NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile: kAppDictionary];
	return settings[specifier.properties[@"key"]] ?: specifier.properties[@"default"];

}


- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {

	NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile: kAppDictionary];
	if(!settings) settings = [NSMutableDictionary dictionary];
	[settings setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:kAppDictionary atomically:YES];

	[super setPreferenceValue:value specifier: specifier];

}


// ! UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath: indexPath];
	cell.textLabel.textColor = [application isEqualToString:@"Instagram"] ? kIgTintColor : kTwitterTintColor;
	return cell;

}

@end
