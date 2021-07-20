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