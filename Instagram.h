@interface IGDirectPublishedMessageMetadata
- (instancetype)initWithServerTimestamp:(NSDate *)timestamp serverId:(NSString *)serverId clientContext:(NSString *)clientContext threadId:(NSString *)threadId senderPk:(NSString *)senderPk;
@end

@interface IGDirectPublishedMessageContent
+ (instancetype)media:(id)media;
+ (instancetype)reshareWithAttackment:(id)attachment comment:(id)comment;
+ (instancetype)textWithString:(NSString *)text mentionedUserPks:(NSArray *)mentionedUserPks mentionedUsers:(NSArray *)users;
@end

@interface IGDirectPublishedMessage
- (instancetype)initWithMetadata:(IGDirectPublishedMessageMetadata *)metadata content:(IGDirectPublishedMessageContent *)content quotedMessage:(id)quotedMessage reactions:(NSArray *)reactions forwardMetadata:(id)forwardMetadata powerupsMetadata:(id)powerupsMetadata violationReview:(id)violationReview instantReplies:(NSArray *)replies isShhMode:(BOOL)shhMode;
@end

@interface IGUser
@property (atomic, copy, readwrite) NSString *pk;
@end

@interface IGDirectThreadMetadata
- (NSArray<IGUser *> *)users;
@end

@interface IGDirectUIThread
- (NSString *)threadId;
- (IGDirectThreadMetadata *)metadata;
@end