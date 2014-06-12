//
//  IPMentorDetailedViewController.h
//  Intern Progress
//
//  Created by Pooja Jain on 6/10/14.
//  Copyright (c) 2014 pjain. All rights reserved.
//

#import <UIKit/UIKit.h>

// The class implements the tableView protocols
@interface IPMentorDetailedViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *progressTableView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (strong, nonatomic) NSString *internUsername; //stores the intern name passed from the previous view.
@property (strong, nonatomic) NSMutableArray *sortedProgressDetails; // stores the content to populate the table view

@end
