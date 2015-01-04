//
//  CPTutorialDisplayable.h
//
//  Created by Can Poyrazoğlu on 29.12.14.
//

#import <UIKit/UIKit.h>
#import "CPTutorial.h"

@interface CPTutorialDisplayable : UIView<CPTutorialDisplayability>

-(instancetype)display;

@end
