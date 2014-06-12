//
//  IPAddProgressViewController.m
//  Intern Progress
//
//  Created by Pooja Jain on 6/9/14.
//  Copyright (c) 2014 pjain. All rights reserved.
//

#import "IPAddProgressViewController.h"
#import "IPAppDelegate.h"

@interface IPAddProgressViewController ()
{
    NSString *formatString;
    NSDateFormatter *formatter; // to set the date format
    ApigeeClient *apigeeClient;
    IPAppDelegate *appDelegate;
    NSString *username;
}
@end

@implementation IPAddProgressViewController

#pragma mark initialization
@synthesize selectedDate,datePicker, description;

#pragma mark View Managing methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // create an instance of IPAppDelegate.
    appDelegate =(IPAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    // assigns apigeeClient to the instance of apigeeClient in app delegate.
    apigeeClient = appDelegate.apigeeClient;
    
    // get the username of the logged in user.
    username = appDelegate.username;
    
    // set the date format
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    formatString = [NSDateFormatter dateFormatFromTemplate:@"dMMMyyyy" options:0 locale:usLocale];
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:formatString];
    
    selectedDate.text =[formatter stringFromDate:datePicker.date];
    
    [datePicker addTarget:self  action:@selector(dateChanged:)
         forControlEvents:UIControlEventValueChanged];
    
    // Customize the navigation bar
    [self.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = YES;
    self.view.backgroundColor = [UIColor clearColor];
}



#pragma mark Methods based on user actions

/*
 This method is called when a user clicks on the Back button.
 */
- (IBAction)BackButton:(id)sender
{
    // dismiss this view controller and show intern main page
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
 This method is called when a user clicks on the Add button.
 */
- (IBAction)AddNewProgress:(id)sender
{
    NSString *date = selectedDate.text;
    NSString *desc = description.text;
    NSMutableDictionary *newProgress = [[NSMutableDictionary alloc] init];
    
    // set properties of new progress.
    [newProgress setObject:@"progresses" forKey:@"type"];
    [newProgress setObject:date forKey:@"date"];
    [newProgress setObject:desc forKey:@"description"];
    [newProgress setObject:username forKey:@"username"];

    // if date already exists, then the description is updated.
    if ([desc length] <=0)
    {
        UIAlertView *descriptionalert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter a description" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [descriptionalert show];

    }
    else
    {
        // create new entity in progresses
        ApigeeClientResponse *response = [[apigeeClient dataClient] createEntity:newProgress];
        if([response completedSuccessfully])
        {
            NSArray *entity = [response valueForKey:@"entities"];
            NSString *uuid = [[NSString alloc] init];
            
            for(ApigeeEntity *eachEntity in entity)
            {
                // get uuid of new entity.
                uuid = [[eachEntity get:@"uuid"] description];
            }
            
            // create a "makes" connection from current user to this new entity i.e. progress
            ApigeeClientResponse *result = [[apigeeClient dataClient] connectEntities:@"users" connectorID:username connectionType:@"makes" connecteeType:@"progresses" connecteeID:uuid];
            if([result completedSuccessfully])
            {
                [self displayAlert:@"Successfully added." title:@"Sucess"];
            }
            else
            {
                [self displayAlert:@"Progress could not be added. Please Try again." title:@"Error"];
            }
        }
        else
        {
            [self displayAlert:@"Progress could not be added. Please Try again." title:@"Error"];
        }
    }
}


- (void)dateChanged:(id)sender
{
    selectedDate.text =[formatter stringFromDate:datePicker.date];
}

/*
 dismisses the keyboard when user clicks anywhere outside the text field.
 */
- (IBAction)dismissKeyboard:(id)sender
{
    [self.view endEditing:YES];
}


/*
 Displays an alert message.
 */
- (void)displayAlert:(NSString *)message title:(NSString *)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
    if([message isEqualToString:@"Successfully added."])
    {
        alert.tag = 3;
    }
    
}

/*
 When Ok button is clicked on the alert box for successful addition
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag== 3 && buttonIndex==0)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


@end
