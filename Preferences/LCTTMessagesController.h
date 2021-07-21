#import <UIKit/UIKit.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>


@interface NSUserDefaults ()
- (void)setObject:(id)arg1 forKey:(id)arg2 inDomain:(id)arg3;
- (id)objectForKey:(id)arg1 inDomain:(id)arg2;
@end

@interface LCTTMessagesDelegate : NSObject <UITableViewDelegate, UITableViewDataSource> {
	
	NSString *application;
	UITableView *table;

}

@property (nonatomic, strong) NSMutableArray<NSDictionary *> *messages;
- (void)addMessage:(NSString *)message byMe:(BOOL)me;
@end

@interface LCTTMessagesController : PSListController {

	NSString *application;

	UIView *bottomContainerView;
	NSLayoutConstraint *bottomContainerViewBottomAnchor;
	UITextField *textField;
	LCTTMessagesDelegate *delegate;
	UITableView *lcttTableView;

}

@property (nonatomic, strong) UIView *bottomBackgroundView;
@end