#import <UIKit/UIKit.h>
#import <stdlib.h>
#import "Instagram.h"

static BOOL enableTweak;

static NSString *prefsKeys = @"/var/mobile/Library/Preferences/me.luki.runtimeoverflow.lcttprefs.plist";


static void loadPrefs() {
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:prefsKeys];
	NSMutableDictionary *prefs = dict ? [dict mutableCopy] : [NSMutableDictionary dictionary];

	enableTweak = prefs[@"enableTweak"] ? [prefs[@"enableTweak"] boolValue] : NO;
}

IGDirectPublishedMessage * createMessage(NSString *message, NSString *senderPk){
	NSString *serverId = [NSString stringWithFormat:@"%d", arc4random_uniform(1000000)];
	NSString *clientContext = [NSString stringWithFormat:@"%d", arc4random_uniform(1000000)];
	
	IGDirectPublishedMessageMetadata *metadata = [[%c(IGDirectPublishedMessageMetadata) alloc] initWithServerTimestamp:NSDate.date serverId:serverId clientContext:clientContext threadId:[NSString stringWithFormat:@"%d", arc4random_uniform(1000000)] senderPk:@"5489216693"];
	IGDirectPublishedMessageContent *content = [%c(IGDirectPublishedMessageContent) textWithString:message mentionedUserPks:@[] mentionedUsers:@[]];
	return [[%c(IGDirectPublishedMessage) alloc] initWithMetadata:metadata content:content quotedMessage:NULL reactions:@[] forwardMetadata:NULL powerupsMetadata:NULL violationReview:NULL instantReplies:@[] isShhMode:false];
}

id (*oldInit)(id self, SEL _cmd, NSArray *sorted, NSDictionary *byServerId, NSDictionary *byClientContext);

id newInit(id self, SEL _cmd, NSArray *sorted, NSDictionary *byServerId, NSDictionary *byClientContext) {
	IGDirectPublishedMessage *message = createMessage(@"Hi", @"5489216693");
	
	return (oldInit)(self, _cmd, @[message], message.metadata.serverId ? @{message.metadata.serverId: message} : @{}, message.metadata.clientContext ? @{message.metadata.clientContext: message} : @{});
}

BOOL newVerified(id self, SEL _cmd) {
	return true;
}

static UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://cdn.discordapp.com/avatars/521753871673065473/6aac8129e691419a15d1f8c66985eabe.webp"]]];

void (*oldProfilePicture)(IGProfilePictureImageView *self, SEL _cmd);

void newProfilePicture(IGProfilePictureImageView *self, SEL _cmd) {
	oldProfilePicture(self, _cmd);
	[self _setImageFromImage:img shouldProcess:true];
}

%hook IGAppDelegate

- (void)applicationDidBecomeActive:(id)app {
	%orig;
	
	loadPrefs();

	if(!enableTweak) return;
	
	MSHookMessageEx(NSClassFromString(@"IGDirectPublishedMessageSet"), @selector(initWithSortedMessages:messagesByServerId:messagesByClientContext:), (IMP) &newInit, (IMP*) &oldInit);
	
	MSHookMessageEx(NSClassFromString(@"IGUser"), @selector(isVerified), (IMP) &newVerified, NULL);
	MSHookMessageEx(NSClassFromString(@"IGProfilePictureImageView"), @selector(_updateImageViewWithProcessedImage), (IMP) &newProfilePicture, (IMP*) &oldProfilePicture);
}

%end