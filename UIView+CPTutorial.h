//
//  UIView+CPTutorial.h
//
//  Created by Can Poyrazoğlu on 23.11.14.
//

#import <UIKit/UIKit.h>
#import "CPTutorialBalloon.h"

@interface UIView (CPTutorial)

-(CPTutorialBalloon*)displayBalloonTip:(NSString*)text;
-(CPTutorialBalloon*)displayBalloonTip:(NSString*)text onceWithIdentifier:(NSString*)tipName;

@end
