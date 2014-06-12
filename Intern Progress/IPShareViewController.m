//
//  IPShareViewController.m
//  Intern Progress
//
//  Created by Pooja Jain on 6/9/14.
//  Copyright (c) 2014 pjain. All rights reserved.
//

#import "IPShareViewController.h"
#import "IPAppDelegate.h"

@interface IPShareViewController ()
{
    IPAppDelegate *appDelegate;
    ApigeeClient *apigeeClient;
    UIAlertView* alert;
    UITextField *alertTextField;  // this will allow user to input in the pop up
    NSString *username;
}
@end

@implementation IPShareViewController

#pragma mark initialization
@synthesize sharedWithTableView, mentors;

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
    
    // get the username of the logged in user.
    username = appDelegate.username;

    // Customize the navigation bar
    [self.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = YES;
    self.view.backgroundColor = [UIColor clearColor];
    
    // This will enable deletion in the table view, but only one at a time.
    sharedWithTableView.allowsMultipleSelectionDuringEditing = NO;
}

/*
 This method is called everytime a view appears
 */
- (void)viewWillAppear:(BOOL)animated
{
    // set the delegate and datasource of the table view to the view controller.
    sharedWithTableView.delegate = self;
    sharedWithTableView.dataSource = self;
    
    // initialize an array to store data to be populated in the table view.
    mentors = [[NSMutableArray alloc] init];
    
    // retrieve mentors of this user
    ApigeeClientResponse *response = [[apigeeClient dataClient] getEntityConnections:@"users" connectorID:username connectionType:@"mentoredBy" query:nil];
    
    if([response completedSuccessfully])
    {
        NSArray *entities = [response valueForKey:@"entities"];
        if([entities count] > 0)
        {
            for(ApigeeEntity *eachEntity in entities)
            {
                // add the retrieved mentor names to the mentors array
                [mentors addObject:[eachEntity get:@"username"]];
            
            }
       }
       else
       {
           [mentors addObject:@"You have not shared your report with any mentor"];
       }
    }
    else
    {
        ApigeeLogError(@"Get Entities", @"Could not retrieve entities of collection users");
    }
    
    // reload table view with new data.
    [sharedWithTableView reloadData];
}

#pragma mark - Table view related methods
/*
 it returns the number of sections in the table view.
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

/*
 it returns the number of rows in each sections of the table view.
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [mentors count];
}

/*
 Sets the properties of each cell in the table view.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"mentorCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        // alloc and initialize a cell with style UITableViewCellStyleDefault
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // set the mentor name in corresponding cell.
    cell.textLabel.text = [mentors objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark Deleting Row methods
/*
 This method enables the tableView row to be edtied. i.e. in this case deleted.
 */
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
     // checks if user wants to delete the cell
     if (editingStyle == UITableViewCellEditingStyleDelete)
     {
         // retrive the cell which is  being deleted
         UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
         
         NSString *mentorEmailId = cell.textLabel.text;
         NSString *internUuid  = appDelegate.uuid;
         
         ApigeeQuery *query = [[ApigeeQuery alloc] init]; // initialize a query

         // Add a filtering condition to the query i.e. to retrieve information only about the current user.
         [query addRequirement:[NSString stringWithFormat:@"username='%@'",mentorEmailId]];
         
         // Get Users method to get users with the given query constraint
         ApigeeClientResponse *response = [[apigeeClient dataClient] getUsers:query];
         
         if ([response completedSuccessfully])
         {
             if([response.response[@"entities"] count] > 0)
             {
                 // get uuid of selected mentor
                 NSString *Mentoruuid = [[response.response[@"entities"] objectAtIndex:0] valueForKey:@"uuid"];
                 
                 // disconnect the mentoredBy connection
                 [[apigeeClient dataClient] disconnectEntities:@"users" connectorID:username type:@"mentoredBy" connecteeID:Mentoruuid];
                 
                 // disconnect the mentoring connection
                 [[apigeeClient dataClient] disconnectEntities:@"users" connectorID:Mentoruuid type:@"mentoring" connecteeID:internUuid];
                 
                 // refresh the view to reflect deleted row.
                 [self viewWillAppear:YES];
             }
         }
         else
         {
             alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"could'nt delete mentor" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
             [alert show];
         }
     }
 }


#pragma mark Methods based on user actions
/*
 This method is called when a user clicks on the Back button.
 */
- (IBAction)BackButton:(id)sender
{
    // dismiss this view controller and show intern main page
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

/*
 This method allows the intern to add new mentor to share his progress report with
 */
- (IBAction)AddNewMentor:(id)sender
{
    //shows an alert with text field to enable the user to enter the mentor id
    alert = [[UIAlertView alloc] initWithTitle:@"Enter email ID of mentor" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertTextField = [alert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeDefault;
    alertTextField.placeholder = @"Enter emailId";
    alertTextField.delegate = self;

    [alertTextField becomeFirstResponder];
    [alert show];
}

/*
 When Ok button is clicked on the alert box for successful addition
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *mentorEmailId = alertTextField.text;
    // checks if user entered something or clicked on cancel button.
    if ([alertTextField.text length] <= 0 || buttonIndex == 0)
    {
        return; //If cancel or 0 length string the string doesn't matter
    }
    // If ok is pressed
    if (buttonIndex == 1)
    {
        // validate that the entered email id is a mentor,
        if([self validateUser:mentorEmailId])
        {
            // create mentoredBy connection from intern to mentor
            [[apigeeClient dataClient] connectEntities:@"users" connectorID:username connectionType:@"mentoredBy" connecteeType:@"users" connecteeID:mentorEmailId];
            // create mentoring connection from mentor to intern
            [[apigeeClient dataClient] connectEntities:@"users" connectorID:mentorEmailId connectionType:@"mentoring" connecteeType:@"users" connecteeID:username];
            // refresh view to show added mentor.
            [self viewWillAppear:YES];
        }
        else
        {
            alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Entered email ID is wrong or is not a mentor. Please Try again!!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

/*
 This method validates the email id entered by the user, to verify if he is a mentor.
 */
- (BOOL)validateUser:(NSString *)mentorEmailId
{
    ApigeeQuery *query = [[ApigeeQuery alloc] init]; // initialize a query
    
    // Add a filtering condition to the query i.e. to retrieve information only about the current user.
    [query addRequirement:[NSString stringWithFormat:@"username='%@'",mentorEmailId]];

    // get the entities for collection users
    ApigeeClientResponse *response = [[apigeeClient dataClient] getEntities:@"users" query:query];
    
    if([response completedSuccessfully])
    {
        NSArray *entities = [response valueForKey:@"entities"];
        if([entities count] > 0)
        {
            if([[[[entities objectAtIndex:0] get:@"userType"] description] isEqualToString:@"Mentor"])
            {
                return YES;
            }
            else
            {
                return NO;
            }
        }
        else
        {
            return NO;
        }
    }
    else
    {
        ApigeeLogError(@"Get User Entity",@"Failed to retrieve users");
        return NO;
    }
}

@end
