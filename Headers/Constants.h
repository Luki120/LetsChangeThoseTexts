@import UIKit;
@import CydiaSubstrate;
#import <stdlib.h>

static NSString *const kIgPath = @"/var/mobile/Library/Preferences/me.luki.runtimeoverflow.lcttinstagram.plist";
static NSString *const kTwitterPath = @"/var/mobile/Library/Preferences/me.luki.runtimeoverflow.lctttwitter.plist";

#define kClass(class) NSClassFromString(class)
#define kPersistentDomainName [NSString stringWithFormat:@"me.luki.runtimeoverflow.lctt%@messages", application.lowercaseString]
#define kIgTintColor [UIColor colorWithRed:0.84 green:0.16 blue:0.46 alpha: 1.0]
#define kTwitterTintColor [UIColor colorWithRed:0.0 green:0.67 blue:0.93 alpha: 1.0]
