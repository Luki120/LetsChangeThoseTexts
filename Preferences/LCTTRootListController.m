#include "LCTTRootListController.h"

static NSString *prefsKeys = @"/var/mobile/Library/Preferences/me.luki.runtimeoverflow.lcttprefs.plist";

#define tint [UIColor colorWithRed: 0.84 green: 0.16 blue: 0.46 alpha: 1.00]


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


@implementation LCTTTableCell


- (void)tintColorDidChange {

	[super tintColorDidChange];

	self.textLabel.textColor = tint;
	self.textLabel.highlightedTextColor = tint;

}


- (void)refreshCellContentsWithSpecifier:(PSSpecifier *)specifier {

	[super refreshCellContentsWithSpecifier:specifier];

	if ([self respondsToSelector:@selector(tintColor)]) {

		self.textLabel.textColor = tint;
		self.textLabel.highlightedTextColor = tint;

	}
}

@end
