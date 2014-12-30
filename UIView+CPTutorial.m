//
//  UIView+CPTutorial.m
//
//  Created by Can Poyrazoğlu on 23.11.14.
//

#import "CPTutorial.h"
#import "UIView+CPTutorial.h"
#import "CPTutorialInvisibleProxyView.h"
#import "CPTutorialTargetTouchIndicatorView.h"

@implementation UIView (CPTutorial)

-(CPTutorialBalloon*)displayBalloonTip:(NSString*)text afterPerforming:(CPTutorialAction)actionToExecuteBefore{
    if([self isKindOfClass:[CPTutorialInvisibleProxyView class]]  ||
       [self isKindOfClass:[CPTutorialTargetTouchIndicatorView class]]){
        if(!self.superview){
            [[[[UIApplication sharedApplication] delegate] window] addSubview:self];
        }
    }
    CPTutorialBalloon *balloon = [[CPTutorialBalloon alloc] initWithFrame:self.frame];
    balloon.isManagedExternally = YES;
    balloon.shouldResizeItselfAccordingToContents = YES;
    balloon.text = text;
    balloon.tutorial = [CPTutorial currentTutorial];
    balloon.targetView = self;
    balloon.blockToExecuteBeforeDisplaying = actionToExecuteBefore;
    
    UIView *superviewToAddBalloon = [[[UIApplication sharedApplication] delegate] window];
    [superviewToAddBalloon addSubview:balloon];
    //now, a hacky way to "observe" frame changes:
    self.autoresizesSubviews = YES;
    CPTutorialInvisibleProxyView *proxyView = [CPTutorialInvisibleProxyView proxyView];
    proxyView.delegate = balloon;
    [self addSubview:proxyView];
    return balloon;
}

-(CPTutorialBalloon*)displayBalloonTip:(NSString*)text{
    return [self displayBalloonTip:text afterPerforming:nil];
}

-(CPTutorial*)displayBalloonTip:(NSString*)text onceWithIdentifier:(NSString*)tipName{
    return [CPTutorial displayWithName:tipName actions:^{
        [self displayBalloonTip:text];
    }];
}

-(CPTutorial*)displayBalloonTip:(NSString*)text onceWithIdentifier:(NSString*)tipName afterPerforming:(CPTutorialAction)actionToExecuteBefore{
    return [CPTutorial displayWithName:tipName actions:^{
        [self displayBalloonTip:text afterPerforming:actionToExecuteBefore];
    }];
}

@end
