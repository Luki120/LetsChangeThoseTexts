#import <UIKit/UIKit.h>
#import <Preferences/PSListController.h>


@interface NSUserDefaults ()
- (void)setObject:(id)arg1 forKey:(id)arg2 inDomain:(id)arg3;
- (id)objectForKey:(id)arg1 inDomain:(id)arg2;
@end

@interface LCTTMessagesDelegate : NSObject <UITableViewDelegate, UITableViewDataSource> {
	
	UITableView *table;

}
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *messages;
- (void)addMessage:(NSString *)message byMe:(BOOL)me;
@end

@interface LCTTMessagesController : PSListController {

	UIView *bottomContainerView;
	NSLayoutConstraint *bottomContainerViewBottomAnchor;
	UITextField *textField;
	LCTTMessagesDelegate *delegate;
	UITableView *lcttTableView;

}
@property (nonatomic, strong) UIView *bottomBackgroundView;
@end


@implementation LCTTMessagesDelegate

@synthesize messages;

- (instancetype)initWithTableView:(UITableView *)tableView {
	
	self = [super init];

	table = tableView;
	self.messages = ((NSArray *) [NSUserDefaults.standardUserDefaults objectForKey:@"messages" inDomain:@"LCTTMessages"]).mutableCopy ?: [[NSMutableArray alloc] init];

	return self;

}

- (void)save {
	
	[NSUserDefaults.standardUserDefaults setObject:self.messages forKey:@"messages" inDomain:@"LCTTMessages"];
	[NSUserDefaults.standardUserDefaults synchronize];

}

- (void)addMessage:(NSString *)message byMe:(BOOL)me {

	[self.messages addObject:@{@"message": message, @"me": [NSNumber numberWithBool:me]}];
	[table insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
	[self save];

}

- (void)removeMessage:(NSUInteger)index {
	
	[self.messages removeObjectAtIndex:index];
	[table deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
	[self save];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

	return 1;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	return self.messages.count;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LCTTCell"];
	cell.backgroundColor = [UIColor clearColor];

	UIView *bubble = [[UIView alloc] init];
	bubble.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; // seems to be useless
	bubble.translatesAutoresizingMaskIntoConstraints = false;
	bubble.backgroundColor = UIColor.clearColor;
	bubble.clipsToBounds = true;
	bubble.layer.cornerRadius = 12;
	[cell addSubview:bubble];

	if(((NSNumber *) self.messages[indexPath.row][@"me"]).boolValue) [bubble.trailingAnchor constraintEqualToAnchor:cell.trailingAnchor constant:-12].active = true;
	else [bubble.leadingAnchor constraintEqualToAnchor:cell.leadingAnchor constant:12].active = true;
	[bubble.topAnchor constraintEqualToAnchor:cell.topAnchor constant:2].active = true;
	[bubble.bottomAnchor constraintEqualToAnchor:cell.bottomAnchor constant:-2].active = true;
	[bubble.widthAnchor constraintLessThanOrEqualToAnchor:cell.widthAnchor multiplier:0.6].active = true;

	UILabel *text = [[UILabel alloc] init];
	text.translatesAutoresizingMaskIntoConstraints = false;
	text.numberOfLines = 0;
	text.text = self.messages[indexPath.row][@"message"];
	if(text.text.length <= 0) text.text = @"​";
	[bubble addSubview:text];

	[text.leadingAnchor constraintEqualToAnchor:bubble.leadingAnchor constant:8].active = true;
	[text.trailingAnchor constraintEqualToAnchor:bubble.trailingAnchor constant:-8].active = true;
	[text.topAnchor constraintEqualToAnchor:bubble.topAnchor constant:4].active = true;
	[text.bottomAnchor constraintEqualToAnchor:bubble.bottomAnchor constant:-4].active = true;

	return cell;

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	UIColor *firstColor = ((NSNumber *) self.messages[indexPath.row][@"me"]).boolValue ? [UIColor colorWithRed: 0.48 green: 0.84 blue: 0.96 alpha: 1.00] : [UIColor colorWithRed: 0.84 green: 0.48 blue: 0.96 alpha: 1.00];
	UIColor *secondColor = ((NSNumber *) self.messages[indexPath.row][@"me"]).boolValue ? [UIColor colorWithRed: 0.47 green: 0.50 blue: 0.96 alpha: 1.00] : [UIColor colorWithRed: 0.50 green: 0.47 blue: 0.96 alpha: 1.00];
	
	[cell layoutIfNeeded];

	CAGradientLayer *gradient = [CAGradientLayer layer];
	gradient.frame = cell.subviews[0].bounds;
	gradient.startPoint = CGPointZero;
	gradient.endPoint = CGPointMake(1, 1);
	gradient.colors = [NSArray arrayWithObjects:(id)firstColor.CGColor, (id)secondColor.CGColor, nil];

	[cell.subviews[0].layer insertSublayer:gradient atIndex:0];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath:indexPath animated:true];

}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return ((NSNumber *) self.messages[indexPath.row][@"me"]).boolValue ? [UISwipeActionsConfiguration configurationWithActions:@[[UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction *action, __kindof UIView *sourceView, void (^completionHandler)(BOOL actionPerformed)) {
		[self removeMessage:indexPath.row];
		completionHandler(true);
	}]]] : [UISwipeActionsConfiguration configurationWithActions:@[]];

}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return !((NSNumber *) self.messages[indexPath.row][@"me"]).boolValue ? [UISwipeActionsConfiguration configurationWithActions:@[[UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction *action, __kindof UIView *sourceView, void (^completionHandler)(BOOL actionPerformed)) {
		[self removeMessage:indexPath.row];
		completionHandler(true);
	}]]] : [UISwipeActionsConfiguration configurationWithActions:@[]];

}

@end

@implementation LCTTMessagesController

- (void)viewDidLoad {

	[super viewDidLoad];
	[[self table] removeFromSuperview];

	if(self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) self.view.backgroundColor = UIColor.blackColor;
	else self.view.backgroundColor = UIColor.whiteColor;

	lcttTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
	lcttTableView.translatesAutoresizingMaskIntoConstraints = NO;	
	[self.viewIfLoaded addSubview:lcttTableView];

	delegate = [[LCTTMessagesDelegate alloc] initWithTableView:lcttTableView];
	lcttTableView.dataSource = delegate;
	lcttTableView.delegate = delegate;

	[lcttTableView.leadingAnchor constraintEqualToAnchor:self.viewIfLoaded.leadingAnchor].active = YES;
	[lcttTableView.trailingAnchor constraintEqualToAnchor:self.viewIfLoaded.trailingAnchor].active = YES;
	[lcttTableView.topAnchor constraintEqualToAnchor:self.viewIfLoaded.safeAreaLayoutGuide.topAnchor].active = YES;
	
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:NULL];
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:NULL];
	
	self.bottomBackgroundView = [[UIView alloc] init];
	self.bottomBackgroundView.translatesAutoresizingMaskIntoConstraints = false;
	if(self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) self.bottomBackgroundView.backgroundColor = UIColor.blackColor;
	else self.bottomBackgroundView.backgroundColor = UIColor.whiteColor;
	[self.viewIfLoaded addSubview:self.bottomBackgroundView];
	
	[self.bottomBackgroundView.leadingAnchor constraintEqualToAnchor:self.viewIfLoaded.leadingAnchor].active = true;
	[self.bottomBackgroundView.trailingAnchor constraintEqualToAnchor:self.viewIfLoaded.trailingAnchor].active = true;
	[self.bottomBackgroundView.bottomAnchor constraintEqualToAnchor:self.viewIfLoaded.bottomAnchor].active = true;
	
	[lcttTableView.bottomAnchor constraintEqualToAnchor:self.bottomBackgroundView.topAnchor].active = YES;

	bottomContainerView = [[UIView alloc] init];
	bottomContainerView.translatesAutoresizingMaskIntoConstraints = false;
	[self.bottomBackgroundView addSubview:bottomContainerView];
	
	[bottomContainerView.leadingAnchor constraintEqualToAnchor:self.bottomBackgroundView.leadingAnchor].active = true;
	[bottomContainerView.trailingAnchor constraintEqualToAnchor:self.bottomBackgroundView.trailingAnchor].active = true;
	[bottomContainerView.topAnchor constraintEqualToAnchor:self.bottomBackgroundView.topAnchor].active = true;
	[bottomContainerView.heightAnchor constraintEqualToConstant:64].active = true;
	
	bottomContainerViewBottomAnchor = [bottomContainerView.bottomAnchor constraintEqualToAnchor:self.viewIfLoaded.safeAreaLayoutGuide.bottomAnchor];
	bottomContainerViewBottomAnchor.active = true;
	
	UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
	leftButton.translatesAutoresizingMaskIntoConstraints = false;
	[leftButton setImage:[UIImage systemImageNamed:@"arrow.backward.circle.fill"] forState:UIControlStateNormal];
	[leftButton setPreferredSymbolConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:32] forImageInState:UIControlStateNormal];
	[leftButton addTarget:self action:@selector(sendLeft:) forControlEvents:UIControlEventPrimaryActionTriggered];
	[bottomContainerView addSubview:leftButton];
	
	[leftButton.leadingAnchor constraintEqualToAnchor:bottomContainerView.leadingAnchor constant:12].active = true;
	[leftButton.topAnchor constraintEqualToAnchor:bottomContainerView.topAnchor constant:12].active = true;
	[leftButton.bottomAnchor constraintEqualToAnchor:bottomContainerView.bottomAnchor constant:-12].active = true;
	[leftButton.widthAnchor constraintEqualToAnchor:leftButton.heightAnchor].active = true;
	
	UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
	rightButton.translatesAutoresizingMaskIntoConstraints = false;
	[rightButton setImage:[UIImage systemImageNamed:@"arrow.forward.circle.fill"] forState:UIControlStateNormal];
	[rightButton setPreferredSymbolConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:32] forImageInState:UIControlStateNormal];
	[rightButton addTarget:self action:@selector(sendRight:) forControlEvents:UIControlEventPrimaryActionTriggered];
	[bottomContainerView addSubview:rightButton];
	
	[rightButton.trailingAnchor constraintEqualToAnchor:bottomContainerView.trailingAnchor constant:-12].active = true;
	[rightButton.topAnchor constraintEqualToAnchor:bottomContainerView.topAnchor constant:12].active = true;
	[rightButton.bottomAnchor constraintEqualToAnchor:bottomContainerView.bottomAnchor constant:-12].active = true;
	[rightButton.widthAnchor constraintEqualToAnchor:rightButton.heightAnchor].active = true;
	
	textField = [[UITextField alloc] init];
	textField.translatesAutoresizingMaskIntoConstraints = false;
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.placeholder = @"Enter Message...";
	textField.textAlignment = NSTextAlignmentCenter;
	[bottomContainerView addSubview:textField];
	
	[textField.leadingAnchor constraintEqualToAnchor:leftButton.trailingAnchor constant:12].active = true;
	[textField.trailingAnchor constraintEqualToAnchor:rightButton.leadingAnchor constant:-12].active = true;
	[textField.centerXAnchor constraintEqualToAnchor:bottomContainerView.centerXAnchor].active = YES;
	[textField.centerYAnchor constraintEqualToAnchor:bottomContainerView.centerYAnchor].active = YES;


}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {

	if(self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {

		self.view.backgroundColor = UIColor.blackColor;
		self.bottomBackgroundView.backgroundColor = UIColor.blackColor;

	}

	else {

		self.view.backgroundColor = UIColor.whiteColor;
		self.bottomBackgroundView.backgroundColor = UIColor.whiteColor;
	
	}

}

- (void)sendLeft:(UIButton *)button {

	[textField resignFirstResponder];
	[delegate addMessage:textField.text byMe:false];
	textField.text = @"";

}

- (void)sendRight:(UIButton *)button {

	[textField resignFirstResponder];
	[delegate addMessage:textField.text byMe:true];
	textField.text = @"";

}

- (void)keyboardWillShow:(NSNotification *)notification {
	
	bottomContainerViewBottomAnchor.active = false;
	
	bottomContainerViewBottomAnchor = [bottomContainerView.bottomAnchor constraintEqualToAnchor:self.viewIfLoaded.bottomAnchor constant:-((NSValue *) notification.userInfo[UIKeyboardFrameEndUserInfoKey]).CGRectValue.size.height];
	bottomContainerViewBottomAnchor.active = true;

}

- (void)keyboardWillHide:(NSNotification *)notification {
	
	bottomContainerViewBottomAnchor.active = false;
	
	bottomContainerViewBottomAnchor = [bottomContainerView.bottomAnchor constraintEqualToAnchor:self.viewIfLoaded.safeAreaLayoutGuide.bottomAnchor];
	bottomContainerViewBottomAnchor.active = true;

}


@end