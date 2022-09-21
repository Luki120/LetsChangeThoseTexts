#import "LCTTRootVC.h"


@implementation LCTTRootVC

- (NSArray *)specifiers {

	if(_specifiers) return nil;
	_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];

	NSArray *items = [NSFileManager.defaultManager contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/Applications", [self bundle].resourcePath] error:NULL];

	if(items) for(NSString *item in items) {

		NSString *app = [item substringToIndex:[item rangeOfString:@"."].location];

		PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:app target:self set:NULL get:NULL detail:NSClassFromString(@"LCTTApplicationVC") cell:PSLinkListCell edit:NULL];
		[specifier setProperty:app forKey:@"Application"];
		[_specifiers addObject: specifier];

	}

	return _specifiers;

}

@end
