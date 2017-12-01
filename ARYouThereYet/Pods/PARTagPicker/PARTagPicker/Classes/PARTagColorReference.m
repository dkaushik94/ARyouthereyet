//
//  PARTagColorReference.m
//  PARTagPicker
//
//  Created by Paul Rolfe on 7/21/15.
//  Copyright (c) 2015 Paul Rolfe. All rights reserved.
//

#import "PARTagColorReference.h"

@implementation PARTagColorReference

- (instancetype)initWithDefaultColors {
    self = [super init];
    if (self) {
        self.chosenTagBorderColor = [UIColor colorWithRed:(84/255.0) green:250/255.0 blue:219/255.0 alpha:1];
        self.chosenTagBackgroundColor = [UIColor colorWithRed:(1/255.0) green:50/255.0 blue:67/255.0 alpha:1];
        self.chosenTagTextColor = [UIColor colorWithRed:(255/255.0) green:255/255.0 blue:255/255.0 alpha:1];
        
        self.defaultTagBorderColor = [UIColor colorWithRed:(1/255.0) green:50/255.0 blue:67/255.0 alpha:1];
        self.defaultTagBackgroundColor = [UIColor colorWithRed:(1/255.0) green:50/255.0 blue:67/255.0 alpha:1];
        self.defaultTagTextColor = [UIColor colorWithRed:(255.0/255.0) green:255.0/255.0 blue:255.0/255.0 alpha:1];
        
        self.highlightedTagBorderColor = [UIColor whiteColor];
        self.highlightedTagBackgroundColor = [UIColor whiteColor];
        self.highlightedTagTextColor = [UIColor blackColor];
    }
    return self;
}

@end
