#import "Twitter.h"


static BOOL enableTweak;
static NSString *targetUsername;

static BOOL showSeen;
static BOOL spoofVerified;

static NSString *username;
static NSString *fullName;
static NSString *profilePictureURL;
static NSString *fakePostText;

static void loadPrefs() {

	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: kTwitterPath];
	NSMutableDictionary *prefs = dict ? [dict mutableCopy] : [NSMutableDictionary dictionary];

	enableTweak = prefs[@"enableTweak"] ? [prefs[@"enableTweak"] boolValue] : NO;
	targetUsername = prefs[@"targetUsername"] ? prefs[@"targetUsername"] : NULL;
	showSeen = prefs[@"showSeen"] ? [prefs[@"showSeen"] boolValue] : YES;
	spoofVerified = prefs[@"spoofVerified"] ? [prefs[@"spoofVerified"] boolValue] : NO;
	fullName = prefs[@"newFullName"] ? prefs[@"newFullName"] : NULL;
	username = prefs[@"newUsername"] ? prefs[@"newUsername"] : NULL;
	profilePictureURL = prefs[@"newProfilePictureURL"] ? prefs[@"newProfilePictureURL"] : NULL;
	fakePostText = prefs[@"fakePostText"] ? prefs[@"fakePostText"] : nil;

}

static NSInteger userID;
static NSInteger targetUserID = -1;
static NSMutableArray<TFNDirectMessageEntry *> *messages;

static NSString *const kTwitterMessagesDict = @"/var/mobile/Library/Preferences/me.luki.runtimeoverflow.lctttwittermessages.plist";

/***************************/
// ! | TFNDirectMessageUser |
/***************************/

static void (*origSetDirectMessageUser)(TFNDirectMessageUser *, SEL, TFSDirectMessageUser *);
static void overrideSetDirectMessageUser(TFNDirectMessageUser *self, SEL _cmd, TFSDirectMessageUser *user) {

	origSetDirectMessageUser(self, _cmd, user);
	if([user.username isEqualToString: targetUsername]) targetUserID = user.userID;

}

static BOOL (*origVerified)(TFNDirectMessageUser *, SEL);
static BOOL overrideVerified(TFNDirectMessageUser *self, SEL _cmd) {

	if(self.userID == targetUserID) return spoofVerified;
	else return origVerified(self, _cmd);

}

static NSString *(*origDisplayFullName)(TFNDirectMessageUser *, SEL);
static NSString *overrideDisplayFullName(TFNDirectMessageUser *self, SEL _cmd) {

	if(self.userID == targetUserID && fullName && ![fullName isEqualToString:@""]) return fullName;
	else return origDisplayFullName(self, _cmd);

}

static NSString *(*origDisplayUsername)(TFNDirectMessageUser *, SEL);
static NSString *overrideDisplayUsername(TFNDirectMessageUser *self, SEL _cmd) {

	if(self.userID == targetUserID && username && ![username isEqualToString:@""]) return [NSString stringWithFormat:@"@%@", username];
	else return origDisplayUsername(self, _cmd);

}

/******************************/
// ! | TFNTwitterCanonicalUser |
/******************************/

static TFNTwitterCanonicalUser *(*origInitWithCS2User)(TFNTwitterCanonicalUser *, SEL, id);
static TFNTwitterCanonicalUser *overrideInitWithCS2User(TFNTwitterCanonicalUser *self, SEL _cmd, id user) {

	TFNTwitterCanonicalUser *userr = origInitWithCS2User(self, _cmd, user);

	userID = self.userID;

	if([userr.username isEqualToString: targetUsername]) targetUserID = userr.userID;

	return userr;

}

static BOOL (*origCanonicalUserVerified)(TFNTwitterCanonicalUser *, SEL);
static BOOL overrideCanonicalUserVerified(TFNTwitterCanonicalUser *self, SEL _cmd) {

	if(self.userID == targetUserID) return spoofVerified;
	else return origCanonicalUserVerified(self, _cmd);

}

static NSString *(*origCanonicalUserDisplayFullName)(TFNDirectMessageUser *, SEL);
static NSString *overrideCanonicalUserDisplayFullName(TFNDirectMessageUser *self, SEL _cmd) {

	if(self.userID == targetUserID && fullName && ![fullName isEqualToString:@""]) return fullName;
	else return origCanonicalUserDisplayFullName(self, _cmd);

}

static NSString *(*origCanonicalUserDisplayUsername)(TFNDirectMessageUser *, SEL);
static NSString *overrideCanonicalUserDisplayUsername(TFNDirectMessageUser *self, SEL _cmd) {

	if(self.userID == targetUserID && username && ![username isEqualToString:@""]) return [NSString stringWithFormat:@"@%@", username];
	else return origCanonicalUserDisplayUsername(self, _cmd);

}

static id (*origMediaURL)(TFSTwitterEntityMedia *, SEL);
static id overrideMediaURL(TFSTwitterEntityMedia *self, SEL _cmd) {

	// hacky but Twitter changed the ivar we used to hook to a Swift property to determine
	// if the URL was for the pfp or the banner image, so :bThisIsHowItIs:
	if(userID == targetUserID
		&& profilePictureURL
		&& ![profilePictureURL isEqualToString:@""]
		&& ![origMediaURL(self, _cmd) containsString:@"banner"]) return profilePictureURL;

	return origMediaURL(self, _cmd);

}

/************/
// ! | Posts |
/************/

static NSString *(*origText)(TFNTwitterStatus *, SEL);
static NSString *overrideText(TFNTwitterStatus *self, SEL _cmd) {

	if(self.fromUserID == targetUserID) return fakePostText;
	else return origText(self, _cmd);

}

/********************/
// ! | Fake messages |
/********************/

static TFNDirectMessageEntry *createMessage(NSString *message, id sender) {

	TFNDirectMessageConversationEntryCanonicalIdentifier *identifier = [[kClass(@"TFNDirectMessageConversationEntryCanonicalIdentifier") alloc] initWithCanonicalID:arc4random_uniform(1000000)];
	return [[kClass(@"TFNDirectMessageEntry") alloc] initWithIdentifier:identifier
		sender:sender
		text:message
		entities:NULL
		attachment:NULL
		quickReplyRequest:NULL
		customProfile:NULL
		markedAsSpam:false
		markedAsAbuse:false
		time:NSDate.date
		ctas:NULL
		searchTokens:nil
		senderDeviceID:nil
		encryptedText:nil
	];

}

static NSArray *(*origAllEntries)(TFNDirectMessageConversation *, SEL);
static NSArray *overrideAllEntries(TFNDirectMessageConversation *self, SEL _cmd) {

	if(!self.isSelfConversation && self.participantsExcludingPerspectivalUser.count == 1 && self.participantsExcludingPerspectivalUser[0].participatingUser.userID == targetUserID) {

		if(messages) return messages;
		messages = [NSMutableArray new];

		NSArray *msgs = [NSDictionary dictionaryWithContentsOfFile: kTwitterMessagesDict][@"messages"];

		if(!msgs) return nil;
		for(NSDictionary *msg in msgs) {

			TFNDirectMessageEntry *entry = createMessage(msg[@"message"], ((NSNumber *) msg[@"me"]).boolValue ? self.perspectivalParticipant.participatingUser : self.participantsExcludingPerspectivalUser[0].participatingUser);
			entry.conversation = self;
			[messages addObject: entry];

		}

		return messages;

	}

	else return origAllEntries(self, _cmd);

}

static NSMutableArray *(*origEntryList)(TFNDirectMessageConversation *, SEL);
static NSMutableArray *overrideEntryList(TFNDirectMessageConversation *self, SEL _cmd) {

	if(!self.isSelfConversation && self.participantsExcludingPerspectivalUser.count == 1 && self.participantsExcludingPerspectivalUser[0].participatingUser.userID == targetUserID)

		return [self allEntries].mutableCopy;

	else return origEntryList(self, _cmd);

}

static TFNDirectMessageEntry *(*origLatestEntry)(TFNDirectMessageConversation *, SEL);
static TFNDirectMessageEntry *overrideLatestEntry(TFNDirectMessageConversation *self, SEL _cmd) {

	if(!self.isSelfConversation && self.participantsExcludingPerspectivalUser.count == 1 && self.participantsExcludingPerspectivalUser[0].participatingUser.userID == targetUserID) {

		NSArray<TFNDirectMessageEntry *> *messages = [self allEntries];

		if(messages.count > 0) return messages[messages.count - 1];
		else return NULL;

	}

	else return origLatestEntry(self, _cmd);

}

static BOOL (*origSeenByAllParticipants)(TFNDirectMessageEntry *, SEL);
static BOOL overrideSeenByAllParticipants(TFNDirectMessageEntry *self, SEL _cmd) {

	if(!self.conversation.isSelfConversation && self.conversation.participantsExcludingPerspectivalUser.count == 1 && self.conversation.participantsExcludingPerspectivalUser[0].participatingUser.userID == targetUserID)

		return showSeen;

	else return origSeenByAllParticipants(self, _cmd);

}

static id (*origSeenByParticipants)(TFNDirectMessageEntry *, SEL);
static id overrideSeenByParticipants(TFNDirectMessageEntry *self, SEL _cmd) {

	if(!self.conversation.isSelfConversation && self.conversation.participantsExcludingPerspectivalUser.count == 1 && self.conversation.participantsExcludingPerspectivalUser[0].participatingUser.userID == targetUserID)
		return showSeen ? self.conversation.participantsExcludingPerspectivalUser : @[];
	else return origSeenByParticipants(self, _cmd);

}

__attribute__((constructor)) static void init() {

	loadPrefs();
	if(!enableTweak || !targetUsername || !targetUsername.length) return;

	MSHookMessageEx(kClass(@"TFNDirectMessageUser"), @selector(setDirectMessageUser:), (IMP) &overrideSetDirectMessageUser, (IMP *) &origSetDirectMessageUser);
	MSHookMessageEx(kClass(@"TFNDirectMessageUser"), @selector(verified), (IMP) &overrideVerified, (IMP *) &origVerified);
	MSHookMessageEx(kClass(@"TFNDirectMessageUser"), @selector(displayFullName), (IMP) &overrideDisplayFullName, (IMP *) &origDisplayFullName);
	MSHookMessageEx(kClass(@"TFNDirectMessageUser"), @selector(displayUsername), (IMP) &overrideDisplayUsername, (IMP *) &origDisplayUsername);

	MSHookMessageEx(kClass(@"TFNTwitterCanonicalUser"), @selector(initWithCS2User:), (IMP) &overrideInitWithCS2User, (IMP *) &origInitWithCS2User);
	MSHookMessageEx(kClass(@"TFNTwitterCanonicalUser"), @selector(verified), (IMP) &overrideCanonicalUserVerified, (IMP *) &origCanonicalUserVerified);
	MSHookMessageEx(kClass(@"TFNTwitterCanonicalUser"), @selector(displayFullName), (IMP) &overrideCanonicalUserDisplayFullName, (IMP *) &origCanonicalUserDisplayFullName);
	MSHookMessageEx(kClass(@"TFNTwitterCanonicalUser"), @selector(displayUsername), (IMP) &overrideCanonicalUserDisplayUsername, (IMP *) &origCanonicalUserDisplayUsername);

	MSHookMessageEx(kClass(@"TFSTwitterEntityMedia"), @selector(mediaURL), (IMP) &overrideMediaURL, (IMP *) &origMediaURL);

	MSHookMessageEx(kClass(@"TFNTwitterStatus"), @selector(text), (IMP) &overrideText, (IMP *) &origText);
	MSHookMessageEx(kClass(@"TFNTwitterStatus"), @selector(originalText), (IMP) &overrideText, (IMP *) &origText);

	MSHookMessageEx(kClass(@"TFNDirectMessageConversation"), @selector(allEntries), (IMP) &overrideAllEntries, (IMP *) &origAllEntries);
	MSHookMessageEx(kClass(@"TFNDirectMessageConversation"), @selector(entryList), (IMP) &overrideEntryList, (IMP *) &origEntryList);
	MSHookMessageEx(kClass(@"TFNDirectMessageConversation"), @selector(latestEntry), (IMP) &overrideLatestEntry, (IMP *) &origLatestEntry);

	MSHookMessageEx(kClass(@"TFNDirectMessageEntry"), @selector(seenByAllParticipants), (IMP) &overrideSeenByAllParticipants, (IMP *) &origSeenByAllParticipants);
	MSHookMessageEx(kClass(@"TFNDirectMessageEntry"), @selector(seenByParticipants), (IMP) &overrideSeenByParticipants, (IMP *) &origSeenByParticipants);

}
