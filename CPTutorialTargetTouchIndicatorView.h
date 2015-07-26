//
//  CPTutorialTargetTouchIndicatorView.h
//
//  Created by Can Poyrazoğlu on 20.12.14.
//

#import <UIKit/UIKit.h>
#import "CPTutorialDisplayable.h"

@interface CPTutorialTargetTouchIndicatorView : CPTutorialDisplayable

-(void)beginAnimating;
-(void)beginAnimatingAfterDelay:(float)delay extraVisible:(BOOL)extraVisible;
-(void)endAnimating;
-(instancetype)display;

@property BOOL isAnimating;

@end
