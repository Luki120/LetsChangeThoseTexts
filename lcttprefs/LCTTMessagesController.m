#import <UIKit/UIKit.h>
#import <Preferences/PSListController.h>

@interface NSUserDefaults ()
- (void)setObject:(id)arg1 forKey:(id)arg2 inDomain:(id)arg3;
- (id)objectForKey:(id)arg1 inDomain:(id)arg2;
@end

@interface LCTTMessagesDelegate : NSObject <UITableViewDelegate, UITableViewDataSource>{
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
@end

@implementation LCTTMessagesDelegate
@synthesize messages;

- (instancetype)initWithTableView:(UITableView *)tableView{
	self = [super init];

	table = tableView;
	self.messages = ((NSArray *) [NSUserDefaults.standardUserDefaults objectForKey:@"messages" inDomain:@"LCTTMessages"]).mutableCopy ?: [[NSMutableArray alloc] init];

	return self;
}

- (void)save{
	[NSUserDefaults.standardUserDefaults setObject:self.messages forKey:@"messages" inDomain:@"LCTTMessages"];
	//[[NSUserDefaults.standardUserDefaults persistentDomainForName:@"LCTTMessages"] writeToFile:@"/var/mobile/Library/Preferences/me.luki.runtimeoverflow.lcttmessages.plist" atomically:YES];
	[NSUserDefaults.standardUserDefaults synchronize];
}

- (void)addMessage:(NSString *)message byMe:(BOOL)me{
	[self.messages addObject:@{@"message": message, @"me": [NSNumber numberWithBool:me]}];
	[table insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
	[self save];
}

- (void)removeMessage:(NSUInteger)index{
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
	bubble.translatesAutoresizingMaskIntoConstraints = false;
	bubble.backgroundColor = [UIColor systemGrayColor];
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
	text.text = [NSString stringWithFormat:@"​%@", self.messages[indexPath.row][@"message"]];
	[bubble addSubview:text];

	[text.leadingAnchor constraintEqualToAnchor:bubble.leadingAnchor constant:8].active = true;
	[text.trailingAnchor constraintEqualToAnchor:bubble.trailingAnchor constant:-8].active = true;
	[text.topAnchor constraintEqualToAnchor:bubble.topAnchor constant:4].active = true;
	[text.bottomAnchor constraintEqualToAnchor:bubble.bottomAnchor constant:-4].active = true;

	return cell;

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
	return ((NSNumber *) self.messages[indexPath.row][@"me"]).boolValue ? [UISwipeActionsConfiguration configurationWithActions:@[[UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction *action, __kindof UIView *sourceView, void (^completionHandler)(BOOL actionPerformed)){
		[self removeMessage:indexPath.row];
		completionHandler(true);
	}]]] : [UISwipeActionsConfiguration configurationWithActions:@[]];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
	return !((NSNumber *) self.messages[indexPath.row][@"me"]).boolValue ? [UISwipeActionsConfiguration configurationWithActions:@[[UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction *action, __kindof UIView *sourceView, void (^completionHandler)(BOOL actionPerformed)){
		[self removeMessage:indexPath.row];
		completionHandler(true);
	}]]] : [UISwipeActionsConfiguration configurationWithActions:@[]];
}
@end

@implementation LCTTMessagesController

- (void)viewDidLoad {

	[super viewDidLoad];
	[[self table] removeFromSuperview];

	lcttTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
	lcttTableView.translatesAutoresizingMaskIntoConstraints = false;
	lcttTableView.backgroundColor = UIColor.systemGray6Color;	
	[self.viewIfLoaded addSubview:lcttTableView];

	delegate = [[LCTTMessagesDelegate alloc] initWithTableView:lcttTableView];
	lcttTableView.dataSource = delegate;
	lcttTableView.delegate = delegate;

	[lcttTableView.leadingAnchor constraintEqualToAnchor:self.viewIfLoaded.leadingAnchor].active = true;
	[lcttTableView.trailingAnchor constraintEqualToAnchor:self.viewIfLoaded.trailingAnchor].active = true;
	[lcttTableView.topAnchor constraintEqualToAnchor:self.viewIfLoaded.safeAreaLayoutGuide.topAnchor].active = true;
	
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:NULL];
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:NULL];
	
	UIView *bottomBackgroundView = [[UIView alloc] init];
	bottomBackgroundView.translatesAutoresizingMaskIntoConstraints = false;
	bottomBackgroundView.backgroundColor = UIColor.systemGray6Color;
	[self.viewIfLoaded addSubview:bottomBackgroundView];
	
	[bottomBackgroundView.leadingAnchor constraintEqualToAnchor:self.viewIfLoaded.leadingAnchor].active = true;
	[bottomBackgroundView.trailingAnchor constraintEqualToAnchor:self.viewIfLoaded.trailingAnchor].active = true;
	[bottomBackgroundView.bottomAnchor constraintEqualToAnchor:self.viewIfLoaded.bottomAnchor].active = true;
	
	[lcttTableView.bottomAnchor constraintEqualToAnchor:bottomBackgroundView.topAnchor].active = true;

	bottomContainerView = [[UIView alloc] init];
	bottomContainerView.translatesAutoresizingMaskIntoConstraints = false;
	[bottomBackgroundView addSubview:bottomContainerView];
	
	[bottomContainerView.leadingAnchor constraintEqualToAnchor:bottomBackgroundView.leadingAnchor].active = true;
	[bottomContainerView.trailingAnchor constraintEqualToAnchor:bottomBackgroundView.trailingAnchor].active = true;
	[bottomContainerView.topAnchor constraintEqualToAnchor:bottomBackgroundView.topAnchor].active = true;
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