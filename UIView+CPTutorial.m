//
//  UIView+CPTutorial.m
//
//  Created by Can Poyrazoğlu on 23.11.14.
//

#import "UIView+CPTutorial.h"
#import "CPTutorial.h"

@implementation UIView (CPTutorial)

-(CPTutorialBalloon*)displayBalloonTip:(NSString*)text{
    CPTutorialBalloon *balloon = [[CPTutorialBalloon alloc] initWithFrame:CGRectZero]; //we'll set up autolayout
    balloon.translatesAutoresizingMaskIntoConstraints = NO;
    balloon.text = text;
    [self.superview addSubview:balloon];
    //check if self frame is above or below the superview's midpoint.
    float midpointY = self.frame.origin.y + self.frame.size.height / 2;
    BOOL below = YES;
    if(midpointY > self.superview.frame.size.height / 2){
        below = NO;
    }
    balloon.manualTipPosition = YES;
    balloon.tipAboveBalloon = below;
    //set up layout constraints
    //|-[balloon]
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:balloon attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeLeading multiplier:1 constant:20];
    //[balloon]-|
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:balloon attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeTrailing multiplier:1 constant:-20];
    //V:[balloon]-[self] or V:[self]-[balloon] depending on self's location
    NSLayoutConstraint *attachmentConstraint = [NSLayoutConstraint constraintWithItem:balloon attribute:(below ? NSLayoutAttributeTop : NSLayoutAttributeBottom) relatedBy:NSLayoutRelationEqual toItem:self attribute:(below ? NSLayoutAttributeBottom : NSLayoutAttributeTop) multiplier:1 constant:-10];
    [self.superview addConstraints:@[leftConstraint, rightConstraint]];
    [self.superview addConstraint:attachmentConstraint];
    return balloon;
}

-(CPTutorialBalloon*)displayBalloonTip:(NSString*)text onceWithIdentifier:(NSString*)tipName{
    if([CPTutorial shouldDisplayTipWithName:tipName]){
        CPTutorialBalloon *balloon = [self displayBalloonTip:text];
        balloon.tipName = tipName;
        return balloon;
    }else{
        return nil;
    }
}

@end
