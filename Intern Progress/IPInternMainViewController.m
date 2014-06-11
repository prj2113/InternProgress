//
//  IPInternMainViewController.m
//  Intern Progress
//
//  Created by Pooja Jain on 6/8/14.
//  Copyright (c) 2014 pjain. All rights reserved.
//

#import "IPInternMainViewController.h"
#import "IPAppDelegate.h"

@interface IPInternMainViewController ()
{
    ApigeeClient *apigeeClient;
    IPAppDelegate *appDelegate;
}
@end

@implementation IPInternMainViewController

@synthesize progressTableView, sortedProgressDetails;
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    ApigeeClientResponse *response = [[apigeeClient dataClient] getEntityConnections:@"users" connectorID:appDelegate.username connectionType:@"makes" query:nil];
    
    if([response completedSuccessfully])
    {
        NSMutableDictionary *eachDay=[[NSMutableDictionary alloc] init];
        NSArray *entities = [response valueForKey:@"entities"];
        if([entities count] > 0)
        {
            for (ApigeeEntity *eachEntity in entities)
            {
                
                NSString *date = [[NSString alloc] init];
                NSString *desc = [[NSString alloc] init];
                date = [[eachEntity get:@"date"] description];
                desc = [[eachEntity get:@"description"] description];
                [eachDay setValue:desc forKey:date];
            }
            
            //sort view on date
            NSArray *keys = [[NSArray alloc] init];
            keys = [eachDay allKeys];
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

- (IBAction)Logout:(id)sender
{
    [[apigeeClient dataClient] logOut];
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
    static NSString *cellIdentifier = @"dailyProgressCell";
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
- (IBAction)addProgress:(id)sender
{
    [self performSegueWithIdentifier:@"addProgress" sender:self];
}
- (IBAction)shareClicked:(id)sender
{
      [self performSegueWithIdentifier:@"manageSharing" sender:self];
}



@end
