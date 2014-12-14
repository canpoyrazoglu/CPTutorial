//
//  CPTutorial.h
//
//  Created by Can Poyrazoğlu on 27.10.14.
//

#ifndef SCREEN_WIDTH
#define SCREEN_WIDTH ([UIApplication sharedApplication].keyWindow.frame.size.width)
#endif

#ifndef SCREEN_HEIGHT
#define SCREEN_HEIGHT ([UIApplication sharedApplication].keyWindow.frame.size.height)
#endif

@protocol CPTutorialView<NSObject>

@required

-(UIView*)tutorialView;
-(void)attachedViewFrameDidChange:(CGRect)newFrame;
-(void)setHidden:(BOOL)hidden;

@end

typedef void (^CPTutorialAction)();

#import <Foundation/Foundation.h>
#import "CPTutorialBalloon.h"
#import "UIView+CPTutorial.h"

@class CPTutorialBalloon;



@interface CPTutorial : NSObject

+(BOOL)shouldDisplayTutorialWithName:(NSString*)name;
+(void)markTipCompletedWithTipName:(NSString*)tipName;
+(UILabel*)label;

+(void)beginStepsWithTutorialName:(NSString*)tutorialName;
+(void)endSteps;

/**
 Displays a series of tutorial balloons sequentially.
 
 Usage:
 Use the following code in the view controller's @c viewDidAppear: method:
 @code
 [CPTutorial displayWithName:tutorialName actions:^{
   [someView displayBalloonTip:@"First tip"];
   [anotherView displayBalloonTip:@"Second tip"];
 }];
 @endcode
 @param tutorialName
 Name of the tutorial. This can be anything as long as it's unique in your app. It will determine whether this tutorial is going to be displayed ever again or not.
 @return YES if the tutorial is displaying, NO if it won't be displayed (in case it has been displayed before in a previous session).
 */
+(BOOL)displayWithName:(NSString*)tutorialName actions:(CPTutorialAction)actions;

/** Prevents the currently waiting (delayed) tutorial from being displayed.
 @param tutorialName
 Name of the tutorial to cancel.
 @warning This method will not function if the tutorial has already started displaying the first balloon.
 */
+(void)cancelTutorialWithName:(NSString*)tutorialName;

/// Internal method. DO NOT call this method.
+(void)processTutorialBalloon:(CPTutorialBalloon*)balloon;
+(BOOL)isRecordingValidTutorial;
+(UIView*)overlay;

@end