//
//  PLPickerView.h
//  TestPickerView
//
//  Created by PhilipLee on 15/11/24.
//  Copyright © 2015年 PhilipLee. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLPickerView;

typedef NS_ENUM(NSInteger, PLPickerViewStyle) {
    PLPickerViewStyleDefault          = 0,
    PLPickerViewStyleBlackTranslucent = 1,
    PLPickerViewStyleBlackOpaque      = 2
};

typedef NS_ENUM(NSInteger, PLPickerViewType) {
    PLPickerViewTypeDateAndTime          = 0,
    PLPickerViewTypeDate                 = 1,
    PLPickerViewTypeTwoColumn            = 2,
    PLPickerViewTypeSingleColumn         = 3
};

@protocol PLPickerViewProtocol <NSObject>

@optional
-(void) pickerViewWillDismiss:(PLPickerView *)pickerView;
-(void) didTouchOkButtonOnPickerView:(PLPickerView *)pickerView;
-(void) didTouchCancelButtonOnPickerView:(PLPickerView *)pickerView;

@end

@interface PLPickerView : UIView

//for selected data or preset data
@property(nonatomic, strong) NSDate *selectedDate;
@property(nonatomic, assign) BOOL allowSelectFutureDate;  // default is yes;

@property(nonatomic, strong) NSString *firstSelectedText;
@property(nonatomic, strong) NSString *secondSelectedText;

@property(nonatomic, assign, readonly) PLPickerViewStyle  pickerViewStyle;
@property(nonatomic, assign, readonly) PLPickerViewType pickerViewType;
@property(nonatomic, weak, readonly) id<PLPickerViewProtocol> delegate;

@property(nonatomic, strong) NSArray *firstColumnDatas;

//{ key(#from firstColumnDatas):value (# is NSArray)} 数据格式：{@"":@[@""], @"":@[@""]}
@property(nonatomic, strong) NSDictionary *secondColumnDatas;


-(instancetype) initWithDelegate:(id<PLPickerViewProtocol>)delegate type:(PLPickerViewType) pickerViewType style:(PLPickerViewStyle) pickerViewStyle;
-(void) showInView:(UIView *)view;
-(void) dismiss;
@end
