//
//  LEEAttachmentItem.m
//  CoreText
//
//  Created by LEE on 2019/3/31.
//  Copyright © 2019年 Lee. All rights reserved.
//

#import "LEEAttachmentItem.h"

@implementation LEEAttachmentItem

- (UIImage *)image {
    if ([_attachment isKindOfClass:[UIImage class]]) {
        return _attachment;
    }
    return nil;
}

@end
