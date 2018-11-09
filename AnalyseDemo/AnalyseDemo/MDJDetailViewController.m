//
//  MDJDetailViewController.m
//  AnalyseDemo
//
//  Created by 马栋军 on 2018/8/1.
//  Copyright © 2018年 DangDangWang. All rights reserved.
//

#import "MDJDetailViewController.h"

@interface MDJDetailViewController ()
@property (strong, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@end

@implementation MDJDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(detailGesture:)];
    [self.imgView addGestureRecognizer:tgr];
    self.imgView.userInteractionEnabled = YES;
}

- (void)detailGesture:(id)tgr
{
    NSLog(@"tgr:%@",tgr);
    
}

- (IBAction)onShareBtnPressed:(id)sender
{
    
}

@end
