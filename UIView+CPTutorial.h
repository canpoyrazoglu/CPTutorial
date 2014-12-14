//
//  UIView+CPTutorial.h
//
//  Created by Can Poyrazoğlu on 23.11.14.
//

#import <UIKit/UIKit.h>
#import "CPTutorial.h"

@class CPTutorialBalloon;

@interface UIView (CPTutorial)

/**
 Displays a balloon tip inside a tutorial block. To display a single balloon tip without a tutorial block, use @c displayBalloonTop:onceWithIdentifier:
 @code
 [CPTutorial displayWithName:@"my unique tutorial name" actions:^{
     [myButton displayBalloonTip:@"Tap here to continue..."];
 }];
 @endcode
 @warning This method sets the calling view's @c autoresizesSubviews property to YES in order to observe frame changes to the view.
 */
-(CPTutorialBalloon*)displayBalloonTip:(NSString*)text;
-(CPTutorialBalloon*)displayBalloonTip:(NSString*)text onceWithIdentifier:(NSString*)tipName;

@end
