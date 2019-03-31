//
//  LEEBaseDataItem.h
//  CoreText
//
//  Created by LEE on 2019/3/31.
//  Copyright © 2019年 Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^ClickActionHandler)(id obj);
@interface LEEBaseDataItem : NSObject

@property (nonatomic, strong) NSMutableArray<NSValue *> *clickableFrames;
@property (nonatomic, copy) ClickActionHandler clickActionHandler;

- (void)addFrame:(CGRect)frame;
- (BOOL)containsPoint:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END
