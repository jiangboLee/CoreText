//
//  LEECTLine.h
//  CoreText
//
//  Created by LEE on 2019/3/31.
//  Copyright © 2019年 Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

NS_ASSUME_NONNULL_BEGIN

@interface LEECTLine : NSObject

@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign) CTLineRef ctLine;

@end

NS_ASSUME_NONNULL_END
