#import <spawn.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>
#import <AudioToolbox/AudioServices.h>
#import <Preferences/PSListController.h>
#import "LCTTMessagesVC.h"
#import "Headers/Constants.h"


@interface LCTTApplicationVC : PSListController
@end


@interface _UIBackdropViewSettings : NSObject
+ (id)settingsForStyle:(NSInteger)arg1;
@end


@interface _UIBackdropView : UIView
- (id)initWithSettings:(id)arg1;
@end
