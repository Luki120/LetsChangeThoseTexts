#import "LCTTMessagesVC.h"


@implementation LCTTMessagesDelegate {

	BOOL _isByMe;
	UIView *bubbleView;
	UITableView *table;
	NSString *application;
	NSMutableArray<NSDictionary *> *messages;

}

#define isByMe ((NSNumber *) messages[indexPath.row][@"me"]).boolValue

- (id)initWithTableView:(UITableView *)tableView forApplication:(NSString *)app {

	self = [super init];
	if(!self) return nil;

	application = app;
	table = tableView;
	messages = ((NSArray *) [NSUserDefaults.standardUserDefaults objectForKey:@"messages" inDomain: kPersistentDomainName]).mutableCopy ?: [NSMutableArray new];

	return self;

}


- (void)addMessage:(NSString *)message byMe:(BOOL)me {

	[messages addObject:@{ @"message": message, @"me": [NSNumber numberWithBool: me] }];
	[table insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:messages.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
	[self saveDefaults];

}


- (void)removeMessage:(NSUInteger)index {

	[messages removeObjectAtIndex: index];
	[table deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
	[self saveDefaults];

}


- (void)saveDefaults {

	[NSUserDefaults.standardUserDefaults setObject:messages forKey:@"messages" inDomain: kPersistentDomainName];

}

// ! UI

- (void)setupBubbleView {

	bubbleView = [UIView new];
	bubbleView.clipsToBounds = YES;
	bubbleView.backgroundColor = UIColor.clearColor;
	bubbleView.translatesAutoresizingMaskIntoConstraints = NO;
	bubbleView.layer.cornerCurve = kCACornerCurveContinuous;
	bubbleView.layer.cornerRadius = 12;

}


- (void)setupBubbleGradientLayer {

	UIColor const *igFirstColor = _isByMe ? [UIColor colorWithRed:0.48 green:0.84 blue:0.96 alpha: 1.0] : [UIColor colorWithRed:0.84 green:0.48 blue:0.96 alpha: 1.0];
	UIColor const *igSecondColor = _isByMe ? [UIColor colorWithRed:0.47 green:0.50 blue:0.96 alpha: 1.0] : [UIColor colorWithRed:0.50 green:0.47 blue:0.96 alpha: 1.0];
	UIColor const *twitterFirstColor = _isByMe ? [UIColor colorWithRed:0.16 green:0.98 blue:0.87 alpha: 1.0] : [UIColor colorWithRed:0.40 green:0.99 blue:0.94 alpha: 1.0];
	UIColor const *twitterSecondColor = _isByMe ? [UIColor colorWithRed:0.30 green:0.51 blue:1.0 alpha: 1.0] : [UIColor colorWithRed:0.11 green:0.44 blue:0.64 alpha: 1.0];

	NSArray *igColors = [NSArray arrayWithObjects:(id)igFirstColor.CGColor, (id)igSecondColor.CGColor, nil];
	NSArray *twitterColors = [NSArray arrayWithObjects:(id)twitterFirstColor.CGColor, (id)twitterSecondColor.CGColor, nil];

	CAGradientLayer *gradientLayer = [CAGradientLayer layer];
	gradientLayer.frame = bubbleView.bounds;
	gradientLayer.startPoint = CGPointZero;
	gradientLayer.endPoint = CGPointMake(1, 1);
	gradientLayer.colors = [application isEqualToString:@"Instagram"] ? igColors : twitterColors;
	[bubbleView.layer insertSublayer:gradientLayer atIndex:0];

}

// ! UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	return messages.count;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: @"LCTTCell"];
	cell.backgroundColor = UIColor.clearColor;

	[self setupBubbleView];
	[cell.contentView addSubview: bubbleView];

	if(isByMe) [bubbleView.trailingAnchor constraintEqualToAnchor: cell.trailingAnchor constant: -12].active = true;
	else [bubbleView.leadingAnchor constraintEqualToAnchor: cell.contentView.leadingAnchor constant: 12].active = true;
	[bubbleView.topAnchor constraintEqualToAnchor: cell.contentView.topAnchor constant: 2].active = true;
	[bubbleView.bottomAnchor constraintEqualToAnchor: cell.contentView.bottomAnchor constant: -2].active = true;
	[bubbleView.widthAnchor constraintLessThanOrEqualToAnchor: cell.contentView.widthAnchor multiplier: 0.6].active = true;

	UILabel *textLabel = [UILabel new];
	textLabel.text = messages[indexPath.row][@"message"];
	textLabel.numberOfLines = 0;
	textLabel.translatesAutoresizingMaskIntoConstraints = NO;
	if(textLabel.text.length <= 0) textLabel.text = @"​";
	[bubbleView addSubview: textLabel];

	[textLabel.topAnchor constraintEqualToAnchor: bubbleView.topAnchor constant: 4].active = true;
	[textLabel.bottomAnchor constraintEqualToAnchor: bubbleView.bottomAnchor constant: -4].active = true;
	[textLabel.leadingAnchor constraintEqualToAnchor: bubbleView.leadingAnchor constant: 8].active = true;
	[textLabel.trailingAnchor constraintEqualToAnchor: bubbleView.trailingAnchor constant: -8].active = true;

	return cell;

}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

	_isByMe = isByMe;

	[cell layoutIfNeeded];
	[self setupBubbleGradientLayer];

}

// ! UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	[tableView deselectRowAtIndexPath:indexPath animated: true];

}


- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {

	return !isByMe ? [UISwipeActionsConfiguration configurationWithActions:@[[self deleteActionForRowAtIndexPath: indexPath]]] : nil;

}


- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {

	return isByMe ? [UISwipeActionsConfiguration configurationWithActions:@[[self deleteActionForRowAtIndexPath: indexPath]]] : nil;

}


- (UIContextualAction *)deleteActionForRowAtIndexPath:(NSIndexPath *)indexPath {

	UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Delete" handler:^(UIContextualAction *action, UIView *sourceView, void(^completionHandler)(BOOL actionPerformed)) {

		[self removeMessage: indexPath.row];
		completionHandler(true);

	}];

	deleteAction.backgroundColor = [application isEqualToString: @"Instagram"] ? UIColor.systemPurpleColor : UIColor.systemTealColor; 

	return deleteAction;

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
	if(!self) return nil;

	[NSNotificationCenter.defaultCenter removeObserver:self];
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:NULL];
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:NULL];

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

	delegate = [[LCTTMessagesDelegate alloc] initWithTableView:lcttTableView forApplication: application];
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

	leftButton = [self createButtonWithImage:leftButtonImage forSelector: @selector(didTapSendLeftButton)];

	messagesTextField = [UITextField new];
	messagesTextField.delegate = self;
	messagesTextField.placeholder = @"Enter Message...";
	messagesTextField.textAlignment = NSTextAlignmentCenter;
	messagesTextField.layer.borderWidth = 1.0f;
	messagesTextField.layer.borderColor = UIColor.blackColor.CGColor;
	[bottomStackView addArrangedSubview: messagesTextField];

	rightButton = [self createButtonWithImage:rightButtonImage forSelector: @selector(didTapSendRightButton)];

	[self layoutUI];

}


- (void)layoutUI {

	[lcttTableView.topAnchor constraintEqualToAnchor: self.viewIfLoaded.safeAreaLayoutGuide.topAnchor].active = YES;
	[lcttTableView.bottomAnchor constraintEqualToAnchor: bottomStackView.topAnchor].active = YES;
	[lcttTableView.leadingAnchor constraintEqualToAnchor: self.viewIfLoaded.leadingAnchor].active = YES;
	[lcttTableView.trailingAnchor constraintEqualToAnchor: self.viewIfLoaded.trailingAnchor].active = YES;

	[bottomStackView.leadingAnchor constraintEqualToAnchor: self.viewIfLoaded.leadingAnchor constant: 20].active = true;
	[bottomStackView.trailingAnchor constraintEqualToAnchor: self.viewIfLoaded.trailingAnchor constant: -20].active = true;

	bottomAnchorConstraint = [bottomStackView.bottomAnchor constraintEqualToAnchor: self.view.safeAreaLayoutGuide.bottomAnchor];
	bottomAnchorConstraint.active = true;

	[leftButton.widthAnchor constraintEqualToAnchor: leftButton.heightAnchor].active = true;
	[rightButton.widthAnchor constraintEqualToAnchor: rightButton.heightAnchor].active = true;

}


- (void)didTapSendLeftButton { [self sendMessageAsMe: false]; }
- (void)didTapSendRightButton { [self sendMessageAsMe: true]; }


- (void)keyboardWillShow:(NSNotification *)notification {

	[self setupBottomAnchorConstraint: [bottomStackView.bottomAnchor constraintEqualToAnchor: self.viewIfLoaded.bottomAnchor constant: -((NSValue *) notification.userInfo[UIKeyboardFrameEndUserInfoKey]).CGRectValue.size.height]];

}


- (void)keyboardWillHide:(NSNotification *)notification {

	[self setupBottomAnchorConstraint: [bottomStackView.bottomAnchor constraintEqualToAnchor: self.viewIfLoaded.safeAreaLayoutGuide.bottomAnchor]];

}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {

	[textField resignFirstResponder];
	return YES;

}


// ! Reusable

- (UIButton *)createButtonWithImage:(UIImage *)image forSelector:(SEL)selector {

	UIButton *button = [UIButton new];
	button.tintColor = [application isEqualToString:@"Instagram"] ? kIgTintColor : kTwitterTintColor;
	button.translatesAutoresizingMaskIntoConstraints = NO;
	[button setImage:image forState: UIControlStateNormal];
	[button addTarget:self action:selector forControlEvents: UIControlEventPrimaryActionTriggered];
	[bottomStackView addArrangedSubview: button];
	return button;

}


- (void)sendMessageAsMe:(BOOL)byMe {

	[messagesTextField resignFirstResponder];
	[delegate addMessage:messagesTextField.text byMe: byMe];
	messagesTextField.text = @"";

}


- (void)setupBottomAnchorConstraint:(NSLayoutConstraint *)constraint {

	bottomAnchorConstraint.active = false;
	bottomAnchorConstraint = constraint;
	bottomAnchorConstraint.active = true;

}

@end
