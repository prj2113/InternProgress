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
/*
 This method is called whenever a view is loaded for the first time
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // create an instance of IPAppDelegate.
    appDelegate=(IPAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    // assigns apigeeClient to the instance of apigeeClient in app delegate.
    apigeeClient = appDelegate.apigeeClient;
    
    // get the username of the logged in user.
    mentorUsername = appDelegate.username;
    
    // Customize the navigation bar
    [self.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = YES;
    self.view.backgroundColor = [UIColor clearColor];
}

/*
 This method is called everytime a view appears
 */
- (void)viewWillAppear:(BOOL)animated
{
    // initialize an array to store data to be populated in the table view.
    internID = [[NSMutableArray alloc] init];
    
    // retrieve interns who the user is mentoring
    ApigeeClientResponse *response = [[apigeeClient dataClient] getEntityConnections:@"users" connectorID:mentorUsername connectionType:@"mentoring" query:nil];
    
    if([response completedSuccessfully])
    {
        NSArray *entities = [response valueForKey:@"entities"];
        if([entities count] > 0)
        {
            for(ApigeeEntity *eachEntity in entities)
            {
                // add the retrieved mentor names to the internID array
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
    
    // reload table view with new date.
    [internListTableView reloadData];
}

#pragma mark - Table view related methods
/*
 it returns the number of sections in the table view.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}

/*
 it returns the number of rows in each sections of the table view.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    return [internID count];
}

/*
 Sets the properties of each cell in the table view.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"internCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        // alloc and initialize a cell with style UITableViewCellStyleDefault
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // set the intern name in corresponding cell.
    cell.textLabel.text = [internID objectAtIndex:indexPath.row];
                           
    return cell;
}

/*
 This method recognizes the row selection the tableView 
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                @"Main" bundle:[NSBundle mainBundle]];
    
    // pass the intern name to the IPMentorDetailedViewController
    IPMentorDetailedViewController *detailVC = [storyboard instantiateViewControllerWithIdentifier:@"IPMentorDetailedViewController"];
    detailVC.internUsername = cell.textLabel.text;
    
    // present the detail vew controller
    [self presentViewController:detailVC animated:YES completion:nil];
}

#pragma mark Methods based on user actions
/*
 This method is called when a user clicks on the logout button.
 */
- (IBAction)Logout:(id)sender
{
    // logs out the user and revokes the assigned token
    [[apigeeClient dataClient] logOut];
}

@end
