//
//  IPInternMainViewController.h
//  Intern Progress
//
//  Created by Pooja Jain on 6/8/14.
//  Copyright (c) 2014 pjain. All rights reserved.
//

#import <UIKit/UIKit.h>

// The class implements the tableView protocols
@interface IPInternMainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *progressTableView;

@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (strong, nonatomic) NSMutableArray *sortedProgressDetails; // stores the content to populate the table view

@end
