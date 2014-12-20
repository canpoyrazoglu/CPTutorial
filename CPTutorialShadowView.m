//
//  CPTutorialShadowView.m
//  QuickUp
//
//  Created by Can Poyrazoğlu on 19.12.14.
//  Copyright (c) 2014 QuickUp, B.V. All rights reserved.
//

#import "CPTutorialShadowView.h"

@implementation CPTutorialShadowView

+(instancetype)shadowViewFor:(CPTutorialBalloon*)balloon{
    CPTutorialShadowView *view = [[CPTutorialShadowView alloc] initWithFrame:balloon.frame];
    return view;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    self.layer.masksToBounds = NO;
    self.userInteractionEnabled = NO;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    return self;
}

-(void)reset{
    self.layer.shadowColor = self.parentBalloon.shadowColor.CGColor;
    self.layer.shadowOpacity = 1;
    self.layer.shadowOffset = CGSizeZero;
    if(self.shadowPath){
        self.layer.shadowPath = self.shadowPath;
    }
    self.layer.shadowRadius = self.parentBalloon.shadowBlurRadius;
    self.frame = self.parentBalloon.frame;
    [self.layer setNeedsDisplay];
}

-(void)setShadowPath:(CGPathRef)shadowPath{
    _shadowPath = shadowPath;
    [self reset];
}

-(void)setParentBalloon:(CPTutorialBalloon *)parentBalloon{
    _parentBalloon = parentBalloon;
    [self reset];
}


@end
