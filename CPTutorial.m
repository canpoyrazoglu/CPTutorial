//
//  CPTutorial.m
//
//  Created by Can Poyrazoğlu on 27.10.14.
//

#import "CPTutorial.h"

#define TIP_NAME_FORMAT (@"_CPTutorialTip_%@")
#define TIP_KEY(x) ([NSString stringWithFormat:TIP_NAME_FORMAT, x])

@implementation CPTutorial

+(BOOL)shouldDisplayTipWithName:(NSString*)tipName{
    if(!tipName){
        return YES;
    }
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *targetKey = TIP_KEY(tipName);
    id val = [settings valueForKey:targetKey];
    if([val isEqualToString:@"done"]){
        return NO;
    }else{
        return YES;
    }
}

+(void)markTipCompletedWithTipName:(NSString*)tipName{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *targetKey = TIP_KEY(tipName);
    [settings setValue:@"done" forKey:targetKey];
    [settings synchronize];
}

+(UILabel*)label{
    return [[UILabel alloc] initWithFrame:CGRectZero];
}

@end
