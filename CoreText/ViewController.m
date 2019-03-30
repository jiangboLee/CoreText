//
//  ViewController.m
//  CoreText
//
//  Created by Lee on 2019/3/29.
//  Copyright © 2019 Lee. All rights reserved.
//

#import "ViewController.h"
#import "CoreTextSimple.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CoreTextSimple *coreTextSimple = [[CoreTextSimple alloc] initWithFrame:CGRectMake(20, 200, 300, 500)];
    coreTextSimple.backgroundColor = [UIColor grayColor];
    [self.view addSubview:coreTextSimple];
    
}


@end
