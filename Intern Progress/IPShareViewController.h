//
//  IPShareViewController.h
//  Intern Progress
//
//  Created by Pooja Jain on 6/9/14.
//  Copyright (c) 2014 pjain. All rights reserved.
//

#import <UIKit/UIKit.h>

// The class implements the tableView protocols and text field protocols
@interface IPShareViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITableView *sharedWithTableView;

@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (strong, nonatomic) NSMutableArray *mentors; // it stores the list of mentors which are used to populate the tableview

@end
