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
    UIView *windowOverlayView;
    NSMutableArray *tutorialsDisplayedThisSession;
    NSMutableDictionary *tutorialNameToFirstBalloonDictionary;
}

-(instancetype)init{
    self = [super init];
    tutorialsDisplayedThisSession = [NSMutableArray array];
    tutorialNameToFirstBalloonDictionary = [NSMutableDictionary dictionary];
    return self;
}

+(void)initialize{
    [super initialize];
    instance = [[CPTutorial alloc] init];
    instance->isCurrentlyRecordingSteps = NO;
}

+(UIView*)overlay{
    if(!instance->windowOverlayView){
        UIView *view = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.frame];
        view.backgroundColor = [UIColor clearColor];
        view.opaque = NO;
        view.userInteractionEnabled = NO;
        NSLog(@"CPTUTORIAL: user interaction disabled.. bunu duzelt");
        view.translatesAutoresizingMaskIntoConstraints = NO;
        UIView *keyWindow = [UIApplication sharedApplication].keyWindow;
        [keyWindow addSubview:view];
        //add constraints
        [keyWindow addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(0)-[view]-(0)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)]];
        [keyWindow addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[view]-(0)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)]];
        instance->windowOverlayView = view;
    }
    return instance->windowOverlayView;
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
    return [self shouldDisplayTutorialWithName:instance->currentTutorialName];
}

+(BOOL)displayWithName:(NSString*)tutorialName actions:(CPTutorialAction)actions{
    if(![CPTutorial shouldDisplayTutorialWithName:tutorialName]){
        return NO;
    }else{
        [CPTutorial beginStepsWithTutorialName:tutorialName];
        actions();
        [CPTutorial endSteps];
        return YES;
    }
}

+(void)cancelTutorialWithName:(NSString*)tutorialName{
    CPTutorialBalloon *initialBalloonOfTutorial = instance->tutorialNameToFirstBalloonDictionary[tutorialName];
    [initialBalloonOfTutorial hold];
}

+(void)beginStepsWithTutorialName:(NSString*)tutorialName{
    NSAssert(tutorialName.length, @"Tutorial must have a valid name!");
    [instance->tutorialsDisplayedThisSession addObject:tutorialName];
    instance->currentTutorialName = tutorialName;
    instance->isCurrentlyRecordingSteps = YES;
    instance->steps = [NSMutableArray array];
}

+(void)endSteps{
    instance->isCurrentlyRecordingSteps = NO;
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
    if(instance->steps.count){
        CPTutorialBalloon *first = [instance->steps firstObject];
        instance->tutorialNameToFirstBalloonDictionary[instance->currentTutorialName] = first;
        [first signal];
    }
}

+(BOOL)shouldDisplayTutorialWithName:(NSString*)name{
    if(!name){
        return YES;
    }
    if(instance->isCurrentlyRecordingSteps){
        return YES;
    }
    if([instance->tutorialsDisplayedThisSession containsObject:name]){
        return NO;
    }
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *targetKey = TIP_KEY(name);
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
