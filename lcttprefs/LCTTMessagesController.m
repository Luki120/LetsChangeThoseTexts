#import <UIKit/UIKit.h>
#import <Preferences/PSListController.h>

@interface LCTTMessagesController : PSListController <UITableViewDelegate, UITableViewDataSource> {

	UIView *bottomContainerView;
	NSLayoutConstraint *bottomContainerViewBottomAnchor;
	UITextField *textField;

}
@property (nonatomic, strong) UITableView *lcttTableView;
@end


@implementation LCTTMessagesController

- (void)viewDidLoad {

	[super viewDidLoad];
	[[self table] removeFromSuperview];

	self.lcttTableView = [[UITableView alloc] initWithFrame:UIScreen.mainScreen.bounds style:UITableViewStylePlain];
	self.lcttTableView.backgroundColor = UIColor.systemGray6Color;	
	self.lcttTableView.dataSource = self;
	self.lcttTableView.delegate = self;
	[self.view addSubview:self.lcttTableView];
	
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:NULL];
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:NULL];
	
	UIView *bottomBackgroundView = [[UIView alloc] init];
	bottomBackgroundView.translatesAutoresizingMaskIntoConstraints = false;
	bottomBackgroundView.backgroundColor = UIColor.systemGray6Color;
	[self.viewIfLoaded addSubview:bottomBackgroundView];
	
	[bottomBackgroundView.leadingAnchor constraintEqualToAnchor:self.viewIfLoaded.leadingAnchor].active = true;
	[bottomBackgroundView.trailingAnchor constraintEqualToAnchor:self.viewIfLoaded.trailingAnchor].active = true;
	[bottomBackgroundView.bottomAnchor constraintEqualToAnchor:self.viewIfLoaded.bottomAnchor].active = true;
	
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

/*- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

	return 1;

}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	return 5;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"heh";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if(cell == nil) {
		
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

	}

	return cell;

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {


}

- (void)sendLeft:(UIButton *)button {

	[textField resignFirstResponder];

}

- (void)sendRight:(UIButton *)button {

	[textField resignFirstResponder];

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