#import "Instagram.h"


// Variables related to preferences

static BOOL enableTweak;
static NSString *targetUsername;

static BOOL showSeen;
static BOOL spoofVerified;

static NSString *username;
static NSString *fullName;
static NSString *profilePictureURL;

static NSString *const kIgMessagesDict = @"/var/mobile/Library/Preferences/me.luki.runtimeoverflow.lcttinstagrammessages.plist";

static void loadPrefs() {

	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: kIgPath];
	NSMutableDictionary *prefs = dict ? [dict mutableCopy] : [NSMutableDictionary dictionary];

	enableTweak = prefs[@"enableTweak"] ? [prefs[@"enableTweak"] boolValue] : NO;
	targetUsername = prefs[@"targetUsername"] ? prefs[@"targetUsername"] : NULL;
	showSeen = prefs[@"showSeen"] ? [prefs[@"showSeen"] boolValue] : YES;
	spoofVerified = prefs[@"spoofVerified"] ? [prefs[@"spoofVerified"] boolValue] : NO;
	fullName = prefs[@"newFullName"] ? prefs[@"newFullName"] : NULL;
	username = prefs[@"newUsername"] ? prefs[@"newUsername"] : NULL;
	profilePictureURL = prefs[@"newProfilePictureURL"] ? prefs[@"newProfilePictureURL"] : NULL;

}

// Variables which are evaluated at runtime
static IGUserStore *userStore = NULL;
static IGUser *me = NULL;
static IGUser *target = NULL;
static UIImage *img = NULL;

// List of our custom messages
static NSMutableArray<IGDirectPublishedMessage *> *messages;

static IGDirectPublishedMessage *createMessage(NSString *message, NSString *senderPk) {

	NSString *serverId = [NSString stringWithFormat:@"%d", arc4random_uniform(1000000)];
	NSString *threadId = [NSString stringWithFormat:@"%d", arc4random_uniform(1000000)];
	NSString *clientContext = [NSString stringWithFormat:@"%d", arc4random_uniform(1000000)];

	IGDirectPublishedMessageMetadata *metadata = [[kClass(@"IGDirectPublishedMessageMetadata") alloc] initWithServerTimestamp:NSDate.date serverId:serverId clientContext:clientContext threadId:threadId senderPk:senderPk isBusinessSuggestionProcessed:YES];
	IGDirectPublishedMessageContent *content = [kClass(@"IGDirectPublishedMessageContent") textWithString:message translatedString:message mentionedUserPks:@[] messageCommands:nil sendSilently:NO textFormatters:nil];
	return [[kClass(@"IGDirectPublishedMessage") alloc] initWithMetadata:metadata content:content collectionSaveIconState:0 quotedMessage:NULL reactions:@[] forwardMetadata:NULL powerupsMetadata:NULL violationReview:NULL instantReplies:@[] auxiliaryContent:NULL isShhMode:false];

}

// spoof the last seen status if the conditions below are met
static NSDictionary *(*oldLastSeen)(IGDirectThreadMetadata *, SEL);
static NSDictionary *newLastSeen(IGDirectThreadMetadata *self, SEL _cmd) {

	NSDictionary *original = oldLastSeen(self, _cmd);

	if(!self.isGroup && self.users.count == 1 && self.users[0] == target) {

		NSMutableDictionary *mutableDict = original.mutableCopy;
		if(showSeen && messages.count > 0) mutableDict[target.pk] = [[kClass(@"IGDirectLastSeenMessageInfo") alloc] initWithMessageId:messages[messages.count - 1].metadata.serverId seenAtTimestamp:NSDate.date shhMessageSeenInfo:NULL];
		else mutableDict[target.pk] = NULL;
		return mutableDict;

	}

	else return original;

}

// Hook isVerified from IGUser to return true if it's the target user
static BOOL (*oldVerified)(IGUser *, SEL);
static BOOL newVerified(IGUser *self, SEL _cmd) {

	if(self == target) return spoofVerified;
	else return oldVerified(self, _cmd);

}

// Hook the fullName (nickname) getter of IGUser to return a custom name if it's the target user
static NSString *(*oldFullName)(IGUser *, SEL);
static NSString *newFullName(IGUser *self, SEL _cmd) {

	if(self == target && fullName && ![fullName isEqualToString:@""]) return fullName;
	else return oldFullName(self, _cmd);

}

// Hook the username getter of IGUser to return a custom username if it's the target user
static NSString *(*oldUsername)(IGUser *, SEL);
static NSString *newUsername(IGUser *self, SEL _cmd) {

	if(self == target && username && ![username isEqualToString:@""]) return username;
	else return oldUsername(self, _cmd);

}

// Hook the _updateImageViewWithProcessedImage method to replace the pfp image with our custom one
static void (*oldProfilePicture)(IGProfilePictureImageView *, SEL);
static void newProfilePicture(IGProfilePictureImageView *self, SEL _cmd) {

	oldProfilePicture(self, _cmd);

	// Only swap the profile picture if it's the target user and the profile picture exists
	if(self.user == target && img)

		// Set a custom image and let it process (processing applies the rounded corners)
		[self _setImageFromImage:img shouldProcess: true];

}

static id (*oldThread)(IGDirectUIThread *, SEL, id, id, id, id, IGDirectThreadMetadata *, id, id, id, id, id, id);
static id newThread(IGDirectUIThread *self, SEL _cmd, id threadKey, id threadId, id viewerId, id threadIdV2ForInboxPaging, IGDirectThreadMetadata *metadata, id visualMessageInfo, id publishedMessageSet, id publishedMessagesInCurrentThreadRange, id outgoingMessageSet, id threadMessagesRange, id messageIslandRange) {

	// Check if the chat ain't a group, only has one other memeber and that member is our target
	if(!metadata.isGroup && metadata.users.count == 1 && metadata.users[0] == target) {

		NSMutableDictionary *messagesByServerId = [NSMutableDictionary new];
		NSMutableDictionary *messagesByClientContext = [NSMutableDictionary new];

		// Loop through all messages and insert them into the NSDictionaries
		for(IGDirectPublishedMessage *msg in messages) {

			if(msg.metadata.serverId) messagesByServerId[msg.metadata.serverId] = msg;
			if(msg.metadata.clientContext) messagesByClientContext[msg.metadata.clientContext] = msg;

		}

		IGDirectPublishedMessageSet *newMessagesSet = [[kClass(@"IGDirectPublishedMessageSet") alloc] initWithSortedMessages:messages messagesByServerId:messagesByServerId messagesByClientContext:messagesByClientContext];

		// Replace the IGDirectPublishedMessageSet and publishedMessagesInCurrentThreadRange NSOrderedSet with our own which have the messages we want
		return oldThread(self, _cmd, threadKey, threadId, viewerId, threadIdV2ForInboxPaging, metadata, visualMessageInfo, newMessagesSet, [NSOrderedSet orderedSetWithArray: messages], outgoingMessageSet, threadMessagesRange, messageIslandRange);

	}

	else

		// Otherwise proceed without a change
		return oldThread(self, _cmd, threadKey, threadId, viewerId, threadIdV2ForInboxPaging, metadata, visualMessageInfo, publishedMessageSet, publishedMessagesInCurrentThreadRange, outgoingMessageSet, threadMessagesRange, messageIslandRange);

}

// Hook IGObjectStores to assign the IGUserStore to a gloabl variable for easy access
static id (*oldObjectStores)(id, SEL, id, id, id, IGUserStore *, id, id);
static id newObjectStores(id self, SEL _cmd, id mediaStore, id productSaveStatusStore, id storyReelStore, IGUserStore *_userStore, id productDrawingEnterStatusStore, id dropsReminderController) {

	userStore = _userStore;
	return oldObjectStores(self, _cmd, mediaStore, productSaveStatusStore, storyReelStore, _userStore, productDrawingEnterStatusStore, dropsReminderController);

}

// We need to hook this method because FBSharedFramework is only loaded right before this
static BOOL (*origADFL)(IGAppDelegate *, SEL, UIApplication *, NSDictionary *);
static BOOL overrideADFL(IGAppDelegate *self, SEL _cmd, UIApplication *app, NSDictionary *options) {

	// Load tweak preferences
	loadPrefs();

	// Disable the tweak if it ain't enabled or there's no target username
	if(!enableTweak || !targetUsername) {
		origADFL(self, _cmd, app, options);
		return YES;
	}

	// instantiate the messages array right before we try to use it :weSmart:
	messages = [NSMutableArray new];

	// Hook the IGObjectStores initializer to obtain the IGUserStore instance
	MSHookMessageEx(kClass(@"IGObjectStores"), @selector(initWithMediaStore:productSaveStatusStore:storyReelStore:userStore:productDrawingEnterStatusStore:dropsReminderController:), (IMP) &newObjectStores, (IMP *) &oldObjectStores);

	// Call the original method implementation, which will execute the above hook and set the IGUserStore
	origADFL(self, _cmd, app, options);

	// Obtain the IGUsers for the signed in account and the target user
	me = [userStore userWithPK: [self.window.userSession pk]];
	target = [userStore storedUserWithUsername: targetUsername];
	if(!target) target = [userStore storedUserWithUsername: username];

	// If either of the users don't exist, abort
	if(!me || !target) return YES;

	// Load the image from the internet
	if(profilePictureURL && ![profilePictureURL isEqualToString:@""])

		img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString: profilePictureURL]]];

	NSArray *msgs = [NSDictionary dictionaryWithContentsOfFile: kIgMessagesDict][@"messages"];

	if(msgs)

		for(NSDictionary *msg in msgs)

			[messages addObject:createMessage(msg[@"message"], ((NSNumber *) msg[@"me"]).boolValue ? me.pk : target.pk)];

	// Initialize all other hooks
	MSHookMessageEx(kClass(@"IGDirectUIThread"), @selector(initWithThreadKey:threadId:viewerId:threadIdV2ForInboxPaging:metadata:visualMessageInfo:publishedMessageSet:publishedMessagesInCurrentThreadRange:outgoingMessageSet:threadMessagesRange:messageIslandRange:), (IMP) &newThread, (IMP *) &oldThread);
	MSHookMessageEx(kClass(@"IGProfilePictureImageView"), @selector(_updateImageViewWithProcessedImage), (IMP) &newProfilePicture, (IMP *) &oldProfilePicture);
	MSHookMessageEx(kClass(@"IGDirectThreadMetadata"), @selector(lastSeenMessageIdsForUserIds), (IMP) &newLastSeen, (IMP *) &oldLastSeen);

	// Initiate IGUser hooks
	MSHookMessageEx(kClass(@"IGUser"), @selector(isVerified), (IMP) &newVerified, (IMP *) &oldVerified);
	MSHookMessageEx(kClass(@"IGUser"), @selector(fullName), (IMP) &newFullName, (IMP *) &oldFullName);
	MSHookMessageEx(kClass(@"IGUser"), @selector(username), (IMP) &newUsername, (IMP *) &oldUsername);

	return YES;

}


__attribute__((constructor)) static void init() {

	MSHookMessageEx(kClass(@"IGAppDelegate"), @selector(application:didFinishLaunchingWithOptions:), (IMP) &overrideADFL, (IMP *) &origADFL);

}
