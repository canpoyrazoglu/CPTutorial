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

#import <Foundation/Foundation.h>
#import "CPTutorialBalloon.h"
#import "UIView+CPTutorial.h"



@interface CPTutorial : NSObject

+(BOOL)shouldDisplayTipWithName:(NSString*)tipName;
+(void)markTipCompletedWithTipName:(NSString*)tipName;
+(UILabel*)label;

+(void)beginStepsWithTutorialName:(NSString*)tutorialName;
+(void)endSteps;

//to be called internally. don't call this method
+(void)processTutorialBalloon:(CPTutorialBalloon*)balloon;
+(BOOL)isRecordingValidTutorial;

@end

