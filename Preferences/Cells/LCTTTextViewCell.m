#import "LCTTTextViewCell.h"


@interface LCTTTextViewCell () <UITextViewDelegate>
@end


@implementation LCTTTextViewCell {

	UITextView *postTextView;
	UILabel *placeholderLabel;

}


- (UILabel *)detailTextLabel { return NULL; }
- (void)willMoveToSuperview:(UIView *)superview {

	[super willMoveToSuperview: superview];

	if(postTextView) return;

	postTextView = [UITextView new];
	postTextView.font = [UIFont systemFontOfSize: 17];
	postTextView.text = [self.specifier performGetter];
	postTextView.delegate = self;
	postTextView.editable = YES;
	postTextView.textColor = UIColor.labelColor;
	postTextView.scrollEnabled = NO;
	postTextView.backgroundColor = UIColor.clearColor;
	postTextView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.contentView addSubview: postTextView];

	[postTextView.topAnchor constraintEqualToAnchor: self.contentView.topAnchor].active = YES;
	[postTextView.bottomAnchor constraintEqualToAnchor: self.contentView.bottomAnchor].active = YES;
	[postTextView.leadingAnchor constraintEqualToAnchor: self.contentView.leadingAnchor constant: 10].active = YES;
	[postTextView.trailingAnchor constraintEqualToAnchor: self.contentView.trailingAnchor constant: -10].active = YES;
	[postTextView.heightAnchor constraintGreaterThanOrEqualToConstant: 44].active = YES;

	[postTextView resignFirstResponder];

	if(((NSNumber *) [self.specifier propertyForKey:@"firstResponder"]).boolValue) {

		[self.specifier removePropertyForKey:@"firstResponder"];
		[postTextView becomeFirstResponder];

	}

	if(placeholderLabel) return;

	placeholderLabel = [UILabel new];
	placeholderLabel.text = @"Fake post...";
	if([postTextView hasText]) placeholderLabel.hidden = YES;
	placeholderLabel.textColor = UIColor.placeholderTextColor;
	placeholderLabel.translatesAutoresizingMaskIntoConstraints = NO;
	[postTextView addSubview: placeholderLabel];

	[placeholderLabel.centerYAnchor constraintEqualToAnchor: postTextView.centerYAnchor].active = YES;
	[placeholderLabel.leadingAnchor constraintEqualToAnchor: postTextView.leadingAnchor constant: 5].active = YES;

}


- (void)updateHeight {

	NSNumber *height = (NSNumber *) [self.specifier propertyForKey:@"lheight"];
	NSNumber *newHeight = @(ceil([postTextView intrinsicContentSize].height));

	if(fabs(height.doubleValue - newHeight.doubleValue) > 10) {

		[self.specifier setProperty:newHeight forKey:@"lheight"];
		[self.specifier setProperty:@([postTextView canResignFirstResponder]) forKey:@"firstResponder"];
		[self.specifier performSetterWithValue: postTextView.text];
		[((LCTTApplicationVC *) [self cellTarget]) reloadSpecifier:self.specifier animated:true];

	}

}


// ! UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {

	if([self.specifier propertyForKey:@"lheight"]) return;
	[self.specifier setProperty:@(ceil([postTextView intrinsicContentSize].height)) forKey:@"lheight"];

}


- (void)textViewDidEndEditing:(UITextView *)textView {

	[self.specifier performSetterWithValue: textView.text];
	if(![textView hasText]) placeholderLabel.hidden = NO;

}


- (void)textViewDidChange:(UITextView *)textView {

	[self updateHeight];
	placeholderLabel.hidden = [textView hasText] ? YES : NO;

}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

	NSRange resultRange = [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch];

	if(text.length == 1 && resultRange.location != NSNotFound) {
		[textView resignFirstResponder];
		return NO;
	}

	return YES;

}

@end
