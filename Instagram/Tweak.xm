#import <UIKit/UIKit.h>
#import <stdlib.h>
#import "Instagram.h"

// Variables related to preferences

static BOOL enableTweak = false;
static NSString *targetUsername = NULL;
static BOOL spoofVerified = false;
static NSString *profilePictureURL = NULL;
static NSString *username = NULL;
static NSString *fullName = NULL;
static BOOL showSeen = true;

static NSString *prefsKeys = @"/var/mobile/Library/Preferences/me.luki.runtimeoverflow.lcttinstagram.plist";


static void loadPrefs() {

	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:prefsKeys];
	NSMutableDictionary *prefs = dict ? [dict mutableCopy] : [NSMutableDictionary dictionary];

	enableTweak = prefs[@"enableTweak"] ? [prefs[@"enableTweak"] boolValue] : NO;
	targetUsername = prefs[@"targetUsername"] ? prefs[@"targetUsername"] : NULL;
	spoofVerified = prefs[@"spoofVerified"] ? [prefs[@"spoofVerified"] boolValue] : NO;
	profilePictureURL = prefs[@"newProfilePictureURL"] ? prefs[@"newProfilePictureURL"] : NULL;
	username = prefs[@"newUsername"] ? prefs[@"newUsername"] : NULL;
	fullName = prefs[@"newFullName"] ? prefs[@"newFullName"] : NULL;
	showSeen = prefs[@"showSeen"] ? [prefs[@"showSeen"] boolValue] : YES;

}

// Variables which are evaluated at runtime

static IGUserStore *userStore = NULL;
static IGUser *me = NULL;
static IGUser *target = NULL;
static UIImage *img = NULL;

//List of our custom messages

static NSMutableArray<IGDirectPublishedMessage *> *messages = [[NSMutableArray alloc] init];


IGDirectPublishedMessage * createMessage(NSString *message, NSString *senderPk){

	NSString *serverId = [NSString stringWithFormat:@"%d", arc4random_uniform(1000000)];
	NSString *clientContext = [NSString stringWithFormat:@"%d", arc4random_uniform(1000000)];
	
	IGDirectPublishedMessageMetadata *metadata = [[%c(IGDirectPublishedMessageMetadata) alloc] initWithServerTimestamp:NSDate.date serverId:serverId clientContext:clientContext threadId:[NSString stringWithFormat:@"%d", arc4random_uniform(1000000)] senderPk:senderPk];
	IGDirectPublishedMessageContent *content = [%c(IGDirectPublishedMessageContent) textWithString:message mentionedUserPks:@[] mentionedUsers:@[]];
	return [[%c(IGDirectPublishedMessage) alloc] initWithMetadata:metadata content:content quotedMessage:NULL reactions:@[] forwardMetadata:NULL powerupsMetadata:NULL violationReview:NULL instantReplies:@[] isShhMode:false];

}

// Hook the isVerified of IGUser to return true if it's the target user

BOOL (*oldVerified)(IGUser *self, SEL _cmd);

BOOL newVerified(IGUser *self, SEL _cmd) {

	if(self == target && spoofVerified) return true;
	else return oldVerified(self, _cmd);

}

// Hook the fullName (nickname) getter of IGUser to return a custom name if it's the target user

NSString * (*oldFullName)(IGUser *self, SEL _cmd);

NSString * newFullName(IGUser *self, SEL _cmd) {

	if(self == target && fullName && ![fullName isEqualToString:@""]) return fullName;
	else return oldFullName(self, _cmd);

}

// Hook the username getter of IGUser to return a custom name if it's the target user

NSString * (*oldUsername)(IGUser *self, SEL _cmd);

NSString * newUsername(IGUser *self, SEL _cmd) {

	if(self == target && username && ![username isEqualToString:@""]) return username;
	else return oldUsername(self, _cmd);

}

// Hook the _updateImageViewWithProcessedImage method to replace the image with our custom one

void (*oldProfilePicture)(IGProfilePictureImageView *self, SEL _cmd);

void newProfilePicture(IGProfilePictureImageView *self, SEL _cmd) {
	oldProfilePicture(self, _cmd);
	
	// Only swap the profile picture if it's the target user and the profile picture exists

	if(self.user == target && img) {
		
		// Set a custom image and let it process (processing applies the rounded corners)
		
		[self _setImageFromImage:img shouldProcess:true];
	
	}

}

NSDictionary * (*oldLastSeen)(IGDirectThreadMetadata *self, SEL _cmd);

NSDictionary * newLastSeen(IGDirectThreadMetadata *self, SEL _cmd) {
	
	NSDictionary *original = oldLastSeen(self, _cmd);

	if(!self.isGroup && self.users.count == 1 && self.users[0] == target) {
		NSMutableDictionary *mutableDict = original.mutableCopy;
		if(showSeen && messages.count > 0) mutableDict[target.pk] = [[%c(IGDirectLastSeenMessageInfo) alloc] initWithMessageId:messages[messages.count - 1].metadata.serverId seenAtTimestamp:NSDate.date shhMessageSeenInfo:NULL];
		else mutableDict[target.pk] = NULL;
		return mutableDict;
	
	} else return original;

}

id (*oldThread)(IGDirectUIThread *self, SEL _cmd, id threadKey, id threadId, id viewerId, id threadIdV2ForInboxPaging, IGDirectThreadMetadata *metadata, id visualMessageInfo, id publishedMessageSet, id publishedMessagesInCurrentThreadRange, id outgoingMessageSet, id threadMessagesRange, id messageIslandRange);

id newThread(IGDirectUIThread *self, SEL _cmd, id threadKey, id threadId, id viewerId, id threadIdV2ForInboxPaging, IGDirectThreadMetadata *metadata, id visualMessageInfo, id publishedMessageSet, id publishedMessagesInCurrentThreadRange, id outgoingMessageSet, id threadMessagesRange, id messageIslandRange) {
	
	// Check if the chat is not a group, only has one other memeber and that member is our target
	
	if(!metadata.isGroup && metadata.users.count == 1 && metadata.users[0] == target) {

		NSMutableDictionary *messagesByServerId = [[NSMutableDictionary alloc] init];
		NSMutableDictionary *messagesByClientContext = [[NSMutableDictionary alloc] init];
		
		// Loop through all messages and insert them into the NSDictionaries
		
		for(IGDirectPublishedMessage *msg in messages) {
			
			if(msg.metadata.serverId) messagesByServerId[msg.metadata.serverId] = msg;
			if(msg.metadata.clientContext) messagesByClientContext[msg.metadata.clientContext] = msg;
		
		}
		
		// Replace the IGDirectPublishedMessageSet and publishedMessagesInCurrentThreadRange NSOrderedSet with our own which have the messages we want
		
		return oldThread(self, _cmd, threadKey, threadId, viewerId, threadIdV2ForInboxPaging, metadata, visualMessageInfo, [[%c(IGDirectPublishedMessageSet) alloc] initWithSortedMessages:messages messagesByServerId:messagesByServerId messagesByClientContext:messagesByClientContext], [NSOrderedSet orderedSetWithArray:messages], outgoingMessageSet, threadMessagesRange, messageIslandRange);
	
	} else {
		
		// Otherwise proceed without a change
		
		return oldThread(self, _cmd, threadKey, threadId, viewerId, threadIdV2ForInboxPaging, metadata, visualMessageInfo, publishedMessageSet, publishedMessagesInCurrentThreadRange, outgoingMessageSet, threadMessagesRange, messageIslandRange);
	
	}

}

// Hook the IGObjectStores to assign the IGUserStore to a gloabl variable for easy access

id (*oldObjectStores)(id self, SEL _cmd, id mediaStore, id productSaveStatusStore, id storyReelStore, IGUserStore *userStore);

id newObjectStores(id self, SEL _cmd, id mediaStore, id productSaveStatusStore, id storyReelStore, IGUserStore *_userStore){
	userStore = _userStore;
	
	return oldObjectStores(self, _cmd, mediaStore, productSaveStatusStore, storyReelStore, _userStore);

}

%hook IGAppDelegate


// We need to hook this method because SBSharedFramework is only loaded right before this

- (void)application:(id)app didFinishLaunchingWithOptions:(id)options {

	// Load tweak preferences

	loadPrefs();
	
	// Disable the tweak if not enabled or there's no target username
	
	if(!enableTweak || !targetUsername) {
	
		%orig;
		return;
	
	}
	
	// Hook the IGObjectStores initializer to obtain the IGUserStore instance

	MSHookMessageEx(NSClassFromString(@"IGObjectStores"), @selector(initWithMediaStore:productSaveStatusStore:storyReelStore:userStore:), (IMP) &newObjectStores, (IMP*) &oldObjectStores);
	
	// Call the original method implementation, which will execute the above hook and set the IGUserStore
	
	%orig;
	
	// Obtain the IGUsers for the signed in account and the target user
	
	me = [userStore userWithPK:[self.window.userSession pk]];
	target = [userStore storedUserWithUsername:targetUsername];
	if(!target) target = [userStore storedUserWithUsername:username];
	
	// If either of the users don't exist, abort
	
	if(!me || !target) return;
	
	// Load the image from the interwebz
	
	if(profilePictureURL && ![profilePictureURL isEqualToString:@""]) img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:profilePictureURL]]];
	
	NSArray<NSDictionary *> *msgs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/LCTTMessages.plist"][@"messages"];
	
	if(msgs) {
		
		for(NSDictionary *msg in msgs) {
			
			[messages addObject:createMessage(msg[@"message"], ((NSNumber *) msg[@"me"]).boolValue ? me.pk : target.pk)];
		
		}
	
	}
	
	// Initialize all other hooks
	
	MSHookMessageEx(NSClassFromString(@"IGDirectUIThread"), @selector(initWithThreadKey:threadId:viewerId:threadIdV2ForInboxPaging:metadata:visualMessageInfo:publishedMessageSet:publishedMessagesInCurrentThreadRange:outgoingMessageSet:threadMessagesRange:messageIslandRange:), (IMP) &newThread, (IMP*) &oldThread);
	MSHookMessageEx(NSClassFromString(@"IGProfilePictureImageView"), @selector(_updateImageViewWithProcessedImage), (IMP) &newProfilePicture, (IMP*) &oldProfilePicture);
	MSHookMessageEx(NSClassFromString(@"IGDirectThreadMetadata"), @selector(lastSeenMessageIdsForUserIds), (IMP) &newLastSeen, (IMP*) &oldLastSeen);
	
	// Initiate IGUser hooks
	
	MSHookMessageEx(NSClassFromString(@"IGUser"), @selector(isVerified), (IMP) &newVerified, (IMP*) &oldVerified);
	MSHookMessageEx(NSClassFromString(@"IGUser"), @selector(fullName), (IMP) &newFullName, (IMP*) &oldFullName);
	MSHookMessageEx(NSClassFromString(@"IGUser"), @selector(username), (IMP) &newUsername, (IMP*) &oldUsername);

}

%end