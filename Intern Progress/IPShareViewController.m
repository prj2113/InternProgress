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
    UITextField *alertTextField;

    NSString *username;
}
@end

@implementation IPShareViewController

@synthesize sharedWithTableView, mentors;

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication]delegate];
    apigeeClient = appDelegate.apigeeClient;
    username = appDelegate.username;
    
    // During startup (-viewDidLoad or in storyboard) do:
    sharedWithTableView.allowsMultipleSelectionDuringEditing = NO;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    mentors = [[NSMutableArray alloc] init];
    
    // retrieve followers of this user
    ApigeeClientResponse *response = [[apigeeClient dataClient] getEntityConnections:@"users" connectorID:username connectionType:@"mentoredBy" query:nil];
    
    if([response completedSuccessfully])
    {
        NSArray *entities = [response valueForKey:@"entities"];
        if([entities count] > 0)
        {
            for(ApigeeEntity *eachEntity in entities)
            {
            
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
    [sharedWithTableView reloadData];
}

#pragma mark - Table view related methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    return [mentors count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"mentorCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [mentors objectAtIndex:indexPath.row];
    return cell;
}



- (IBAction)BackButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)AddNewMentor:(id)sender
{
    alert = [[UIAlertView alloc] initWithTitle:@"Enter email ID of mentor" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertTextField = [alert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeDefault;
    alertTextField.placeholder = @"Enter emailId";
    alertTextField.delegate = self;

    [alertTextField becomeFirstResponder];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *mentorEmailId = alertTextField.text;
    if ([alertTextField.text length] <= 0 || buttonIndex == 0)
    {
        return; //If cancel or 0 length string the string doesn't matter
    }
    if (buttonIndex == 1)
    {
         // validate that the entered email id is a mentor,
        if([self validateUser:mentorEmailId])
        {
            [[apigeeClient dataClient] connectEntities:@"user" connectorID:username connectionType:@"mentoredBy" connecteeType:@"users" connecteeID:mentorEmailId];
            [[apigeeClient dataClient] connectEntities:@"user" connectorID:mentorEmailId connectionType:@"mentoring" connecteeType:@"users" connecteeID:username];
            [self viewWillAppear:YES];
            
        }
        else
        {
            alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Entered email ID is wrong or is not a mentor. Please Try again!!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}



// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *mentorEmailId = cell.textLabel.text;
        
        ApigeeQuery *query = [[ApigeeQuery alloc] init];
        [query addRequirement:[NSString stringWithFormat:@"username='%@'",mentorEmailId]];
        ApigeeClientResponse *response = [[apigeeClient dataClient] getUsers:query];
        if ([response completedSuccessfully])
        {
            if([response.response[@"entities"] count] > 0)
            {
                NSString *uuid = [[response.response[@"entities"] objectAtIndex:0] valueForKey:@"uuid"];
                [[apigeeClient dataClient] disconnectEntities:@"users" connectorID:username type:@"mentoredBy" connecteeID:uuid];
                [[apigeeClient dataClient] disconnectEntities:@"users" connectorID:mentorEmailId type:@"mentoring" connecteeID:username];
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

- (BOOL)validateUser:(NSString *)mentorEmailId
{
    ApigeeQuery *query = [[ApigeeQuery alloc] init];
    [query addRequirement:[NSString stringWithFormat:@"username='%@'",mentorEmailId]];

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
