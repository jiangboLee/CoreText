//
//  ViewController.m
//  CoreText
//
//  Created by Lee on 2019/3/29.
//  Copyright © 2019 Lee. All rights reserved.
//

#import "ViewController.h"
#import "CoreTextSimple.h"
#import <Masonry.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    
    NSMutableAttributedString * truncationToken = [[NSMutableAttributedString alloc] initWithString:@"..." attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16 weight:UIFontWeightRegular]}];
    NSString *text = @"这是一个最好的时代这是一个最这是一个最好的时代这是一个最这是一个最好的时代这是一个最这是一个最好的时代这是一个最这是一个最好的时代这是一个最这是一个最好的时代这是一个最这是一个最好的时代这是一个最这是一个最好的时代这是一个最这是一个最好的时代这是一个最";
    
    // 段落设置与实际显示的 Label 属性一致 采用 NSMutableParagraphStyle 设置Nib 中 Label 的相关属性传入到 NSAttributeString 中计算；
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineSpacing = 3;
    style.alignment = NSTextAlignmentLeft;
    
    NSAttributedString *string = [[NSAttributedString alloc]initWithString:text attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16 weight:UIFontWeightRegular], NSParagraphStyleAttributeName:style}];
    
    CGSize size =  [string boundingRectWithSize:CGSizeMake(self.view.bounds.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    NSLog(@" size =  %@", NSStringFromCGSize(size));
    CGFloat height = roundf(size.height);
    
    CoreTextSimple *coreTextSimple = [[CoreTextSimple alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, height > 44 ? 44 : height)];
    coreTextSimple.backgroundColor = [UIColor whiteColor];
    coreTextSimple.numberOfLines = 2;
    coreTextSimple.textAlignment = NSTextAlignmentLeft;
    coreTextSimple.lineSpacing = 5.5;
    coreTextSimple.truncationToken = truncationToken;
    [coreTextSimple addString:text attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16 weight:UIFontWeightRegular], NSParagraphStyleAttributeName:style} clickActionHandler:^(id obj) {
    }];
    __weak typeof(coreTextSimple) weakDrawView = coreTextSimple;
    coreTextSimple.truncationActionHandler = ^(id obj) {
        NSLog(@"点击查看更多");
        weakDrawView.frame = CGRectMake(0, 100, self.view.bounds.size.width, height);
        weakDrawView.numberOfLines = 0;
        
    };
    [self.view addSubview:coreTextSimple];
    
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor whiteColor];
    label.attributedText = string;
    label.numberOfLines = 0;
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.width.offset(self.view.bounds.size.width);
        make.top.equalTo(self.view).offset(400);
    }];
    
}


@end
