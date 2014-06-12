//
//  IPMentorMainViewController.h
//  Intern Progress
//
//  Created by Pooja Jain on 6/8/14.
//  Copyright (c) 2014 pjain. All rights reserved.
//

#import <UIKit/UIKit.h>

// The class implements the tableView protocols
@interface IPMentorMainViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *internListTableView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) NSMutableArray *internID;  // it stores the list of interns which are used to populate the tableview

@end
