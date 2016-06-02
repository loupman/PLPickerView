//
//  ViewController.m
//  PLPickerView
//
//  Created by PhilipLee on 16/5/31.
//  Copyright © 2016年 PhilipLee. All rights reserved.
//

#import "ViewController.h"
#import "PLPickerView.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, PLPickerViewDelegate>

@property(strong, nonatomic) NSArray *keyTitles;
@property(strong, nonatomic) NSMutableArray *keyValues;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _keyTitles = @[@"显示年月日时分", @"显示年月日", @"显示年月", @"显示单列", @"显示两列"];
    _keyValues = [@[@"", @"", @"", @"", @""] mutableCopy];
}

#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _keyTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    
    static NSString *identifier = @"UITableViewCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    cell.textLabel.text = _keyTitles[section];
    cell.detailTextLabel.text = _keyValues[section];
    
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 12.1f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger section = indexPath.section;
    switch (section) {
        case 0: {
            PLPickerView *pickerView = [[PLPickerView alloc] initWithDelegate:self type:PLPickerViewTypeDateAndTime];
            
            NSString *dateStr = _keyValues[0];
            NSDate *date = [NSDate date];
            if (dateStr.length > 0) {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"yyyy-MM-dd HH:mm";
                date = [formatter dateFromString:dateStr];
            }
            
            pickerView.selectedDate = date;
            pickerView.pickerViewStyle = PLPickerViewStyleBlackOpaque;
            pickerView.tag = 100+section;
            [pickerView showInView:self.view];
        }
            break;
        case 1: {
            PLPickerView *pickerView = [[PLPickerView alloc] initWithDelegate:self type:PLPickerViewTypeDate];
            
            NSString *dateStr = _keyValues[1];
            NSDate *date = [NSDate date];
            if (dateStr.length > 0) {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"yyyy-MM-dd";
                date = [formatter dateFromString:dateStr];
            }
            
            pickerView.selectedDate = date;
            pickerView.pickerViewStyle = PLPickerViewStyleDefault;
            pickerView.tag = 100+section;
            [pickerView showInView:self.view];
        }
            break;
        case 2: {
            PLPickerView *pickerView = [[PLPickerView alloc] initWithDelegate:self type:PLPickerViewTypeYearAndMonth];
            
            NSString *dateStr = _keyValues[2];
            NSDate *date = [NSDate date];
            if (dateStr.length > 0) {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"yyyy-MM";
                date = [formatter dateFromString:dateStr];
            }
            
            pickerView.selectedDate = date;
            pickerView.pickerViewStyle = PLPickerViewStyleBlackTranslucent;
            pickerView.tag = 100+section;
            [pickerView showInView:self.view];
        }
            break;
            
        case 3: {
            PLPickerView *pickerView = [[PLPickerView alloc] initWithDelegate:self type:PLPickerViewTypeSingleColumn];
            pickerView.pickerViewStyle = PLPickerViewStyleBlackTranslucent;
            NSMutableArray *data = [NSMutableArray array];
            NSArray *dd = @[@"其它", @"文印店/广告公司", @"互联网/软件", @"金融/保险", @"餐饮", @"美容/保健", @"酒店/旅游",
                            @"建筑/建材/工程", @"家居/室内设计/装潢", @"房产中介", @"教育/培训", @"广告/媒体", @"贸易/进出口",
                            @"计算机硬件及网络设备", @"计算机软件", @"IT服务（系统/数据/维护）/多领域经营", @"网络游戏"];
            for (NSString *obj in dd) {
                
                PLPickerObject *object = [PLPickerObject objectWithKey:obj extraData:nil];
                [data addObject:object];
            }
            NSString *str = _keyValues[3];
            NSInteger index = 0;
            if (str.length > 0) {
                index = [dd indexOfObject:str];
                if (index >= dd.count) {
                    index = 0;
                }
            }
            
            pickerView.dataObjects = data;
            pickerView.firstSelectedColIndex = index;
            pickerView.tag = 100+section;
            [pickerView showInView:self.view];
        }
            break;
            
        case 4: {
            PLPickerView *pickerView = [[PLPickerView alloc] initWithDelegate:self type:PLPickerViewTypeTwoColumn];
            pickerView.pickerViewStyle = PLPickerViewStyleBlackTranslucent;
            
            NSMutableArray *data = [NSMutableArray array];
            NSArray *dd = @[@"文印店/广告公司", @"互联网/软件", @"金融/保险", @"餐饮"];
            
            NSArray *dd2 = @[@[@"文印店司", @"互联件"],
                             @[@"金融/保险", @"餐饮"],
                             @[@"计算机硬件设备", @"计算机软件"],
                             @[@"计算机", @"计算"]];
            NSString *str = _keyValues[4];
            NSInteger firstIndex = 0;
            NSInteger secondIndex = 0;
            if (str.length > 0) {
                NSArray *coms = [str componentsSeparatedByString:@"^"];
                if (coms.count == 2) {
                    firstIndex = [dd indexOfObject:coms[0]];
                    firstIndex = firstIndex>=dd.count?0:firstIndex;
                    
                    secondIndex = [dd2[firstIndex] indexOfObject:coms[1]];
                    secondIndex = secondIndex>=[dd2[firstIndex] count]?0:secondIndex;
                }
            }
            
            for (int i = 0; i < dd.count; i++) {
                
                PLPickerObject *object = [PLPickerObject objectWithKey:dd[i] extraData:nil];
                
                NSArray *d = dd2[i];
                NSMutableArray *arr = [NSMutableArray array];
                for (NSString *obj2 in d) {
                    PLPickerObject *o1 = [PLPickerObject objectWithKey:obj2 extraData:nil];
                    [arr addObject:o1];
                }
                object.subObjects = arr;
                [data addObject:object];
            }
            pickerView.dataObjects = data;
            pickerView.firstSelectedColIndex = firstIndex;
            pickerView.secondSelectedColIndex = secondIndex;
            
            pickerView.tag = 100+section;
            [pickerView showInView:self.view];
        }
            break;
            
        default:
            break;
    }
}

-(void) plPickerView:(PLPickerView *)pickerView didDismissWithTouchIndex:(NSInteger)index
{
    if (index == 1) {
        
        switch (pickerView.tag) {
            case 100: {
                NSDateFormatter *format = [[NSDateFormatter alloc] init];
                format.dateFormat = @"yyyy-MM-dd HH:mm";
                
                [_keyValues setObject:[format stringFromDate:pickerView.selectedDate] atIndexedSubscript:0];
                
                [self.tableView reloadData];
            }
                break;
            case 101: {
                NSDateFormatter *format = [[NSDateFormatter alloc] init];
                format.dateFormat = @"yyyy-MM-dd";
                
                [_keyValues setObject:[format stringFromDate:pickerView.selectedDate] atIndexedSubscript:1];
                
                [self.tableView reloadData];
            }
                break;
            case 102: {
                NSDateFormatter *format = [[NSDateFormatter alloc] init];
                format.dateFormat = @"yyyy-MM";
                
                [_keyValues setObject:[format stringFromDate:pickerView.selectedDate] atIndexedSubscript:2];
                
                [self.tableView reloadData];
            }
                break;
                
            case 103: {
                
                PLPickerObject *obj = pickerView.dataObjects[pickerView.firstSelectedColIndex];
                [_keyValues setObject:obj.key atIndexedSubscript:3];
                
                [self.tableView reloadData];
            }
                break;
                
            case 104: {
                
                PLPickerObject *obj = pickerView.dataObjects[pickerView.firstSelectedColIndex];
                PLPickerObject *obj2 = obj.subObjects[pickerView.secondSelectedColIndex];
                [_keyValues setObject:[NSString stringWithFormat:@"%@^%@", obj.key, obj2.key] atIndexedSubscript:4];
                
                [self.tableView reloadData];
            }
                break;
                
            default:
                break;
        }
        
    } else if (index == 0) {
        
    }
}
@end
