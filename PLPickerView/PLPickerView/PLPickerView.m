//
//  PLPickerView.m
//  TestPickerView
//
//  Created by PhilipLee on 15/11/24.
//  Copyright © 2015年 PhilipLee. All rights reserved.
//

#import "PLPickerView.h"

//屏幕宽高
#define kScreenWidth                 [UIScreen mainScreen].bounds.size.width
#define kScreenHeight                [UIScreen mainScreen].bounds.size.height
#define kColorRGBA(r,g,b,a)          [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define kBlueColor                   kColorRGBA(0, 160, 233, 1)
#define kIOS7                        ([[UIDevice currentDevice].systemVersion doubleValue]<8.0)

#define pickerHeight                 252
#define pickerWidth                  kScreenWidth

@implementation PLPickerObject

+(instancetype)objectWithKey:(NSString *)key extraData:(id)extraData
{
    PLPickerObject *object = [PLPickerObject new];
    object.key = key;
    object.extraData = extraData;
    object.subObjects = nil;
    
    return object;
}

-(NSString *)description
{
    return _key;
}

- (NSComparisonResult)compare:(PLPickerObject *)object
{
    return [object.key compare:_key];
}
@end

@interface PLPickerView()<UIPickerViewDelegate, UIPickerViewDataSource>

@property(nonatomic, strong) UIDatePicker *datePicker;
@property(nonatomic, strong) UIPickerView *normalPicker;
@property(strong, nonatomic) NSArray *secondMonths;

@property(nonatomic, strong) UIControl *coverLayer;
@property(nonatomic, weak) id<PLPickerViewDelegate> delegate;

@end

@implementation PLPickerView

-(instancetype) initWithDelegate:(id<PLPickerViewDelegate>)delegate type:(PLPickerViewType) pickerViewType
{
    CGRect frame = CGRectMake(0, kScreenHeight, pickerWidth, pickerHeight);
    if (self = [super initWithFrame:frame]) {
        _pickerViewStyle = PLPickerViewStyleDefault;
        _pickerViewType = pickerViewType?:PLPickerViewTypeDateAndTime;
        _delegate = delegate;
        
        _allowSelectFutureDate = YES;
        
        [self setupViews];
    }
    
    return self;
}

-(void) setupViews
{
    CGFloat buttonWidth = 80;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pickerWidth, 40)];
    
    view.backgroundColor = kColorRGBA(248, 248, 248, 1.0);
    
    self.backgroundColor = kColorRGBA(248, 248, 248, 1.0);
    self.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(-1, -1);
    self.layer.shadowOpacity = 1.0f;
    self.layer.borderColor = kColorRGBA(248, 248, 248, 1.0).CGColor;
    self.layer.borderWidth = 0.1;
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, 40)];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [cancelButton setTitleColor:kColorRGBA(0, 160, 233, 1) forState:UIControlStateNormal];
    UIButton *okButton = [[UIButton alloc] initWithFrame:CGRectMake(pickerWidth - buttonWidth, 0, buttonWidth, 40)];
    [okButton setTitle:@"确定" forState:UIControlStateNormal];
    okButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [okButton setTitleColor:kColorRGBA(0, 160, 233, 1) forState:UIControlStateNormal];
    
    [cancelButton addTarget:self action:@selector(didTouchCancelButton) forControlEvents:UIControlEventTouchUpInside];
    [okButton addTarget:self action:@selector(didTouchOkButton) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:cancelButton];
    [view addSubview:okButton];
    
    CGRect pickRect = CGRectMake(0, 40, pickerWidth, pickerHeight - 40);
    switch (_pickerViewType) {
        case PLPickerViewTypeDate:
            _datePicker = [[UIDatePicker alloc] initWithFrame:pickRect];
            _datePicker.datePickerMode = UIDatePickerModeDate;
            
            break;
        case PLPickerViewTypeDateAndTime:
            _datePicker = [[UIDatePicker alloc] initWithFrame:pickRect];
            _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
            break;
        case PLPickerViewTypeTwoColumn:
        case PLPickerViewTypeSingleColumn:
        case PLPickerViewTypeYearAndMonth:
            
            _normalPicker = [[UIPickerView alloc] initWithFrame:pickRect];
            _normalPicker.dataSource = self;
            _normalPicker.delegate = self;
            
            break;
            
        default:
            break;
    }
    
    [self addSubview:view];
    if (_datePicker) {
        _datePicker.backgroundColor = [UIColor whiteColor];
        [self addSubview:_datePicker];
    } else if (_normalPicker) {
        _normalPicker.backgroundColor = [UIColor whiteColor];
        [self addSubview:_normalPicker];
    }
}

#pragma mark UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (_pickerViewType == PLPickerViewTypeTwoColumn ||
        _pickerViewType == PLPickerViewTypeYearAndMonth) {
        return 2;
    } else if (_pickerViewType == PLPickerViewTypeSingleColumn) {
        return 1;
    }
    return 0;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return _dataObjects.count;
            break;
        case 1: {
            if (_pickerViewType == PLPickerViewTypeYearAndMonth) {
                return 12;
            }
            
            if (_firstSelectedColIndex >= _dataObjects.count) {
                _firstSelectedColIndex = 0;
            }
            NSArray *arr = _dataObjects[_firstSelectedColIndex].subObjects;
            if (_secondSelectedColIndex >= [arr count]) {
                _secondSelectedColIndex = 0;
            }
            return [arr count];
        }
            break;
            
        default:
            break;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [_dataObjects[row] key];
            break;
        case 1: {
            if (_pickerViewType == PLPickerViewTypeYearAndMonth) {
                return [NSString stringWithFormat:@"%ld月", row+1];
            }
            
            NSArray *arr = _dataObjects[_firstSelectedColIndex].subObjects;
            if (_secondSelectedColIndex >= [arr count]) {
                _secondSelectedColIndex = 0;
            }
            return [arr[row] key];
        }
            break;
            
        default:
            break;
    }
    return @"";
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [UILabel new];
        pickerLabel.font = [UIFont systemFontOfSize:18];
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
    }
    // Fill the label text here
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component) {
        case 0: {
            if (_pickerViewType == PLPickerViewTypeYearAndMonth) {
                
                NSString *yearStr = [_dataObjects[row] key];
                NSInteger sYear = [[yearStr substringToIndex:yearStr.length - 1] integerValue];
                if (!_allowSelectFutureDate) {
                    NSDate *date = _selectedDate;
                    if (!date) {
                        date = [NSDate date];
                    }
                    NSInteger year = [[NSCalendar currentCalendar] component:NSCalendarUnitYear fromDate:date];
                    
                    if (sYear > year) {
                        
                        [pickerView selectRow:_firstSelectedColIndex>=_dataObjects.count?row:_firstSelectedColIndex
                                  inComponent:0 animated:YES];
                        [pickerView reloadAllComponents];
                        return;
                    }
                }
                _firstSelectedColIndex = row;
                return;
            }
            _firstSelectedColIndex = row;
            
            if (_pickerViewType == PLPickerViewTypeTwoColumn) {
                _secondSelectedColIndex = 0;
                
                [pickerView selectRow:0 inComponent:1 animated:YES];
                [pickerView reloadAllComponents];
            }
        }
            break;
        case 1: {
            if (_pickerViewType == PLPickerViewTypeYearAndMonth) {
                
                if (!_allowSelectFutureDate) {
                    NSDate *date = _selectedDate;
                    if (!date) {
                        date = [NSDate date];
                    }
                    NSInteger month = [[NSCalendar currentCalendar] component:NSCalendarUnitMonth fromDate:date];
                    
                    if ((row + 1) > month) {
                        [_normalPicker selectRow:month-1 inComponent:1 animated:YES];
                        [pickerView reloadAllComponents];
                        return;
                    }
                }
                _secondSelectedColIndex = row;
                return;
            }
            _secondSelectedColIndex = row;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark private method
-(void) didTouchOkButton
{
    if (_datePicker) {
        _selectedDate = _datePicker.date;
    } else if (_pickerViewType == PLPickerViewTypeYearAndMonth) {
        NSString *year = [_dataObjects[_firstSelectedColIndex] key];
        
        NSString *dd = [NSString stringWithFormat:@"%@-%ld-01",
                        [year substringToIndex:year.length-1], _secondSelectedColIndex+1];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        format.dateFormat = @"yyyy-MM-dd";
        
        _selectedDate = [format dateFromString:dd];
    }
    
    __weak __typeof(&*self)weakSelf = self;
    if (_plPickerViewDidDimissWithButtonIndex) {
        _plPickerViewDidDimissWithButtonIndex(weakSelf, 1);
    }
    
    if ([_delegate respondsToSelector:@selector(plPickerView:didDismissWithTouchIndex:)]) {
        [_delegate plPickerView:weakSelf didDismissWithTouchIndex:1];
    }
    
    [self dismiss];
}

-(void) didTouchCancelButton
{
    __weak __typeof(&*self)weakSelf = self;
    if (_plPickerViewDidDimissWithButtonIndex) {
        _plPickerViewDidDimissWithButtonIndex(weakSelf, 0);
    }
    
    if ([_delegate respondsToSelector:@selector(plPickerView:didDismissWithTouchIndex:)]) {
        [_delegate plPickerView:weakSelf didDismissWithTouchIndex:0];
    }
    
    [self dismiss];
}

-(void) showInView:(UIView *)view
{
    if (!_coverLayer) {
        _coverLayer = [[UIControl alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _coverLayer.backgroundColor = kColorRGBA(127, 127, 127, 0.7);
        [_coverLayer addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        
        [_coverLayer addSubview:self];
    }
    switch (_pickerViewStyle) {
        case PLPickerViewStyleDefault:
            _coverLayer.backgroundColor = kColorRGBA(127, 127, 127, 0.6);
            break;
        case PLPickerViewStyleBlackOpaque:
            _coverLayer.backgroundColor = kColorRGBA(127, 127, 127, 1);
            break;
        case PLPickerViewStyleBlackTranslucent:
            _coverLayer.backgroundColor = kColorRGBA(127, 127, 127, 0);
            break;
            
        default:
            break;
    }
    
    [view addSubview:_coverLayer];
    
    [self loadPresetValuesBeforShow];
    
    CGFloat viewHeight = CGRectGetHeight(view.bounds);
    self.frame = CGRectMake(0, viewHeight, pickerWidth, pickerHeight);
    _coverLayer.alpha = 0;
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.35 animations:^{
        weakSelf.coverLayer.alpha = 1;
    }];
    
    weakSelf.transform = CGAffineTransformIdentity;
    
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.transform = CGAffineTransformTranslate(weakSelf.transform, 0, - pickerHeight);
    }];
    
}
-(void) dismiss
{
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        
        weakSelf.transform = CGAffineTransformIdentity;
        weakSelf.coverLayer.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        weakSelf.coverLayer.alpha = 1;
        [weakSelf.coverLayer removeFromSuperview];
    }];
}

-(void) loadPresetValuesBeforShow
{
    if (_datePicker) {
        if (_selectedDate) {
            _datePicker.date = _selectedDate;
        } else {
            _datePicker.date = [NSDate date];
        }
        
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        _datePicker.locale = locale;
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        _datePicker.calendar = gregorian;
        
        if (!_allowSelectFutureDate) {
            NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
            //设置时间
            [offsetComponents setYear:-1];
            [offsetComponents setMonth:0];
            [offsetComponents setDay:0];
            [offsetComponents setHour:0];
            [offsetComponents setMinute:0];
            [offsetComponents setSecond:0];
            //设置最小时间
            NSDate *minDate = [gregorian dateByAddingComponents:offsetComponents toDate:_datePicker.date options:0];
            
            _datePicker.maximumDate = _datePicker.date;
            _datePicker.minimumDate = minDate;
        }
        
    } else if (_normalPicker) {
        if (_pickerViewType == PLPickerViewTypeSingleColumn || _pickerViewType == PLPickerViewTypeTwoColumn) {
            
            if (_firstSelectedColIndex >= _dataObjects.count) {
                _firstSelectedColIndex = 0;
            }
            [_normalPicker selectRow:_firstSelectedColIndex inComponent:0 animated:NO];
            
            if (_pickerViewType == PLPickerViewTypeTwoColumn) {
                NSArray *arra = [_dataObjects[_firstSelectedColIndex] subObjects];
                if (_secondSelectedColIndex >= arra.count) {
                    _secondSelectedColIndex = 0;
                }
                [_normalPicker selectRow:_secondSelectedColIndex inComponent:1 animated:NO];
            }
            [_normalPicker reloadAllComponents];
            
        } else if (_pickerViewType == PLPickerViewTypeYearAndMonth) {
            // year start from 1910
            NSMutableArray *array = [NSMutableArray array];
            for (int i = 1910; i < 1910 + 199; i++) {
                NSString *yearStr = [NSString stringWithFormat:@"%d年", i];
                PLPickerObject *obj = [PLPickerObject objectWithKey:yearStr extraData:nil];
                
                [array addObject:obj];
            }
            self.dataObjects = array;
            
            NSDate *date = _selectedDate;
            if (!date) {
                date = [NSDate date];
            }
            NSInteger selectedYear = [[NSCalendar currentCalendar] component:NSCalendarUnitYear fromDate:date];
            NSInteger selectedMonth = [[NSCalendar currentCalendar] component:NSCalendarUnitMonth fromDate:date];

            _firstSelectedColIndex = selectedYear-1910;
            _secondSelectedColIndex = selectedMonth-1;
            
            [_normalPicker reloadAllComponents];
            [_normalPicker selectRow:_firstSelectedColIndex inComponent:0 animated:NO];
            [_normalPicker selectRow:_secondSelectedColIndex inComponent:1 animated:NO];
        }
    }
}
@end
