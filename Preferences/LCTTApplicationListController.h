#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>
#import <AudioToolbox/AudioServices.h>
#import <spawn.h>


@interface LCTTApplicationListController : PSListController {

    NSString *application;

}
- (void)shatterThePrefsToPieces;
@end

@interface _UIBackdropViewSettings : NSObject
+ (id)settingsForStyle:(long long)arg1;
@end

@interface _UIBackdropView : UIView
- (id)initWithFrame:(CGRect)arg1 autosizesToFitSuperview:(BOOL)arg2 settings:(id)arg3;
- (id)initWithSettings:(id)arg1;
@end

@interface LCTTTextViewCell : PSTableCell <UITextViewDelegate> {
	
	UITextView *postText;

}

@end
