//
//  Created by Can Poyrazoğlu on 23.11.14.
//

#import <UIKit/UIKit.h>
#import "CPTutorial.h"

@class CPTutorial;

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
extern NSString *const CPTutorialSettingHorizontalMargin;
extern NSString *const CPTutorialSettingShadowEnabled;
extern NSString *const CPTutorialSettingShadowColor;
extern NSString *const CPTutorialSettingShadowBlurRadius;


//animation types

/// No animation.
extern NSString *const CPTutorialAnimationTypeNone;

/// Fade animation.
extern NSString *const CPTutorialAnimationTypeFade;

///Collapsing animation.
extern NSString *const CPTutorialAnimationTypeCollapse;

typedef enum{
    TutorialBalloonStateWaitingForSignal,
    TutorialBalloonStateWaitingForDelay,
    TutorialBalloonStateAnimatingIn,
    TutorialBalloonStateDisplaying,
    TutorialBalloonStateAnimatingOut,
    TutorialBalloonStateDismissed,
    
    TutorialBalloonStateDesignMode
}TutorialBalloonState;

typedef NSDictionary CPTutorialBalloonStyle;


IB_DESIGNABLE
@interface CPTutorialBalloon : UIView<CPTutorialView>

+(NSMutableDictionary*)defaultSettings;

/// Text to display. Can be @c nil.
@property(nonatomic) IBInspectable NSString *text;

/// Name of the tip. It should be a unique string within your app, to identify and display your tip only once.
@property(nonatomic) IBInspectable NSString *tipName;

/// View that this tip is attached to. When displayed, the balloon and tip will be "attached" to this view.
@property(nonatomic) IBOutlet UIView *targetView;

/// Border color of the balloon.
@property(nonatomic) IBInspectable UIColor *borderColor;

/// Border width of the balloon.
@property IBInspectable float borderWidth;

/// Whether the balloon displays a shadow underneath or not.
@property(nonatomic) IBInspectable BOOL shadowEnabled;

/// Color of the shadow, if exists.
@property(nonatomic) IBInspectable UIColor *shadowColor;

/// Blur radius of the shadow, if it exists
@property(nonatomic) IBInspectable float shadowBlurRadius;

/// Whether the balloon displays its tip or not.
@property(nonatomic) IBInspectable BOOL displaysTip;

/// Text color of the balloon.
@property(nonatomic) IBInspectable UIColor *textColor;

/// Font size of the text.
@property(nonatomic) IBInspectable float fontSize;

/** Font name of the text. Accepts both plain text "Helvetica Neue Light" and iOS-friendly "HelveticaNeue-Light" names. Custom fonts in your bundle should also work, though honestly I haven't tested it. 
 @see Full list of iOS fonts: http://iosfonts.com.
 */
@property(nonatomic) IBInspectable NSString *fontName;

/// Corner radius of the balloon.
@property(nonatomic) IBInspectable float cornerRadius;

/// Size of the tip from balloon to target view, if displayed.
@property IBInspectable CGSize tipSize;

/// Whether tip will be manually positioned by developer (hey, it's you!) or automatically on layout.
@property IBInspectable BOOL manualTipPosition;

/// Set to YES for displaying the tip above the balloon. Works only if @c manualTipPosition is set to YES.
@property IBInspectable BOOL tipAboveBalloon;

/// Sets whether the balloon dismisses itself or not, when touched.
@property IBInspectable BOOL dismissOnTouch;

/** Animation type of appearing and dismissing of the balloon.
 @see @c CPTutorialAnimationType constants.
 */
@property IBInspectable NSString *animationType; //currently supported: fade, collapse, none. default: collapse

/// Delay before displaying the balloon, in seconds.
@property(nonatomic) IBInspectable float displayDelay;

/// Content padding inside the tip, in points.
@property IBInspectable float contentPadding;

/// Horizontal margin size of the baloon, in points.
@property(nonatomic) IBInspectable float horizontalMargin;

/**
 Set YES to make the appearance of this balloon default for all balloons this session.
 @warning Setting this property to YES on multiple balloons on the same view simultaneously has undefined behavior.
 */
@property IBInspectable BOOL definesStyle;

/// Handler block to be fired when balloon is dismissed. Can be nil.
@property(copy) CPTutorialAction dismissHandler;

@property BOOL shouldFireDismissHandlerEvenIfDisplayIsSkipped;
@property BOOL isManagedExternally;

/// Set YES to enable resizing the balloon according to it's contents (e.g. number of lines of text etc). Interface Builder-designed balloons normally wouldn't need this property, unless their text is dynamic.
@property(nonatomic) IBInspectable BOOL shouldResizeItselfAccordingToContents;

@property(nonatomic) TutorialBalloonState balloonState;
@property(readonly, nonatomic) UILabel *textLabel;

@property(copy) CPTutorialAction blockToExecuteBeforeDisplaying;

-(instancetype)hold;
-(instancetype)signal;

/// Dismisses the balloon.
-(instancetype)dismiss;

/// Convenience method for setting dismiss handler. Returns the balloon itself for method chaining.
-(instancetype)whenDismissed:(CPTutorialAction)handler;

/// Delays the display of this balloon, and returns itself, enabling method chaining.
-(CPTutorialBalloon*)delay:(float)delayInSeconds;

/** Makes all balloons look like this
 @seealso definesStyle
 */
-(void)makeStyleDefaultForAllBalloons;

@property(nonatomic) CPTutorialBalloonStyle *style;

-(instancetype)withStyle:(CPTutorialBalloonStyle*)style;
-(instancetype)withoutObeyingBounds;
-(instancetype)obeyingBounds;
-(instancetype)provideStyleToTutorial;

@property(nonatomic) CPTutorial *tutorial;
@property CPTutorialBalloon *nextBalloon;
@property BOOL shouldHoldAfterBeingDismissed;
@property BOOL shouldDisplayEvenOutsideTheViewBounds;

@end
