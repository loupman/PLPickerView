//
//  PLPickerView.h
//  TestPickerView
//
//  Created by PhilipLee on 15/11/24.
//  Copyright © 2015年 PhilipLee. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLPickerView;

@interface PLPickerObject : NSObject

@property(copy, nonatomic) NSString *key;
@property(copy, nonatomic) id extraData;
@property(strong, nonatomic) NSArray<PLPickerObject *> *subObjects;

+(instancetype)objectWithKey:(NSString *)key extraData:(id)extraData;
- (NSComparisonResult)compare:(PLPickerObject *)object;
@end

typedef NS_ENUM(NSInteger, PLPickerViewStyle) {
    PLPickerViewStyleDefault          = 0,
    PLPickerViewStyleBlackTranslucent = 1,
    PLPickerViewStyleBlackOpaque      = 2
};

typedef NS_ENUM(NSInteger, PLPickerViewType) {
    PLPickerViewTypeDateAndTime          = 0,
    PLPickerViewTypeDate                 = 1, // year, month, day
    PLPickerViewTypeYearAndMonth         = 2,
    PLPickerViewTypeSingleColumn         = 3,
    PLPickerViewTypeTwoColumn            = 4
};

@protocol PLPickerViewDelegate <NSObject>

@optional

/**
 *   cancel=0 , ok=1, background=2 of touch position
 *
 *  @param pickerView  pickerView
 *  @param index : 点击的地方
 */
-(void) plPickerView:(PLPickerView *)pickerView didDismissWithTouchIndex:(NSInteger)index;

@end

@interface PLPickerView : UIView

/**
 * pickerViewType= PLPickerViewTypeDateAndTime,PLPickerViewTypeDate
 *  or PLPickerViewTypeYearAndMonth.
 * if you set this property then will show the select the date automatically
 */
@property(nonatomic, strong) NSDate *selectedDate;

/**
 *  default is YES, if pickerViewType= PLPickerViewTypeDateAndTime,PLPickerViewTypeDate 
 *  or PLPickerViewTypeYearAndMonth
 */
@property(nonatomic, assign) BOOL allowSelectFutureDate;  // default is yes;

/**
 *  pickerViewType = PLPickerViewTypeTwoColumn, you can use next two properties to make picker select related row
 *  pickerViewType = PLPickerViewTypeSingleColumn, then firstSelectedColIndex is available to make picker select related row
 */
@property(nonatomic, assign) NSUInteger firstSelectedColIndex;
@property(nonatomic, assign) NSUInteger secondSelectedColIndex;

/**
 * pickerViewType = PLPickerViewTypeTwoColumn, pickerViewType = PLPickerViewTypeSingleColumn
 * will be used to set data at the first column of picker
 *  and "key" in object will be displayed
 *
 */
@property(nonatomic, strong) NSArray<PLPickerObject *> *dataObjects;

/**
 *  Set pickerViewType before calling showInView: method, 
 * default value is PLPickerViewStyleDefault which has a transcent background
 */
@property(nonatomic, assign) PLPickerViewStyle  pickerViewStyle;

/**
 *  The backgroud view will display different color
 */
@property(nonatomic, assign, readonly) PLPickerViewType pickerViewType;

// another convienent block method, same as the delegate method
@property(strong, nonatomic) void (^plPickerViewDidDimissWithButtonIndex)(PLPickerView *pickerView, NSInteger index);

// a construct method, you need to use this
-(instancetype) initWithDelegate:(id<PLPickerViewDelegate>)delegate type:(PLPickerViewType) pickerViewType;

-(void) showInView:(UIView *)view;
-(void) dismiss;
@end
