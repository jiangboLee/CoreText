//
//  LEEBaseDataItem.m
//  CoreText
//
//  Created by LEE on 2019/3/31.
//  Copyright © 2019年 Lee. All rights reserved.
//

#import "LEEBaseDataItem.h"

@implementation LEEBaseDataItem

- (NSMutableArray<NSValue *> *)clickableFrames {
    if (!_clickableFrames) {
        _clickableFrames = [NSMutableArray arrayWithCapacity:2];
    }
    return _clickableFrames;
}

- (void)addFrame:(CGRect)frame {
    [self.clickableFrames addObject:[NSValue valueWithCGRect:frame]];
}

- (BOOL)containsPoint:(CGPoint)point {
    for (NSValue *frameValue in self.clickableFrames) {
        if (CGRectContainsPoint(frameValue.CGRectValue, point)) {
            return YES;
        }
    }
    return false;
}

@end
