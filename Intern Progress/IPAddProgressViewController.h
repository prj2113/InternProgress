//
//  IPAddProgressViewController.h
//  Intern Progress
//
//  Created by Pooja Jain on 6/9/14.
//  Copyright (c) 2014 pjain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IPAddProgressViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;  // PickerView to allow user to pick date

@property (strong, nonatomic) IBOutlet UITextView *description;
@property (strong, nonatomic) IBOutlet UILabel *selectedDate;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;

@end
