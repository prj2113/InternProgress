//
//  IPShareViewController.h
//  Intern Progress
//
//  Created by Pooja Jain on 6/9/14.
//  Copyright (c) 2014 pjain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IPShareViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITableView *sharedWithTableView;
@property (strong, nonatomic) NSMutableArray *mentors;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;

@end
