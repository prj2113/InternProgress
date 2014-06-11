//
//  IPMentorMainViewController.m
//  Intern Progress
//
//  Created by Pooja Jain on 6/8/14.
//  Copyright (c) 2014 pjain. All rights reserved.
//

#import "IPMentorMainViewController.h"
#import "IPAppDelegate.h"
#import "IPMentorDetailedViewController.h"
@interface IPMentorMainViewController ()
{
    ApigeeClient *apigeeClient;
    IPAppDelegate *appDelegate;
    NSString *mentorUsername;
    NSString *internUsername;
}
@end

@implementation IPMentorMainViewController

#pragma mark initialization
@synthesize internID, internListTableView;

#pragma mark View Managing methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appDelegate=(IPAppDelegate *)[[UIApplication sharedApplication]delegate];
    apigeeClient = appDelegate.apigeeClient;
    mentorUsername = appDelegate.username;
    
    [self.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = YES;
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    internID = [[NSMutableArray alloc] init];
    
    // retrieve followers of this user
    ApigeeClientResponse *response = [[apigeeClient dataClient] getEntityConnections:@"users" connectorID:mentorUsername connectionType:@"mentoring" query:nil];
    if([response completedSuccessfully])
    {
        NSArray *entities = [response valueForKey:@"entities"];
        if([entities count] > 0)
        {
            for(ApigeeEntity *eachEntity in entities)
            {
                [internID addObject:[eachEntity get:@"username"]];
                
            }
        }
        else
        {
             [internID addObject:@"You have no interns currently"];
        }
    }
    else
    {
        [internID addObject:@"You have no interns currently"];
        ApigeeLogError(@"Get Connections", @"Could not retrieve entities mentoring connections");
    }
    [internListTableView reloadData];
}

#pragma mark - Table view related methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    return [internID count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"internCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [internID objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                @"Main" bundle:[NSBundle mainBundle]];
    
    IPMentorDetailedViewController *detailVC = [storyboard instantiateViewControllerWithIdentifier:@"IPMentorDetailedViewController"];
    detailVC.internUsername = cell.textLabel.text;
    [self presentViewController:detailVC animated:YES completion:nil];
}

#pragma mark Methods based on user actions
- (IBAction)Logout:(id)sender
{
    [[apigeeClient dataClient] logOut];
}



@end
