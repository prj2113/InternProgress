//
//  IPRegisterViewController.h
//  Intern Progress
//
//  Created by Pooja Jain on 6/5/14.
//  Copyright (c) 2014 pjain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IPRegisterViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UIPickerView *userTypePicker; // PickerView to allow user to pick userType
@property (nonatomic) IBOutlet UITextField *fullName;
@property (nonatomic) IBOutlet UITextField *emailId;
@property (nonatomic) IBOutlet UITextField *password;
@property (nonatomic) IBOutlet UILabel *userType;  

@end
