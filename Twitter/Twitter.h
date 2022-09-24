#import "Headers/Constants.h"


@interface TFNDirectMessageConversationEntryCanonicalIdentifier : NSObject
- (instancetype)initWithCanonicalID:(NSInteger)identifier;
@end


@interface TFNTwitterCanonicalUser : NSObject
@property (assign, nonatomic, readonly) NSInteger userID;
@property (copy, nonatomic, readonly) NSString *username;
@end


@interface TFNDirectMessageUser : TFNTwitterCanonicalUser // Hacky solution, does not actually subclass TFNTwitterCanonicalUser
@end


@interface TFSDirectMessageUser : TFNDirectMessageUser // Again not subclassing TFNDirectMessageUser
@end


@interface TFNTwitterStatus : NSObject
@property (assign, nonatomic, readonly) NSInteger fromUserID;
@end


@interface TFSTwitterEntityMedia : NSObject
@end


@interface T1DirectMessageConversation : NSObject // We need to move this up for TFNDirectMessageConversationParticipant & TFNDirectMessageEntry
@end


@interface TFNDirectMessageConversation : T1DirectMessageConversation // Bad practises go brrr, but what can you do when you're lazy
@end


@interface TFNDirectMessageEntry : NSObject
@property (nonatomic, weak) TFNDirectMessageConversation *conversation;
- (instancetype)initWithIdentifier:(id)identifier sender:(id)sender text:(id)text entities:(id)entities attachment:(id)attachment quickReplyRequest:(id)quickReplyRequest customProfile:(id)customProfile markedAsSpam:(BOOL)markedAsSpam markedAsAbuse:(BOOL)markedAsAbuse time:(id)time ctas:(id)ctas searchTokens:(id)searchTokens;
@end


@interface TFNDirectMessageConversationParticipant : NSObject
@property (assign, nonatomic, readonly) TFNDirectMessageUser *participatingUser;
@property (nonatomic, weak) TFNDirectMessageConversation *conversation;
@end


@interface T1DirectMessageConversation () // Extension to T1DirectMessageConversation beacuse the initial declaration is above
@property (assign, nonatomic, readonly) NSArray<TFNDirectMessageConversationParticipant *> *participantsExcludingPerspectivalUser;
@property (assign, nonatomic, readonly) TFNDirectMessageConversationParticipant *perspectivalParticipant;
@property (assign, nonatomic, readonly) BOOL isSelfConversation;
- (NSArray<TFNDirectMessageEntry *> *)allEntries;
@end
