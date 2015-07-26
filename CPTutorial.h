//
//  CPTutorial.h
//
//  Created by Can Poyrazoğlu on 27.10.14.
//

#ifndef CPTUTORIAL_SCREEN_WIDTH
#define CPTUTORIAL_SCREEN_WIDTH ([UIApplication sharedApplication].keyWindow.frame.size.width)
#endif

#ifndef CPTUTORIAL_SCREEN_HEIGHT
#define CPTUTORIAL_SCREEN_HEIGHT ([UIApplication sharedApplication].keyWindow.frame.size.height)
#endif

#ifndef CPTUTORIAL_WINDOWFRAME
#define CPTUTORIAL_WINDOWFRAME ([UIApplication sharedApplication].keyWindow.frame)
#endif

@protocol CPTutorialView<NSObject>

@required

-(UIView*)tutorialView;
-(void)attachedViewFrameDidChange:(CGRect)newFrame;
-(void)setHidden:(BOOL)hidden;

@end

typedef void (^CPTutorialAction)();
typedef void (^CPTutorialCompletion)(BOOL didDisplay);

#import <Foundation/Foundation.h>
#import "CPTutorialBalloon.h"
#import "UIView+CPTutorial.h"
#import "CPTutorialDisplayability.h"
#import "CPTutorialDisplayable.h"

@interface CPTutorial : NSObject

@property(readonly) NSString *name;
@property(readonly) CPTutorialBalloon *firstBalloon;
@property(readonly) CPTutorialBalloon *currentBalloon;
@property CPTutorialBalloonStyle *style;

+(BOOL)shouldDisplayTutorialWithName:(NSString*)name;
+(void)markTutorialAsCompleted:(NSString*)tipName;

+(CPTutorial*)beginStepsWithTutorialName:(NSString*)tutorialName;
+(CPTutorial*)endSteps;

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
 @param actions
 Tutorial block to execute. Multiple calls to display methods are managed by the framework and they will display one after another properly after dismissal.
 @note If the tutorial has been displayed before, the action block will not execured at all. It can be safely used for executing one-time events 
 @return The tutorial if the tutorial is displaying, or nil if it won't be displayed (in case it has been displayed before in a previous session).
 */
+(CPTutorial*)displayWithName:(NSString*)tutorialName actions:(CPTutorialAction)actions;

+(CPTutorial*)displayWithName:(NSString*)tutorialName forceIfAlreadyCompleted:(BOOL)forceIfCompleted actions:(CPTutorialAction)actions;

/** Prevents the currently waiting (delayed) tutorial from being displayed.
 @param tutorialName
 Name of the tutorial to cancel.
 @warning This method will not function if the tutorial has already started displaying the first balloon.
 */
+(instancetype)cancel:(NSString*)tutorialName;

+(instancetype)pause:(NSString*)tutorialName;
+(instancetype)resume:(NSString*)tutorialName;

-(instancetype)pause;
-(instancetype)resume;
-(instancetype)cancel;
-(instancetype)refresh;
-(instancetype)step;
-(instancetype)resumeIfOn:(id)target;
-(instancetype)pauseIfOn:(id)target;

-(instancetype)insert:(CPTutorialAction)actions;



+(CPTutorial*)currentTutorial;
-(void)addBalloon:(CPTutorialBalloon*)balloon;
-(instancetype)completeWith:(CPTutorialAction)completion;
+(UIView*)placeholderAt:(CGRect)frame;
+(CPTutorialDisplayable*)targetTouchIndicatorAt:(CGRect)frame;
+(CPTutorialDisplayable*)targetTouchIndicatorAt:(CGRect)frame withAnimationDelay:(NSTimeInterval)delay;

+(CPTutorialDisplayable*)targetTouchIndicatorAt:(CGRect)frame withAnimationDelay:(NSTimeInterval)delay extraVisible:(BOOL)extraVisible;

@end
