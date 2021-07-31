#include "LCTTRootListController.h"

static NSString *prefsKeys = @"/var/mobile/Library/Preferences/me.luki.runtimeoverflow.lcttprefs.plist";


@implementation LCTTRootListController

- (NSArray *)specifiers {

	if (!_specifiers) {

		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];

		NSArray<NSString *> *items = [NSFileManager.defaultManager contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/Applications", [self bundle].resourcePath] error:NULL];
		if(items) for(NSString *item in items) {

			NSString *app = [item substringToIndex:[item rangeOfString:@"."].location];

			PSSpecifier* specifier = [PSSpecifier preferenceSpecifierNamed:app target:self set:NULL get:NULL detail:NSClassFromString(@"LCTTApplicationListController") cell:PSLinkListCell edit:NULL];
			[specifier setProperty:app forKey:@"Application"];
			[_specifiers addObject:specifier];

		}

	}

	return _specifiers;

}



- (void)viewDidLoad {

	[super viewDidLoad];

	((UITableView *)[self.view.subviews objectAtIndex:0]).keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

}

@end
