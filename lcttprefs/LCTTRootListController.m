#include "LCTTRootListController.h"


@implementation LCTTRootListController

- (NSArray *)specifiers {

	if (!_specifiers) {

		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	
	}

	return _specifiers;

}


- (void)viewDidLoad {

	[super viewDidLoad];

	((UITableView *)[self.view.subviews objectAtIndex:0]).keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

}

@end