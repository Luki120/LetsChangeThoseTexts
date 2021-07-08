#import <UIKit/UIKit.h>


static BOOL enableTweak;

static NSString *prefsKeys = @"/var/mobile/Library/Preferences/me.luki.runtimeoverflow.lcttprefs.plist";


static void loadPrefs() {


    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:prefsKeys];
    NSMutableDictionary *prefs = dict ? [dict mutableCopy] : [NSMutableDictionary dictionary];

    enableTweak = prefs[@"enableTweak"] ? [prefs[@"enableTweak"] boolValue] : NO;


}


id (*oldInit)(id self, SEL _cmd, NSArray *sorted, NSDictionary *byServerId, NSDictionary *byClientContext);

id newInit(id self, SEL _cmd, NSArray *sorted, NSDictionary *byServerId, NSDictionary *byClientContext) {

    id msg = sorted.firstObject;
    NSString *serverId = [byServerId allKeysForObject:msg].firstObject;
    NSString *clientContext = [byClientContext allKeysForObject:msg].firstObject;
    
    return (oldInit)(self, _cmd, @[msg], serverId ? @{serverId: msg} : @{}, clientContext ? @{clientContext: msg} : @{});

}


%hook IGAppDelegate

- (void)applicationDidBecomeActive:(id)app {

    %orig;
    
    loadPrefs();

    if(!enableTweak) return;
    
    MSHookMessageEx(NSClassFromString(@"IGDirectPublishedMessageSet"), @selector(initWithSortedMessages:messagesByServerId:messagesByClientContext:), (IMP) &newInit, (IMP*) &oldInit);

}

%end