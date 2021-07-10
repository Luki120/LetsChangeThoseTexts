#import <UIKit/UIKit.h>
#import <stdlib.h>
#import "Instagram.h"

//Variables related to preferences
static BOOL enableTweak = false;
static NSString *targetUsername = NULL;

static NSString *prefsKeys = @"/var/mobile/Library/Preferences/me.luki.runtimeoverflow.lcttprefs.plist";


static void loadPrefs() {
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:prefsKeys];
	NSMutableDictionary *prefs = dict ? [dict mutableCopy] : [NSMutableDictionary dictionary];

	enableTweak = prefs[@"enableTweak"] ? [prefs[@"enableTweak"] boolValue] : NO;
	targetUsername = prefs[@"username"] ? prefs[@"username"] : NULL;
}

//Variables which are evaluated at runtime
static IGUserStore *userStore = NULL;
static IGUser *me = NULL;
static IGUser *target = NULL;
static UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://cdn.discordapp.com/avatars/521753871673065473/6aac8129e691419a15d1f8c66985eabe.webp"]]];
static IGDirectPublishedMessage *message = NULL;


IGDirectPublishedMessage * createMessage(NSString *message, NSString *senderPk){
	NSString *serverId = [NSString stringWithFormat:@"%d", arc4random_uniform(1000000)];
	NSString *clientContext = [NSString stringWithFormat:@"%d", arc4random_uniform(1000000)];
	
	IGDirectPublishedMessageMetadata *metadata = [[%c(IGDirectPublishedMessageMetadata) alloc] initWithServerTimestamp:NSDate.date serverId:serverId clientContext:clientContext threadId:[NSString stringWithFormat:@"%d", arc4random_uniform(1000000)] senderPk:@"5489216693"];
	IGDirectPublishedMessageContent *content = [%c(IGDirectPublishedMessageContent) textWithString:message mentionedUserPks:@[] mentionedUsers:@[]];
	return [[%c(IGDirectPublishedMessage) alloc] initWithMetadata:metadata content:content quotedMessage:NULL reactions:@[] forwardMetadata:NULL powerupsMetadata:NULL violationReview:NULL instantReplies:@[] isShhMode:false];
}

//Hook the isVerified of IGUser to return true if it's the target user
BOOL (*oldVerified)(IGUser *self, SEL _cmd);

BOOL newVerified(IGUser *self, SEL _cmd) {
	if(self == target) return true;
	else return oldVerified(self, _cmd);
}

//Hook the _updateImageViewWithProcessedImage method to replace the image with our custom one
void (*oldProfilePicture)(IGProfilePictureImageView *self, SEL _cmd);

void newProfilePicture(IGProfilePictureImageView *self, SEL _cmd) {
	oldProfilePicture(self, _cmd);
	
	//Only swap the profile picture if it's the target user
	if(self.user == target){
		//Set a custom image and let it process (processing applies the rounded corners)
		[self _setImageFromImage:img shouldProcess:true];
	}
}

id (*oldThread)(IGDirectUIThread *self, SEL _cmd, id threadKey, id threadId, id viewerId, id threadIdV2ForInboxPaging, IGDirectThreadMetadata *metadata, id visualMessageInfo, id publishedMessageSet, id publishedMessagesInCurrentThreadRange, id outgoingMessageSet, id threadMessagesRange, id messageIslandRange);

id newThread(IGDirectUIThread *self, SEL _cmd, id threadKey, id threadId, id viewerId, id threadIdV2ForInboxPaging, IGDirectThreadMetadata *metadata, id visualMessageInfo, id publishedMessageSet, id publishedMessagesInCurrentThreadRange, id outgoingMessageSet, id threadMessagesRange, id messageIslandRange) {
	//Check if the chat is not a group, only has one other memeber and that member is our target
	if(!metadata.isGroup && metadata.users.count == 1 && metadata.users[0] == target) {
		//If yes, replace the IGDirectPublishedMessageSet and publishedMessagesInCurrentThreadRange NSOrderedSet the with our own which have the messages we want
		return oldThread(self, _cmd, threadKey, threadId, viewerId, threadIdV2ForInboxPaging, metadata, visualMessageInfo, [[%c(IGDirectPublishedMessageSet) alloc] initWithSortedMessages:@[message] messagesByServerId:message.metadata.serverId ? @{message.metadata.serverId: message} : @{} messagesByClientContext:message.metadata.clientContext ? @{message.metadata.clientContext: message} : @{}], [NSOrderedSet orderedSetWithArray:@[message]], outgoingMessageSet, threadMessagesRange, messageIslandRange);
	} else {
		//Otherwise proceed without a change
		return oldThread(self, _cmd, threadKey, threadId, viewerId, threadIdV2ForInboxPaging, metadata, visualMessageInfo, publishedMessageSet, publishedMessagesInCurrentThreadRange, outgoingMessageSet, threadMessagesRange, messageIslandRange);
	}
}

//Hook the IGObjectStores to assign the IGUserStore to a gloabl variable for easy access
id (*oldObjectStores)(id self, SEL _cmd, id mediaStore, id productSaveStatusStore, id storyReelStore, IGUserStore *userStore);

id newObjectStores(id self, SEL _cmd, id mediaStore, id productSaveStatusStore, id storyReelStore, IGUserStore *_userStore){
	userStore = _userStore;
	
	return oldObjectStores(self, _cmd, mediaStore, productSaveStatusStore, storyReelStore, _userStore);
}

%hook IGAppDelegate
//We need to hook this method because SBSharedFramework is only loaded right before this
- (void)application:(id)app didFinishLaunchingWithOptions:(id)options {
	//Load tweak preferences
	loadPrefs();
	
	//Disable the tweak if not enabled or there's no target username
	if(!enableTweak || !targetUsername) {
		%orig;
		return;
	}
	
	//Hook the IGObjectStores initializer to obtain the IGUserStore instance
	MSHookMessageEx(NSClassFromString(@"IGObjectStores"), @selector(initWithMediaStore:productSaveStatusStore:storyReelStore:userStore:), (IMP) &newObjectStores, (IMP*) &oldObjectStores);
	
	//Call the original method implementation, which will execute the above hook and set the IGUserStore
	%orig;
	
	//Obtain the IGUsers for the signed in account and the target user
	me = [userStore userWithPK:[self.window.userSession pk]];
	target = [userStore storedUserWithUsername:targetUsername];
	
	//If either of the users don't exist, abort
	if(!me || !target) return;
	
	message = createMessage(@"Hi", target.pk);
	
	//Initialize all other hooks
	MSHookMessageEx(NSClassFromString(@"IGDirectUIThread"), @selector(initWithThreadKey:threadId:viewerId:threadIdV2ForInboxPaging:metadata:visualMessageInfo:publishedMessageSet:publishedMessagesInCurrentThreadRange:outgoingMessageSet:threadMessagesRange:messageIslandRange:), (IMP) &newThread, (IMP*) &oldThread);
	MSHookMessageEx(NSClassFromString(@"IGUser"), @selector(isVerified), (IMP) &newVerified, (IMP*) &oldVerified);
	MSHookMessageEx(NSClassFromString(@"IGProfilePictureImageView"), @selector(_updateImageViewWithProcessedImage), (IMP) &newProfilePicture, (IMP*) &oldProfilePicture);
}
%end