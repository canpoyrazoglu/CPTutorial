//
//  CPTutorialShadowView.h
//
//  Created by Can Poyrazoğlu on 19.12.14.
//

#import <UIKit/UIKit.h>
#import "CPTutorialBalloon.h"

@interface CPTutorialShadowView : UIView

@property(nonatomic) CPTutorialBalloon *parentBalloon;
@property(nonatomic) CGPathRef shadowPath;

+(instancetype)shadowViewFor:(CPTutorialBalloon*)balloon;

@end
