#import <UIKit/UIKit.h>
#import <stdlib.h>
#import "Twitter.h"

static BOOL enableTweak = false;
static NSString *targetUsername = NULL;
static BOOL spoofVerified = false;
static NSString *profilePictureURL = NULL;
static NSString *username = NULL;
static NSString *fullName = NULL;
static NSString *fakePostText = nil; // establishing nil superiority here >> :thishowitis:

static NSString *prefsKeys = @"/var/mobile/Library/Preferences/me.luki.runtimeoverflow.lctttwitter.plist";

static void loadPrefs() {

	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:prefsKeys];
	NSMutableDictionary *prefs = dict ? [dict mutableCopy] : [NSMutableDictionary dictionary];

	enableTweak = prefs[@"enableTweak"] ? [prefs[@"enableTweak"] boolValue] : NO;
	targetUsername = prefs[@"targetUsername"] ? prefs[@"targetUsername"] : NULL;
	spoofVerified = prefs[@"spoofVerified"] ? [prefs[@"spoofVerified"] boolValue] : NO;
	profilePictureURL = prefs[@"newProfilePictureURL"] ? prefs[@"newProfilePictureURL"] : NULL;
	username = prefs[@"newUsername"] ? prefs[@"newUsername"] : NULL;
	fullName = prefs[@"newFullName"] ? prefs[@"newFullName"] : NULL;
	fakePostText = prefs[@"fakePostText"] ? prefs[@"fakePostText"] : nil;

}

static NSInteger targetUserID = -1;
static NSMutableArray<TFNDirectMessageEntry *> *messages = NULL;

static TFNDirectMessageEntry * createMessage(NSString *message, id sender){
	TFNDirectMessageConversationEntryCanonicalIdentifier *identifier = [[%c(TFNDirectMessageConversationEntryCanonicalIdentifier) alloc] initWithCanonicalID:arc4random_uniform(1000000)];

	return [[%c(TFNDirectMessageEntry) alloc] initWithIdentifier:identifier sender:sender text:message entities:NULL attachment:NULL quickReplyRequest:NULL customProfile:NULL markedAsSpam:false markedAsAbuse:false time:NSDate.date ctas:NULL];
}

%hook TFNDirectMessageConversation
- (NSArray<TFNDirectMessageEntry *> *)allEntries {
	if(!self.isSelfConversation && self.participantsExcludingPerspectivalUser.count == 1 && self.participantsExcludingPerspectivalUser[0].participatingUser.userID == targetUserID) {

		if(!messages){
			messages = [NSMutableArray array];

			NSArray<NSDictionary *> *msgs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/me.luki.runtimeoverflow.lctttwittermessages.plist"][@"messages"];

			if(msgs) {
				for(NSDictionary *msg in msgs) {
					[messages addObject:createMessage(msg[@"message"], ((NSNumber *) msg[@"me"]).boolValue ? self.perspectivalParticipant.participatingUser : self.participantsExcludingPerspectivalUser[0].participatingUser)];
				}
			}
		}

		return messages;
	} else return %orig;
}

- (NSMutableArray<TFNDirectMessageEntry *> *)entryList{
	if(!self.isSelfConversation && self.participantsExcludingPerspectivalUser.count == 1 && self.participantsExcludingPerspectivalUser[0].participatingUser.userID == targetUserID) {
		return [self allEntries].mutableCopy;
	} else return %orig;
}

- (TFNDirectMessageEntry *)latestEntry{
	if(!self.isSelfConversation && self.participantsExcludingPerspectivalUser.count == 1 && self.participantsExcludingPerspectivalUser[0].participatingUser.userID == targetUserID) {
		NSArray<TFNDirectMessageEntry *> *messages = [self allEntries];
		if(messages.count > 0) return messages[messages.count - 1];
		else return NULL;
	} else return %orig;
}

%end

%hook TFNDirectMessageUser
- (void)setDirectMessageUser:(TFSDirectMessageUser *)user{
	%orig;

	if([user.username isEqualToString:targetUsername]) targetUserID = user.userID;
}

- (BOOL)verified {
	if(self.userID == targetUserID) return spoofVerified;
	else return %orig;
}

- (NSString *)displayUsername {
	if(self.userID == targetUserID && username && ![username isEqualToString:@""]) return [NSString stringWithFormat:@"@%@", username];
	else return %orig;
}

- (NSString *)displayFullName {
	if(self.userID == targetUserID && fullName && ![fullName isEqualToString:@""]) return fullName;
	else return %orig;
}
%end

%hook TFSDirectMessageUser
- (id)profileImageMediaEntity {
	id media = %orig;

	if(self.userID == targetUserID && profilePictureURL && ![profilePictureURL isEqualToString:@""]) MSHookIvar<NSString *>(media, "_mediaURL") = profilePictureURL;

	return media;
}
%end


// Posts

%hook TFNTwitterStatus


- (NSString *)text {

	if(self.fromUserID == targetUserID) return fakePostText;
	else return %orig;

}

- (NSString *)fullText {

	if(self.fromUserID == targetUserID) return fakePostText;
	else return %orig;

}

- (NSString *)displayText {

	if(self.fromUserID == targetUserID) return fakePostText;
	else return %orig;

}

- (NSString *)originalText {

	if(self.fromUserID == targetUserID) return fakePostText;
	else return %orig;

}

%end

%hook TFNTwitterCanonicalUser

- (TFNTwitterCanonicalUser *)initWithCS2User:(id)user{

	TFNTwitterCanonicalUser *userr = %orig;

	if([userr.username isEqualToString:targetUsername]) targetUserID = userr.userID;

	return userr;

}

- (id)profileImageMediaEntity {

	id media = %orig;

	if(self.userID == targetUserID && profilePictureURL && ![profilePictureURL isEqualToString:@""]) MSHookIvar<NSString *>(media, "_mediaURL") = profilePictureURL;

	return media;

}

- (BOOL)verified {

	if(self.userID == targetUserID) return spoofVerified;
	else return %orig;

}

- (NSString *)displayUsername {

	if(self.userID == targetUserID && username && ![username isEqualToString:@""]) return [NSString stringWithFormat:@"@%@", username];
	else return %orig;

}

- (NSString *)displayFullName {

	if(self.userID == targetUserID && fullName && ![fullName isEqualToString:@""]) return fullName;
	else return %orig;

}

%end


%ctor {

	loadPrefs();
	if(enableTweak && targetUsername && targetUsername.length > 0) %init;

}
