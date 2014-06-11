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
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication]delegate];
    apigeeClient = appDelegate.apigeeClient;
    
    [self.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = YES;
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    sortedProgressDetails = [[NSMutableArray alloc] init];
    ApigeeClientResponse *response = [[apigeeClient dataClient] getEntityConnections:@"users" connectorID:internUsername connectionType:@"makes" query:nil];
    
    if([response completedSuccessfully])
    {
        NSMutableDictionary *eachDay=[[NSMutableDictionary alloc] init];
        NSArray *entities = [response valueForKey:@"entities"];
        if([entities count] > 0)
        {
            for (ApigeeEntity *eachEntity in entities)
            {
                
                NSString *date = [[eachEntity get:@"date"] description];
                NSString *desc =[[eachEntity get:@"description"] description];
                [eachDay setValue:desc forKey:date];
            }
            
            //sort view on date
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
    
    [progressTableView reloadData];
}



#pragma mark - Table view related methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    return [sortedProgressDetails count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"internDetail";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSString *date = [[[sortedProgressDetails objectAtIndex:indexPath.row] allKeys] objectAtIndex:0];
    cell.textLabel.text = date;
    cell.detailTextLabel.text = [[sortedProgressDetails objectAtIndex:indexPath.row] valueForKey:date];
    
    return cell;
}

#pragma mark Methods based on user actions
- (IBAction)BackButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
