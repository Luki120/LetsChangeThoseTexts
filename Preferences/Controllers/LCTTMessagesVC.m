#import "LCTTMessagesVC.h"


@implementation LCTTMessagesDelegate {

	UITableView *table;
	NSString *application;
	NSMutableArray<NSDictionary *> *messages;

}


- (instancetype)initWithTableView:(UITableView *)tableView forApplication:(NSString *)app {

	self = [super init];

	if(self) {

		application = app;
		table = tableView;
		messages = ((NSArray *) [NSUserDefaults.standardUserDefaults objectForKey:@"messages" inDomain:[NSString stringWithFormat:@"me.luki.runtimeoverflow.lctt%@messages", application.lowercaseString]]).mutableCopy ?: [NSMutableArray new];

	}

	return self;

}


- (void)save {

	[NSUserDefaults.standardUserDefaults setObject:messages forKey:@"messages" inDomain:[NSString stringWithFormat:@"me.luki.runtimeoverflow.lctt%@messages", application.lowercaseString]];
	[NSUserDefaults.standardUserDefaults synchronize];

}


- (void)addMessage:(NSString *)message byMe:(BOOL)me {

	[messages addObject:@{@"message": message, @"me": [NSNumber numberWithBool: me]}];
	[table insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:messages.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
	[self save];

}


- (void)removeMessage:(NSUInteger)index {

	[messages removeObjectAtIndex:index];
	[table deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
	[self save];

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	return messages.count;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LCTTCell"];
	cell.backgroundColor = UIColor.clearColor;

	UIView *bubbleView = [UIView new];
	bubbleView.clipsToBounds = YES;
	bubbleView.backgroundColor = UIColor.clearColor;
	bubbleView.translatesAutoresizingMaskIntoConstraints = NO;
	bubbleView.layer.cornerCurve = kCACornerCurveContinuous;
	bubbleView.layer.cornerRadius = 12;
	[cell.contentView addSubview: bubbleView];

	if(((NSNumber *) messages[indexPath.row][@"me"]).boolValue) [bubbleView.trailingAnchor constraintEqualToAnchor : cell.trailingAnchor constant : -12].active = true;
	else [bubbleView.leadingAnchor constraintEqualToAnchor : cell.contentView.leadingAnchor constant : 12].active = true;
	[bubbleView.topAnchor constraintEqualToAnchor : cell.contentView.topAnchor constant : 2].active = true;
	[bubbleView.bottomAnchor constraintEqualToAnchor : cell.contentView.bottomAnchor constant : -2].active = true;
	[bubbleView.widthAnchor constraintLessThanOrEqualToAnchor : cell.contentView.widthAnchor multiplier : 0.6].active = true;

	UILabel *textLabel = [UILabel new];
	textLabel.text = messages[indexPath.row][@"message"];
	textLabel.numberOfLines = 0;
	textLabel.translatesAutoresizingMaskIntoConstraints = NO;
	if(textLabel.text.length <= 0) textLabel.text = @"​";
	[bubbleView addSubview: textLabel];

	[textLabel.topAnchor constraintEqualToAnchor : bubbleView.topAnchor constant : 4].active = true;
	[textLabel.bottomAnchor constraintEqualToAnchor : bubbleView.bottomAnchor constant : -4].active = true;
	[textLabel.leadingAnchor constraintEqualToAnchor : bubbleView.leadingAnchor constant : 8].active = true;
	[textLabel.trailingAnchor constraintEqualToAnchor : bubbleView.trailingAnchor constant : -8].active = true;

	return cell;

}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

	UIColor *igFirstColor = ((NSNumber *) messages[indexPath.row][@"me"]).boolValue ? [UIColor colorWithRed: 0.48 green: 0.84 blue: 0.96 alpha: 1.0] : [UIColor colorWithRed: 0.84 green: 0.48 blue: 0.96 alpha: 1.0];
	UIColor *igSecondColor = ((NSNumber *) messages[indexPath.row][@"me"]).boolValue ? [UIColor colorWithRed: 0.47 green: 0.50 blue: 0.96 alpha: 1.0] : [UIColor colorWithRed: 0.50 green: 0.47 blue: 0.96 alpha: 1.0];
	UIColor *twitterFirstColor = ((NSNumber *) messages[indexPath.row][@"me"]).boolValue ? [UIColor colorWithRed: 0.16 green: 0.98 blue: 0.87 alpha: 1.0] : [UIColor colorWithRed: 0.40 green: 0.99 blue: 0.94 alpha: 1.0];
	UIColor *twitterSecondColor = ((NSNumber *) messages[indexPath.row][@"me"]).boolValue ? [UIColor colorWithRed: 0.30 green: 0.51 blue: 1.00 alpha: 1.0] : [UIColor colorWithRed: 0.11 green: 0.44 blue: 0.64 alpha: 1.0];

	[cell layoutIfNeeded];

	CAGradientLayer *gradient = [CAGradientLayer layer];
	gradient.frame = cell.contentView.subviews[0].bounds;
	gradient.startPoint = CGPointZero;
	gradient.endPoint = CGPointMake(1, 1);
	if([application isEqualToString:@"Instagram"]) gradient.colors = [NSArray arrayWithObjects:(id)igFirstColor.CGColor, (id)igSecondColor.CGColor, nil];
	else if([application isEqualToString:@"Twitter"]) gradient.colors = [NSArray arrayWithObjects:(id)twitterFirstColor.CGColor, (id)twitterSecondColor.CGColor, nil];
	[cell.contentView.subviews[0].layer insertSublayer:gradient atIndex:0];

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	[tableView deselectRowAtIndexPath: indexPath animated: true];

}


- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {

	return !((NSNumber *) messages[indexPath.row][@"me"]).boolValue ? [UISwipeActionsConfiguration configurationWithActions:@[[UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction *action, __kindof UIView *sourceView, void (^completionHandler)(BOOL actionPerformed)) {

		[self removeMessage:indexPath.row];
		completionHandler(true);

	}]]] : [UISwipeActionsConfiguration configurationWithActions:@[]];

}


- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {

	return ((NSNumber *) messages[indexPath.row][@"me"]).boolValue ? [UISwipeActionsConfiguration configurationWithActions:@[[UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction *action, __kindof UIView *sourceView, void (^completionHandler)(BOOL actionPerformed)) {

		[self removeMessage:indexPath.row];
		completionHandler(true);

	}]]] : [UISwipeActionsConfiguration configurationWithActions:@[]];

}


@end


@implementation LCTTMessagesVC {

	NSString *application;
	UITableView *lcttTableView;
	UIStackView *bottomStackView;
	NSLayoutConstraint *bottomAnchorConstraint;
	UIButton *leftButton;
	UIButton *rightButton;
	UITextField *messagesTextField;
	LCTTMessagesDelegate *delegate;

}


- (id)init {

	self = [super init];

	if(self) {

		[NSNotificationCenter.defaultCenter removeObserver:self];
		[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:NULL];
		[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:NULL];

	}

	return self;

}


- (void)viewDidLoad {

	[super viewDidLoad];

	// do any additional setup after loading the view, typically from a nib.

	[self setupUI];

}


- (void)viewWillAppear:(BOOL)animated {

	[super viewWillAppear: animated];

	self.navigationController.navigationController.navigationBar.translucent = NO;
	self.navigationController.navigationController.navigationBar.barTintColor = UIColor.blackColor;

}


- (void)viewWillDisappear:(BOOL)animated {

	[super viewWillDisappear: animated];

	self.navigationController.navigationController.navigationBar.translucent = YES;
	self.navigationController.navigationController.navigationBar.barTintColor = nil;

}


- (void)setSpecifier:(PSSpecifier *)specifier {

	[super setSpecifier: specifier];
	application = [specifier propertyForKey:@"Application"];

}


- (void)setupUI {

	[self.table removeFromSuperview];

	lcttTableView = [UITableView new];
	lcttTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	lcttTableView.backgroundColor = UIColor.systemBackgroundColor;
	lcttTableView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.viewIfLoaded addSubview: lcttTableView];

	delegate = [[LCTTMessagesDelegate alloc] initWithTableView: lcttTableView forApplication: application];
	lcttTableView.dataSource = delegate;
	lcttTableView.delegate = delegate;
	lcttTableView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0); // haha hacky solution goes brr

	bottomStackView = [UIStackView new];
	bottomStackView.axis = UILayoutConstraintAxisHorizontal;
	bottomStackView.spacing = 10;
	bottomStackView.alignment = UIStackViewAlignmentCenter;
	bottomStackView.distribution = UIStackViewDistributionFill;
	bottomStackView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.viewIfLoaded addSubview: bottomStackView];

	UIImageSymbolConfiguration *configuration = [UIImageSymbolConfiguration configurationWithPointSize: 32];
	UIImage *leftButtonImage = [UIImage systemImageNamed:@"arrow.backward.circle.fill" withConfiguration: configuration];
	UIImage *rightButtonImage = [UIImage systemImageNamed:@"arrow.forward.circle.fill" withConfiguration: configuration];

	leftButton = [UIButton new];
	leftButton.tintColor = ([application isEqualToString:@"Instagram"]) ? kIgTintColor : kTwitterTintColor;
	leftButton.translatesAutoresizingMaskIntoConstraints = NO;
	[leftButton setImage: leftButtonImage forState: UIControlStateNormal];
	[leftButton addTarget: self action:@selector(sendLeft) forControlEvents: UIControlEventPrimaryActionTriggered];
	[bottomStackView addArrangedSubview: leftButton];

	messagesTextField = [UITextField new];
	messagesTextField.delegate = self;
	messagesTextField.placeholder = @"Enter Message...";
	messagesTextField.textAlignment = NSTextAlignmentCenter;
	messagesTextField.layer.borderWidth = 1.0f;
	messagesTextField.layer.borderColor = UIColor.blackColor.CGColor;
	[bottomStackView addArrangedSubview: messagesTextField];

	rightButton = [UIButton new];
	rightButton.tintColor = ([application isEqualToString:@"Instagram"]) ? kIgTintColor : kTwitterTintColor;
	rightButton.translatesAutoresizingMaskIntoConstraints = NO;
	[rightButton setImage: rightButtonImage forState: UIControlStateNormal];
	[rightButton addTarget: self action:@selector(sendRight) forControlEvents: UIControlEventPrimaryActionTriggered];
	[bottomStackView addArrangedSubview: rightButton];

	[self layoutUI];

}


- (void)layoutUI {

	[lcttTableView.topAnchor constraintEqualToAnchor : self.viewIfLoaded.safeAreaLayoutGuide.topAnchor].active = YES;
	[lcttTableView.bottomAnchor constraintEqualToAnchor : bottomStackView.topAnchor].active = YES;
	[lcttTableView.leadingAnchor constraintEqualToAnchor : self.viewIfLoaded.leadingAnchor].active = YES;
	[lcttTableView.trailingAnchor constraintEqualToAnchor : self.viewIfLoaded.trailingAnchor].active = YES;

	[bottomStackView.topAnchor constraintEqualToAnchor : lcttTableView.bottomAnchor].active = true;
	[bottomStackView.leadingAnchor constraintEqualToAnchor : self.viewIfLoaded.leadingAnchor constant : 20].active = true;
	[bottomStackView.trailingAnchor constraintEqualToAnchor : self.viewIfLoaded.trailingAnchor constant : -20].active = true;

	bottomAnchorConstraint = [bottomStackView.bottomAnchor constraintEqualToAnchor : self.view.safeAreaLayoutGuide.bottomAnchor constant : -15];
	bottomAnchorConstraint.active = true;

	[leftButton.widthAnchor constraintEqualToAnchor : leftButton.heightAnchor].active = true;
	[rightButton.widthAnchor constraintEqualToAnchor : rightButton.heightAnchor].active = true;

}


- (void)sendLeft {

	[messagesTextField resignFirstResponder];
	[delegate addMessage:messagesTextField.text byMe:false];
	messagesTextField.text = @"";

}

- (void)sendRight {

	[messagesTextField resignFirstResponder];
	[delegate addMessage:messagesTextField.text byMe:true];
	messagesTextField.text = @"";

}

- (void)keyboardWillShow:(NSNotification *)notification {

	bottomAnchorConstraint.active = false;

	bottomAnchorConstraint = [bottomStackView.bottomAnchor constraintEqualToAnchor : self.viewIfLoaded.bottomAnchor constant : -((NSValue *) notification.userInfo[UIKeyboardFrameEndUserInfoKey]).CGRectValue.size.height];
	bottomAnchorConstraint.active = true;

}

- (void)keyboardWillHide:(NSNotification *)notification {

	bottomAnchorConstraint.active = false;

	bottomAnchorConstraint = [bottomStackView.bottomAnchor constraintEqualToAnchor : self.viewIfLoaded.safeAreaLayoutGuide.bottomAnchor constant : -15];
	bottomAnchorConstraint.active = true;

}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {

	[textField resignFirstResponder];

	return YES;

}


@end
