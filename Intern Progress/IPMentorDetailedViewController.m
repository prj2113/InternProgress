//
//  IPMentorDetailedViewController.m
//  Intern Progress
//
//  Created by Pooja Jain on 6/10/14.
//  Copyright (c) 2014 pjain. All rights reserved.
//

#import "IPMentorDetailedViewController.h"
#import "IPAppDelegate.h"

@interface IPMentorDetailedViewController ()
{
    ApigeeClient *apigeeClient;
    IPAppDelegate *appDelegate;
}
@end

@implementation IPMentorDetailedViewController

#pragma mark initialization
@synthesize internUsername, progressTableView, sortedProgressDetails;

#pragma mark View Managing methods
/*
 This method is called whenever a view is loaded for the first time
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // create an instance of IPAppDelegate.
    appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    // assigns apigeeClient to the instance of apigeeClient in app delegate.
    apigeeClient = appDelegate.apigeeClient;
    
    // Customize teh navigation bar
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
    sortedProgressDetails = [[NSMutableArray alloc] init];
    
    // get the connections "makes" i.e. the progess made by the intern
    ApigeeClientResponse *response = [[apigeeClient dataClient] getEntityConnections:@"users" connectorID:internUsername connectionType:@"makes" query:nil];
    
    if([response completedSuccessfully])
    {
        NSMutableDictionary *eachDay=[[NSMutableDictionary alloc] init];
        NSArray *entities = [response valueForKey:@"entities"];
        if([entities count] > 0)
        {
            for (ApigeeEntity *eachEntity in entities)
            {
                // retrieve the date and desription of each entity.
                NSString *date = [[eachEntity get:@"date"] description];
                NSString *desc =[[eachEntity get:@"description"] description];
                [eachDay setValue:desc forKey:date];
            }
            
            //sort the results on date
            NSArray *keys = [eachDay allKeys];
            NSArray *sortedKeys = [keys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            
            for(NSString *key in sortedKeys)
            {
                NSMutableDictionary *sortedEntity = [[NSMutableDictionary alloc] init];
                NSString *desc = [eachDay objectForKey:key];
                [sortedEntity setObject:desc forKey:key];
                [sortedProgressDetails addObject:sortedEntity];
            }
            
        }
        else
        {
            [eachDay setValue:@"No Progress reported yet." forKey:@"None"];
            [sortedProgressDetails addObject:eachDay];
        }
    }
    else
    {
        ApigeeLogError(@"Connections Error",@"Get Connections failed");
    }
    
    // reload table view with new date.
    [progressTableView reloadData];
}



#pragma mark - Table view related methods
/*
 it returns the number of sections in the table view.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/*
 it returns the number of rows in each sections of the table view.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [sortedProgressDetails count];
}

/*
 Sets the properties of each cell in the table view.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"internDetail";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        // alloc and initialize a cell with style UITableViewCellStyleSubtitle
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSString *date = [[[sortedProgressDetails objectAtIndex:indexPath.row] allKeys] objectAtIndex:0];
    
    // set the date and description for each cell.
    cell.textLabel.text = date;
    cell.detailTextLabel.text = [[sortedProgressDetails objectAtIndex:indexPath.row] valueForKey:date];
    
    return cell;
}

#pragma mark Methods based on user actions
/*
 This method is called when a user clicks on the Back button.
 */
- (IBAction)BackButtonPressed:(id)sender
{
    // dismiss this view controller and show intern main page
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
