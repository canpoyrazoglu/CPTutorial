//
//  CPTutorialShadowView.h
//  QuickUp
//
//  Created by Can Poyrazoğlu on 19.12.14.
//  Copyright (c) 2014 QuickUp, B.V. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPTutorialShadowView : UIView

@property(nonatomic) CPTutorialBalloon *parentBalloon;
@property(nonatomic) CGPathRef shadowPath;

+(instancetype)shadowViewFor:(CPTutorialBalloon*)balloon;

@end
