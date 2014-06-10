//
//  IPMentorDetailedViewController.h
//  Intern Progress
//
//  Created by Pooja Jain on 6/10/14.
//  Copyright (c) 2014 pjain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IPMentorDetailedViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *progressTableView;
@property (strong, nonatomic) NSMutableArray *sortedProgressDetails;
@property (strong, nonatomic) NSString *internUsername;
@end
