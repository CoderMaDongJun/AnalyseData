//
//  MDJHomeViewController.m
//  AnalyseDemo
//
//  Created by 马栋军 on 2018/8/1.
//  Copyright © 2018年 DangDangWang. All rights reserved.
//

#import "MDJHomeViewController.h"
#import "MDJDetailViewController.h"
#import "MDJUserStatistics.h"

@interface MDJHomeViewController ()

@property (strong, nonatomic) IBOutlet UIButton *favBtn;
@property (strong, nonatomic) IBOutlet UIButton *shareBtn;

@end

@implementation MDJHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"MDJHomeViewController";
}

- (IBAction)onFavBtnPressed:(id)sender
{
    
}

- (IBAction)onShareBtnPressed:(id)sender
{
    
}

- (IBAction)onNextItemPressed:(id)sender
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MDJDetailViewController *secondVC = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([MDJDetailViewController class])];
    [self.navigationController pushViewController:secondVC animated:YES];
}

@end
