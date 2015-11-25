//
//  ViewController.m
//  TestPickerView
//
//  Created by PhilipLee on 15/11/23.
//  Copyright © 2015年 PhilipLee. All rights reserved.
//

#import "ViewController.h"
#import "PLPickerView.h"

@interface ViewController ()<PLPickerViewProtocol>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showPickerView:(UIButton *)sender
{
    PLPickerView *picker = [[PLPickerView alloc] initWithDelegate:self type:PLPickerViewTypeSingleColumn style:PLPickerViewStyleBlackOpaque];
    
    picker.firstColumnDatas = @[@"一", @"二", @"三", @"四", @"五", @"六", @"七"];
    picker.firstSelectedText = @"三";
    
    [picker showInView:self.view];
}

- (IBAction)showTwoPicker:(UIButton *)sender
{
    PLPickerView *picker = [[PLPickerView alloc] initWithDelegate:self type:PLPickerViewTypeTwoColumn style:PLPickerViewStyleDefault];
    
    picker.firstColumnDatas = @[@"一", @"二", @"三"];
    picker.firstSelectedText = @"二";
    
    picker.secondColumnDatas = @{@"一":@[@"1",@"2",@"3",@"4",@"5",@"6"], @"二":@[@"11",@"12",@"13",@"14",@"15"], @"三":@[@"21",@"22",@"23"]};
    
    [picker showInView:self.view];
}

- (IBAction)showDatePicker:(UIButton *)sender
{
    PLPickerView *picker = [[PLPickerView alloc] initWithDelegate:self type:PLPickerViewTypeDate style:PLPickerViewStyleBlackTranslucent];
    [picker showInView:self.view];
}

- (IBAction)showDateAndTimePicker:(UIButton *)sender
{
    PLPickerView *picker = [[PLPickerView alloc] initWithDelegate:self type:PLPickerViewTypeDateAndTime style:PLPickerViewStyleDefault];
    picker.allowSelectFutureDate = NO;
    
    [picker showInView:self.view];
}
@end
