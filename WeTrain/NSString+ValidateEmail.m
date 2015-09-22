//
//  NSString+ValidateEmail.m
//  GymPact
//
//  Created by Bobby Ren on 6/14/13.
//  Copyright (c) 2013 Harvard University. All rights reserved.
//

#import "NSString+ValidateEmail.h"

@implementation NSString (ValidateEmail)
-(BOOL) isValidEmail
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

@end
