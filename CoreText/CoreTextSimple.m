//
//  CoreTextSimple.m
//  CoreText
//
//  Created by Lee on 2019/3/29.
//  Copyright © 2019 Lee. All rights reserved.
//

#import "CoreTextSimple.h"
#import <CoreText/CoreText.h>

@implementation CoreTextSimple

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1, -1);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18], NSForegroundColorAttributeName: [UIColor blueColor]};
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"d等你放假还分开发的发货快发货 爱的客户分类和覅问候日供货方达到覅恩菲复合返回电话放开了花覅偶诶诶hi噢if口味发呢克日日日我日日的目的的目的" attributes:attributes];
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrStr);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attrStr.length), path, NULL);
    
    CTFrameDraw(frame, context);
}

@end
