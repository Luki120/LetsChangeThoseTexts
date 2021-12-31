#import "Headers/Constants.h"
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListController.h>


@interface LCTTMessagesDelegate : NSObject <UITableViewDelegate, UITableViewDataSource>
@end


@interface LCTTMessagesVC : PSListController <UITextFieldDelegate>
@end


@interface NSUserDefaults ()
- (id)objectForKey:(id)arg1 inDomain:(id)arg2;
- (void)setObject:(id)arg1 forKey:(id)arg2 inDomain:(id)arg3;
@end
