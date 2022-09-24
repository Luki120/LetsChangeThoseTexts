#import "Headers/Constants.h"


@interface IGDirectPublishedMessageMetadata
@property (nonatomic, readonly) NSString *serverId;
@property (nonatomic, readonly) NSString *clientContext;
- (instancetype)initWithServerTimestamp:(NSDate *)timestamp serverId:(NSString *)serverId clientContext:(NSString *)clientContext threadId:(NSString *)threadId senderPk:(NSString *)senderPk isBusinessSuggestionProcessed:(BOOL)isBusinessSuggestionProcessed;
@end


@interface IGDirectPublishedMessageContent
+ (instancetype)textWithString:(NSString *)text translatedString:(NSString *)translatedString mentionedUserPks:(NSArray *)mentionedUserPks messageCommands:(id)messageCommands sendSilently:(BOOL)sendSilently textFormatters:(id)textFormatters;
@end


@interface IGDirectPublishedMessage
@property (nonatomic, readonly) IGDirectPublishedMessageMetadata *metadata;
- (instancetype)initWithMetadata:(IGDirectPublishedMessageMetadata *)metadata content:(IGDirectPublishedMessageContent *)content collectionSaveIconState:(NSInteger)iconState quotedMessage:(id)quotedMessage reactions:(NSArray *)reactions forwardMetadata:(id)forwardMetadata powerupsMetadata:(id)powerupsMetadata violationReview:(id)violationReview instantReplies:(NSArray *)replies auxiliaryContent:(id)auxiliaryContent isShhMode:(BOOL)shhMode;
@end


@interface IGDirectLastSeenMessageInfo
- (instancetype)initWithMessageId:(NSString *)messageId seenAtTimestamp:(NSDate *)timestamp shhMessageSeenInfo:(id)info;
@end


@interface IGDirectPublishedMessageSet : NSObject
- (instancetype)initWithSortedMessages:(NSArray *)messages messagesByServerId:(NSDictionary *)messagesByServerId messagesByClientContext:(NSDictionary *)messagesByClientContext;
@end


@interface IGUser
@property (atomic, copy) NSString *pk;
@end


@interface IGDirectThreadMetadata
@property (assign, nonatomic, readonly) BOOL isGroup;
@property (copy, nonatomic, readonly) NSArray<IGUser *> *users;
@end


@interface IGDirectUIThread
- (NSString *)threadId;
- (IGDirectThreadMetadata *)metadata;
- (id)initWithThreadKey:(id)threadKey threadId:(id)threadId viewerId:(id)viewerId threadIdV2ForInboxPaging:(id)threadIdV2ForInboxPaging metadata:(id)metadata visualMessageInfo:(id)visualMessageInfo publishedMessageSet:(id)publishedMessageSet publishedMessagesInCurrentThreadRange:(id)publishedMessagesInCurrentThreadRange outgoingMessageSet:(id)outgoingMessageSet threadMessagesRange:(id)threadMessagesRange messageIslandRange:(id)messageIslandRange;
@end


@interface IGProfilePictureImageView
@property (assign, nonatomic, readonly) IGUser *user;
- (void)_setImageFromImage:(UIImage *)image shouldProcess:(BOOL)shouldProcess;
@end


@interface IGUserStore : NSObject
- (IGUser *)storedUserWithUsername:(NSString *)username;
- (IGUser *)userWithPK:(NSString *)pk;
@end


@interface IGUserSession : NSObject
- (NSString *)pk;
@end


@interface IGWindow : UIWindow
@property (nonatomic, weak) IGUserSession *userSession;
@end


@interface IGAppDelegate : NSObject
@property (nonatomic, strong) IGWindow *window;
@end
