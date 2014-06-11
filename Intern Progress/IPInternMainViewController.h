//
//  IPInternMainViewController.h
//  Intern Progress
//
//  Created by Pooja Jain on 6/8/14.
//  Copyright (c) 2014 pjain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IPInternMainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *progressTableView;
@property (strong, nonatomic) NSMutableArray *sortedProgressDetails;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;

@end
