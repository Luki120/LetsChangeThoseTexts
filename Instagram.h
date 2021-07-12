@interface IGDirectPublishedMessageMetadata
@property (nonatomic, readonly) NSString *serverId;
@property (nonatomic, readonly) NSString *clientContext;
- (instancetype)initWithServerTimestamp:(NSDate *)timestamp serverId:(NSString *)serverId clientContext:(NSString *)clientContext threadId:(NSString *)threadId senderPk:(NSString *)senderPk;
@end

@interface IGDirectPublishedMessageContent
+ (instancetype)media:(id)media;
+ (instancetype)reshareWithAttackment:(id)attachment comment:(id)comment;
+ (instancetype)textWithString:(NSString *)text mentionedUserPks:(NSArray *)mentionedUserPks mentionedUsers:(NSArray *)users;
@end

@interface IGDirectPublishedMessage
@property (nonatomic, readonly) IGDirectPublishedMessageMetadata *metadata;
- (instancetype)initWithMetadata:(IGDirectPublishedMessageMetadata *)metadata content:(IGDirectPublishedMessageContent *)content quotedMessage:(id)quotedMessage reactions:(NSArray *)reactions forwardMetadata:(id)forwardMetadata powerupsMetadata:(id)powerupsMetadata violationReview:(id)violationReview instantReplies:(NSArray *)replies isShhMode:(BOOL)shhMode;
@end

@interface IGUser
@property (atomic, copy, readwrite) NSString *pk;
@end

@interface IGDirectThreadMetadata
@property (nonatomic, assign, readonly) BOOL isGroup;
@property (nonatomic, copy, readonly) NSArray<IGUser *> *users;
@end

@interface IGDirectUIThread
- (NSString *)threadId;
- (IGDirectThreadMetadata *)metadata;
- (id)initWithThreadKey:(id)threadKey threadId:(id)threadId viewerId:(id)viewerId threadIdV2ForInboxPaging:(id)threadIdV2ForInboxPaging metadata:(id)metadata visualMessageInfo:(id)visualMessageInfo publishedMessageSet:(id)publishedMessageSet publishedMessagesInCurrentThreadRange:(id)publishedMessagesInCurrentThreadRange outgoingMessageSet:(id)outgoingMessageSet threadMessagesRange:(id)threadMessagesRange messageIslandRange:(id)messageIslandRange;
@end

@interface IGProfilePictureImageView
@property (nonatomic, assign, readonly) IGUser *user;

- (void)_setImageFromImage:(UIImage *)image shouldProcess:(BOOL)shouldProcess;
@end

@interface IGProfilePictureImageProcessor : NSObject
- (UIImage *)processedImageFromImage:(UIImage *)image;
@end

@interface IGImageView : UIImageView
@property (nonatomic, strong, readwrite) IGProfilePictureImageProcessor *imageProcessor;
@end

@interface IGDirectPublishedMessageSet : NSObject
- (instancetype)initWithSortedMessages:(NSArray *)messages messagesByServerId:(NSDictionary *)messagesByServerId messagesByClientContext:(NSDictionary *)messagesByClientContext;
@end

@interface IGUserStore : NSObject
- (IGUser *)storedUserWithUsername:(NSString *)username;
- (IGUser *)userWithPK:(NSString *)pk;
@end

@interface IGUserSession : NSObject
- (NSString *)pk;
@end

@interface IGWindow : UIWindow
@property (nonatomic, weak, readwrite) IGUserSession *userSession;
@end

@interface IGAppDelegate : NSObject
@property (nonatomic, strong, readwrite) IGWindow *window;
@end