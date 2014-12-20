//
//  CPTutorial.m
//
//  Created by Can Poyrazoğlu on 27.10.14.
//

#import "CPTutorial.h"
#import "CPTutorialInvisibleProxyView.h"

#define CPTUTORIAL_NAME_FORMAT (@"_CPTutorial_%@")
#define CPTUTORIAL_KEY(x) ([NSString stringWithFormat:CPTUTORIAL_NAME_FORMAT, x])
#define CPTUTORIAL_NOOP (^{})

static CPTutorial *current;
static NSMutableDictionary *tutorials;
static NSMutableArray *tutorialsDisplayedThisSession;

@implementation CPTutorial{
    UIView *windowOverlayView;
    CPTutorialBalloon *lastAddedBalloon;
    CPTutorialAction completionHandler;
}

-(instancetype)pause{
    self.currentBalloon.shouldHoldAfterBeingDismissed = YES;
    [self.currentBalloon dismiss];
    _currentBalloon = self.currentBalloon.nextBalloon;
    [self checkCompletion];
    return self;
}

-(instancetype)resume{
    self.currentBalloon.shouldHoldAfterBeingDismissed = NO;
    [self.currentBalloon signal];
    [self refresh];
    return self;
}

-(void)checkCompletion{
    if(!self.currentBalloon){
        [CPTutorial markTutorialAsCompleted:self.name];
        if(completionHandler){
            completionHandler();
        }
    }
}

-(instancetype)insert:(CPTutorialAction)actions{
    CPTutorial *before = current;
    current = self;
    actions();
    current = before;
    return self;
}

-(instancetype)step{
    _currentBalloon = self.currentBalloon.nextBalloon;
    [self checkCompletion];
    [self resume];
    return self;
}

-(instancetype)cancel{
    [self.currentBalloon dismiss];
    _currentBalloon = nil;
    [self checkCompletion];
    return self;
}

+(CPTutorial*)tutorialNamed:(NSString*)tutorialName{
    CPTutorial *tut = tutorials[tutorialName];
    if(!tut){
        tut = [[CPTutorial alloc] initWithName:tutorialName];
        tutorials[tutorialName] = tut;
    }
    return tut;
}

+(CPTutorial*)currentTutorial{
    return current;
}

-(instancetype)initWithName:(NSString*)tutorialName{
    self = [super init];
    _name = tutorialName;
    return self;
}

-(instancetype)init{
    NSAssert(NO, @"Use [CPTutorial initWithName:] to initialize CPTutorial.");
    return nil;
}

+(void)initialize{
    [super initialize];
    tutorialsDisplayedThisSession = [NSMutableArray array];
    tutorials = [NSMutableDictionary dictionary];
}

-(BOOL)shouldDisplay{
    return [CPTutorial shouldDisplayTutorialWithName:self.name];
}

+(CPTutorial*)displayWithName:(NSString*)tutorialName actions:(CPTutorialAction)actions completion:(CPTutorialCompletion)completion{
    if(![CPTutorial shouldDisplayTutorialWithName:tutorialName]){
        if(completion){
            completion(NO);
        }
        return nil;
    }else{
        [[CPTutorial beginStepsWithTutorialName:tutorialName] completeWith:^{
            if(completion){
                completion(YES);
            }
        }];
        actions();
        return [CPTutorial endSteps];
    }
}

+(UIView*)placeholderAt:(CGRect)frame{
    CPTutorialInvisibleProxyView *proxy = [[CPTutorialInvisibleProxyView alloc] initWithFrame:frame];
    return proxy;
}

+(CPTutorial*)displayWithName:(NSString*)tutorialName actions:(CPTutorialAction)actions{
    return [self displayWithName:tutorialName actions:actions completion:nil];
}

-(instancetype)completeWith:(CPTutorialAction)completion{
    if(!completion){
        completion = CPTUTORIAL_NOOP;
    }
    completionHandler = completion;
    return self;
}

+(instancetype)pause:(NSString*)tutorialName{
    return [[CPTutorial tutorialNamed:tutorialName] pause];
}

+(instancetype)resume:(NSString*)tutorialName{
    return [[CPTutorial tutorialNamed:tutorialName] resume];
}

+(instancetype)cancel:(NSString*)tutorialName{
    return [[CPTutorial tutorialNamed:tutorialName] cancel];
}

+(CPTutorial*)beginStepsWithTutorialName:(NSString*)tutorialName{
    NSAssert(tutorialName.length, @"Tutorial must have a valid name!");
    CPTutorial *tut = [CPTutorial tutorialNamed:tutorialName];
    [tutorialsDisplayedThisSession addObject:tutorialName];
    current = tut;
    return tut;
}

-(void)addBalloon:(CPTutorialBalloon*)balloon{
    if(!_firstBalloon){
        _firstBalloon = balloon;
    }
    if(!_currentBalloon){
        _currentBalloon = balloon;
    }
    lastAddedBalloon.nextBalloon = balloon;
    lastAddedBalloon = balloon;
}

+(CPTutorial*)endSteps{
    CPTutorial *tut = current;
    current = nil;
    CPTutorialBalloon *firstBalloon = tut.firstBalloon;
    [firstBalloon signal];
    return tut;
}

+(BOOL)shouldDisplayTutorialWithName:(NSString*)name{
    if(!name){
        return YES;
    }
    if([tutorialsDisplayedThisSession containsObject:name]){
        return NO;
    }
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *targetKey = CPTUTORIAL_KEY(name);
    id val = [settings valueForKey:targetKey];
    if([val isEqualToString:@"done"]){
        return NO;
    }else{
        return YES;
    }
}

-(instancetype)resumeIfOn:(id)target{
    if(self.currentBalloon.targetView == target){
        [self.currentBalloon dismiss];
    }
    return self;
}

-(instancetype)refresh{
    CGRect rect = [self.currentBalloon.targetView.superview convertRect:self.currentBalloon.targetView.frame toView:nil];
    [self.currentBalloon attachedViewFrameDidChange:rect];
    return self;
}

+(void)markTutorialAsCompleted:(NSString*)tipName{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *targetKey = CPTUTORIAL_KEY(tipName);
    [settings setValue:@"done" forKey:targetKey];
    [settings synchronize];
}


@end
