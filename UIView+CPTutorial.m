//
//  UIView+CPTutorial.m
//
//  Created by Can Poyrazoğlu on 23.11.14.
//

#import "UIView+CPTutorial.h"
#import "CPTutorial.h"
#import "CPTutorialInvisibleProxyView.h"

@implementation UIView (CPTutorial)

-(CPTutorialBalloon*)displayBalloonTip:(NSString*)text{
    if(![CPTutorial isRecordingValidTutorial]){
        return nil;
    }
    CPTutorialBalloon *balloon = [[CPTutorialBalloon alloc] initWithFrame:self.frame];
    balloon.isManagedExternally = YES;
    balloon.shouldResizeItselfAccordingToContents = YES;
    balloon.text = text;

    float midpointY = self.frame.origin.y + self.frame.size.height / 2;
    BOOL below = YES;
    if(midpointY > self.superview.frame.size.height / 2){
        below = NO;
    }
    balloon.manualTipPosition = YES;
    balloon.targetView = self;
    balloon.tipAboveBalloon = below;

    UIView *superviewToAddBalloon = [[[UIApplication sharedApplication] delegate] window];
    [superviewToAddBalloon addSubview:balloon];
    //now, a hacky way to "observe" frame changes:
    self.autoresizesSubviews = YES;
    CPTutorialInvisibleProxyView *proxyView = [CPTutorialInvisibleProxyView proxyView];
    proxyView.delegate = balloon;
    [self addSubview:proxyView];
    return balloon;
}

-(CPTutorialBalloon*)displayBalloonTip:(NSString*)text onceWithIdentifier:(NSString*)tipName{
    if([CPTutorial shouldDisplayTutorialWithName:tipName]){
        CPTutorialBalloon *balloon = [self displayBalloonTip:text];
        balloon.tipName = tipName;
        return balloon;
    }else{
        return nil;
    }
}

@end
