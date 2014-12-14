//
//  CPTutorialInvisibleProxyView.h
//
//  Created by Can Poyrazoğlu on 29.11.14.
//

//Do NOT instantiate or use this class directly. This is just an internal implementation.

#import <UIKit/UIKit.h>
#import "CPTutorial.h"

@interface CPTutorialInvisibleProxyView : UIView

+(instancetype)proxyView;

@property id<CPTutorialView> delegate;

@end
