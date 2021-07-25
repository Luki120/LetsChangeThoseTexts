@interface TFNDirectMessageConversationEntryCanonicalIdentifier : NSObject
- (instancetype)initWithCanonicalID:(NSInteger)identifier;
@end

@interface T1DirectMessageConversation : NSObject //We need to move this up for TFNDirectMessageConversationParticipant & TFNDirectMessageEntry
@end

@interface TFNDirectMessageConversation : T1DirectMessageConversation //Bad practises go brrr, but what can you do when you're lazy
@end

@interface TFNDirectMessageEntry : NSObject
@property (nonatomic, assign, readonly) NSInteger messageID;
@property (nonatomic, weak, readwrite) TFNDirectMessageConversation *conversation;

- (instancetype)initWithIdentifier:(id)identifier sender:(id)sender text:(id)text entities:(id)entities attachment:(id)attachment quickReplyRequest:(id)quickReplyRequest customProfile:(id)customProfile markedAsSpam:(BOOL)markedAsSpam markedAsAbuse:(BOOL)markedAsAbuse time:(id)time ctas:(id)ctas;
@end

@interface TFNTwitterCanonicalUser : NSObject
@property (nonatomic, assign, readonly) NSInteger userID;
@property (nonatomic, copy, readonly) NSString *username;
@end

@interface TFNDirectMessageUser : TFNTwitterCanonicalUser //Hacky solution, does not actually subclass TFNTwitterCanonicalUser
@end

@interface TFSDirectMessageUser : TFNDirectMessageUser //Again not subclassing TFNDirectMessageUser
@end

@interface TFNDirectMessageConversationParticipant : NSObject
@property (nonatomic, assign, readonly) TFNDirectMessageUser *participatingUser;
@property (nonatomic, weak, readwrite) TFNDirectMessageConversation *conversation;
@end

@interface T1DirectMessageConversation () //Extension to T1DirectMessageConversation beacuse the initial declaration is above
@property (nonatomic, assign, readonly) NSArray<TFNDirectMessageConversationParticipant *> *participantsExcludingPerspectivalUser;
@property (nonatomic, assign, readonly) TFNDirectMessageConversationParticipant *perspectivalParticipant;
@property (nonatomic, assign, readonly) BOOL isSelfConversation;

- (NSArray<TFNDirectMessageEntry *> *)allEntries;
@end

@interface TFNTwitterStatus : NSObject
@property (nonatomic, assign, readonly) NSInteger fromUserID;
@end

@interface TFNTwitterUser : NSObject
@property (nonatomic, assign, readonly) NSInteger userID;
@end
