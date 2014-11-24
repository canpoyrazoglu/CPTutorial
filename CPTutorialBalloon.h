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
extern NSString *const CPTutorialSettingTextColor;
extern NSString *const CPTutorialSettingDisplaysTip;
extern NSString *const CPTutorialSettingFontSize;
extern NSString *const CPTutorialSettingFontName;



IB_DESIGNABLE
@interface CPTutorialBalloon : UIView

+(NSMutableDictionary*)defaultSettings;

//text to display. can be nil.
@property(nonatomic) IBInspectable NSString *text;

@property(nonatomic) IBInspectable NSString *tipName;

//view that this tip is attached to set 
@property(nonatomic) IBOutlet UIView *targetView;

//border color of the balloon
@property IBInspectable UIColor *borderColor;

//border width of the balloon
@property IBInspectable float borderWidth;

//text color of the balloon
@property(nonatomic) IBInspectable UIColor *textColor;

//font size of the text
@property(nonatomic) IBInspectable float fontSize;

//font name of the text. accepts both plain text "Helvetica Neue Light" and iOS-friendly "HelveticaNeue-Light" names. here is a nice list for you: http://iosfonts.com
@property(nonatomic) IBInspectable NSString *fontName;

//fill color of the balloon
@property IBInspectable UIColor *fillColor;

//corner radius of the balloon
@property(nonatomic) IBInspectable float cornerRadius;

//whether the balloon displays tip or not.
@property(nonatomic) IBInspectable BOOL displaysTip;

//size of the tip from balloon to target view
@property IBInspectable CGSize tipSize;

@property IBInspectable BOOL manualTipPosition;
@property IBInspectable BOOL tipAboveBalloon;
@property IBInspectable BOOL dismissOnTouch;
@property IBInspectable NSString *animationType; //currently supported: fade, collapse, none. default: collapse
@property IBInspectable float displayDelay;
//unique name of the tip
@property IBInspectable float contentPadding;



@end
