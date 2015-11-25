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

@interface PLPickerView()<UIPickerViewDelegate, UIPickerViewDataSource> {
    CGFloat pickerHeight;
    CGFloat pickerWidth;
}

@property(nonatomic, strong) UIDatePicker *datePicker;
@property(nonatomic, strong) UIPickerView *normalPicker;

@property(nonatomic, strong) UIControl *coverLayer;
@end

@implementation PLPickerView

-(instancetype) initWithDelegate:(id<PLPickerViewProtocol>)delegate type:(PLPickerViewType)pickerViewType style:(PLPickerViewStyle)pickerViewStyle
{
    pickerWidth = kScreenWidth;
    pickerHeight = 252.f;
    CGRect frame = CGRectMake(0, kScreenHeight, pickerWidth, pickerHeight);
    if (self = [super initWithFrame:frame]) {
        _pickerViewStyle = pickerViewStyle;
        _pickerViewType = pickerViewType;
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
    
    view.backgroundColor = kColorRGBA(248, 248, 248, 1);
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, 40)];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [cancelButton setTitleColor:kBlueColor forState:UIControlStateNormal];
    UIButton *okButton = [[UIButton alloc] initWithFrame:CGRectMake(pickerWidth - buttonWidth, 0, buttonWidth, 40)];
    [okButton setTitle:@"确定" forState:UIControlStateNormal];
    okButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [okButton setTitleColor:kBlueColor forState:UIControlStateNormal];
    
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
    if (_pickerViewType == PLPickerViewTypeTwoColumn) {
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
            return [_firstColumnDatas count];
            break;
        case 1: {
            id data = _secondColumnDatas[_firstSelectedText];
            if ([data isKindOfClass:NSArray.class]) {
                return [data count];
            } else if ([data isKindOfClass:NSString.class]) {
                return 1;
            }
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
            return _firstColumnDatas[row];
            break;
        case 1: {
            id data = _secondColumnDatas[_firstSelectedText];
            if ([data isKindOfClass:NSArray.class]) {
                return data[row];
            }
            return [NSString stringWithFormat:@"%@", data];
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
            _firstSelectedText = _firstColumnDatas[row];
            
            if (_pickerViewType == PLPickerViewTypeTwoColumn) {
                [pickerView reloadComponent:1];
                [pickerView selectRow:0 inComponent:1 animated:YES];
            }
        }
            break;
        case 1: {
            id data = _secondColumnDatas[_firstSelectedText];
            if ([data isKindOfClass:NSArray.class]) {
                _secondSelectedText = data[row];
            } else {
                _secondSelectedText = [NSString stringWithFormat:@"%@", data];
            }
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
    }
    
    if([_delegate respondsToSelector:@selector(didTouchOkButtonOnPickerView:)]) {
        [_delegate didTouchOkButtonOnPickerView:self];
    }
    
    [self dismiss];
}

-(void) didTouchCancelButton
{
    if ([_delegate respondsToSelector:@selector(didTouchCancelButtonOnPickerView:)]) {
        [_delegate didTouchCancelButtonOnPickerView:self];
    }
    
    [self dismiss];
}

-(void) showInView:(UIView *)view
{
    if (!_coverLayer) {
        _coverLayer = [[UIControl alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _coverLayer.backgroundColor = kColorRGBA(127, 127, 127, 0.95);
        [_coverLayer addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        
        [_coverLayer addSubview:self];
    }
    switch (_pickerViewStyle) {
        case PLPickerViewStyleDefault:
            _coverLayer.backgroundColor = kColorRGBA(127, 127, 127, 0.7);
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
    
    _coverLayer.alpha = 0;
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.35 animations:^{
        weakSelf.coverLayer.alpha = 1;
    }];
    CGRect frame = CGRectMake(0, kScreenHeight - pickerHeight, pickerWidth, pickerHeight);
    [UIView animateWithDuration:0.35 animations:^{
        weakSelf.frame = frame;
    }];
    
}
-(void) dismiss
{
    if ([_delegate respondsToSelector:@selector(pickerViewWillDismiss:)]) {
        [_delegate pickerViewWillDismiss:self];
    }
    
    __weak __typeof(self) weakSelf = self;
    CGRect frame = CGRectMake(0, kScreenHeight, pickerWidth, pickerHeight);
    [UIView animateWithDuration:0.35 animations:^{
        weakSelf.frame = frame;
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
            if (_firstSelectedText) {
                NSInteger row = [_firstColumnDatas indexOfObject:_firstSelectedText];
                [_normalPicker selectRow:row inComponent:0 animated:NO];
                
                if (_pickerViewType == PLPickerViewTypeTwoColumn) {
                    NSInteger row = 0;
                    if (_secondSelectedText) {
                        row = [_secondColumnDatas[_firstSelectedText] indexOfObject:_secondSelectedText];
                    }
                    [_normalPicker selectRow:row inComponent:1 animated:NO];
                }
            }
        }
    }
    
    
}
@end
