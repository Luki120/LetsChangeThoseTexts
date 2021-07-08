#import <UIKit/UIKit.h>


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
    
    MSHookMessageEx(NSClassFromString(@"IGDirectPublishedMessageSet"), @selector(initWithSortedMessages:messagesByServerId:messagesByClientContext:), (IMP) &newInit, (IMP*) &oldInit);

}

%end