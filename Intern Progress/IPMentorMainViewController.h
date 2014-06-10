//
//  IPMentorMainViewController.h
//  Intern Progress
//
//  Created by Pooja Jain on 6/8/14.
//  Copyright (c) 2014 pjain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IPMentorMainViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *internListTableView;
@property (strong, nonatomic) NSMutableArray *internID;

@end
