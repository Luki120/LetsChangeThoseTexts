#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>
#import <AudioToolbox/AudioServices.h>
#import <spawn.h>


@interface LCTTRootListController : PSListController
@property (nonatomic, retain) UIBarButtonItem *killButton;
- (void)shatterThePrefsToPieces;
- (void)killApps;
@end