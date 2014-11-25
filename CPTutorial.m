//
//  CPTutorial.m
//
//  Created by Can Poyrazoğlu on 27.10.14.
//

#import "CPTutorial.h"

#define TIP_NAME_FORMAT (@"_CPTutorialTip_%@")
#define TIP_KEY(x) ([NSString stringWithFormat:TIP_NAME_FORMAT, x])
#define CPTUTORIAL_NOOP (^{})

static CPTutorial *instance;

@implementation CPTutorial{
    BOOL isCurrentlyRecordingSteps;
    NSMutableArray *steps;
    NSString *currentTutorialName;
}

+(void)initialize{
    [super initialize];
    instance = [[CPTutorial alloc] init];
    instance->isCurrentlyRecordingSteps = NO;
}

+(void)processTutorialBalloon:(CPTutorialBalloon*)balloon{
    if(instance->isCurrentlyRecordingSteps){
        balloon.shouldFireDismissHandlerEvenIfDisplayIsSkipped = YES;
        [balloon hold];
        if(instance->steps.count){
            CPTutorialBalloon *previous = [instance->steps lastObject];
            CPTutorialAction handler = previous.dismissHandler;
            if(!handler){
                handler = CPTUTORIAL_NOOP;
            }
            handler = ^{
                handler();
                [balloon signal];
            };
            previous.dismissHandler = handler;
        }
        [instance->steps addObject:balloon];
    }
}

//determines if the current tutorial context is valid or invalid (e.g. displayed before)
+(BOOL)isRecordingValidTutorial{
    return [self shouldDisplayTipWithName:instance->currentTutorialName];
}

+(void)beginStepsWithTutorialName:(NSString*)tutorialName{
    NSAssert(tutorialName.length, @"Tutorial must have a valid name!");
    instance->currentTutorialName = tutorialName;
    instance->isCurrentlyRecordingSteps = YES;
    instance->steps = [NSMutableArray array];
}

+(void)endSteps{
    instance->isCurrentlyRecordingSteps = NO;
    if(instance->steps.count){
        CPTutorialBalloon *first = [instance->steps firstObject];
        [first signal];
    }
    if(instance->steps.count){
        CPTutorialBalloon *last = [instance->steps lastObject];
        CPTutorialAction handler = last.dismissHandler;
        if(!handler){
            handler = CPTUTORIAL_NOOP;
        }
        handler = ^{
            handler();
            [CPTutorial markTipCompletedWithTipName:instance->currentTutorialName];
        };
        last.dismissHandler = handler;
    }
}

+(BOOL)shouldDisplayTipWithName:(NSString*)tipName{
    if(!tipName){
        return YES;
    }
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *targetKey = TIP_KEY(tipName);
    id val = [settings valueForKey:targetKey];
    if([val isEqualToString:@"done"]){
        return NO;
    }else{
        return YES;
    }
}

+(void)markTipCompletedWithTipName:(NSString*)tipName{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *targetKey = TIP_KEY(tipName);
    [settings setValue:@"done" forKey:targetKey];
    [settings synchronize];
}

+(UILabel*)label{
    return [[UILabel alloc] initWithFrame:CGRectZero];
}

@end
