//
//  Created by Can Poyrazoğlu on 23.11.14.
//

#import <UIKit/UIKit.h>

extern NSString *const CPTutorialSettingBorderColor;
extern NSString *const CPTutorialSettingBorderWidth;
extern NSString *const CPTutorialSettingCornerRadius;
extern NSString *const CPTutorialSettingTipSize;
extern NSString *const CPTutorialSettingFillColor;
extern NSString *const CPTutorialSettingManualTipPosition;
extern NSString *const CPTutorialSettingTipAboveBalloon;
extern NSString *const CPTutorialSettingDismissOnTouch;
extern NSString *const CPTutorialSettingAnimationType;
extern NSString *const CPTutorialSettingDisplayDelay;
extern NSString *const CPTutorialSettingContentPadding;


IB_DESIGNABLE
@interface CPTutorialBalloon : UIView

+(NSMutableDictionary*)defaultSettings;

//view that this tip is attached to set 
@property(nonatomic) IBOutlet UIView *targetView;

//border color of the balloon
@property IBInspectable UIColor *borderColor;

//border width of the balloon
@property IBInspectable float borderWidth;

//corner radius of the balloon
@property(nonatomic) IBInspectable float cornerRadius;
@property IBInspectable CGSize tipSize;
@property IBInspectable UIColor *fillColor;
@property IBInspectable BOOL manualTipPosition;
@property IBInspectable BOOL tipAboveBalloon;
@property IBInspectable BOOL dismissOnTouch;
@property IBInspectable NSString *animationType; //currently supported: fade, collapse, none. default: collapse
@property IBInspectable float displayDelay;
//unique name of the tip
@property IBInspectable float contentPadding;
@property IBInspectable NSString *tipName;
//text to display. can be nil.
@property(nonatomic) IBInspectable NSString *text;

@end
