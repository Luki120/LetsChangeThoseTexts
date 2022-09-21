@import AudioToolbox.AudioServices;
@import Preferences.PSListController;
@import Preferences.PSSpecifier;
@import Preferences.PSTableCell;
#import <spawn.h>
#import "LCTTMessagesVC.h"
#import "Headers/Constants.h"


@interface LCTTApplicationVC : PSListController
@end


@interface _UIBackdropViewSettings : NSObject
+ (id)settingsForStyle:(NSInteger)arg1;
@end


@interface _UIBackdropView : UIView
- (id)initWithFrame:(CGRect)arg1 autosizesToFitSuperview:(BOOL)arg2 settings:(id)arg3;
@end
