//
//  IPViewController.m
//  Intern Progress
//
//  Created by Pooja Jain on 6/4/14.
//  Copyright (c) 2014 pjain. All rights reserved.
//

#import "IPLoginViewController.h"
#import "IPAppDelegate.h"

@interface IPLoginViewController ()
{
    ApigeeClient *apigeeClient;
    IPAppDelegate *appDelegate;
    UIStoryboard *storyboard;
    NSMutableArray *user;
}
@end

@implementation IPLoginViewController

#pragma mark initialization
@synthesize username, password;

#pragma mark View Managing methods

/*
 This method is called whenever a view is loaded for the first time
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // create an instance of IPAppDelegate.
    appDelegate =(IPAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // assigns apigeeClient to the instance of apigeeClient in app delegate.
    apigeeClient = appDelegate.apigeeClient;

    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil] ;
    
    // initializes the user array to store user entities.
    user = [[NSMutableArray alloc] init];
    
	// Customize the navigation bar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
}


#pragma mark Methods based on user actions

/*
 This method is called when a user clicks on the login button.
 */
- (IBAction)Login:(id)sender
{
    NSString *usernameValue = username.text; // username entered by the user.
    NSString *passwordValue = password.text; // password entered by the user.
    
    // checks if user has entered both username and password
    if([usernameValue length] > 0 && [passwordValue length] > 0)
    {
        // call the logInUser method of the ApigeeClient dataClient to authenticate the user.
        [[apigeeClient dataClient] logInUser:usernameValue password:passwordValue completionHandler:^(ApigeeClientResponse *response)
        {
            // checks the response of the api call
            if([response completedSuccessfully])
            {
                appDelegate.username = usernameValue;   //assign the username instance in the appDelegate.
                
                ApigeeQuery *query = [[ApigeeQuery alloc] init]; // initialize a query
                
                // Add a filtering condition to the query i.e. to retrieve information only about the current user.
                [query addRequirement:[NSString stringWithFormat:@"username='%@'",usernameValue]];
                
                // Get Users method to get users with the given query constraint
                ApigeeClientResponse *result = [[apigeeClient dataClient] getUsers:query];
                
                if ([result completedSuccessfully])
                {
                    // retrieve the entities in the response
                    user = result.response[@"entities"];
                    
                    //assign the uudi instance in the appDelegate.
                    appDelegate.uuid = [[user valueForKey:@"uuid"] objectAtIndex:0];
                    
                    // check if current user is Intern or a mentor
                    if([[[user valueForKey:@"userType"] objectAtIndex:0] isEqualToString:@"Intern"])
                    {
                        // perform segue to present the views for an intern userType.
                        [self performSegueWithIdentifier:@"internSegue" sender:self];
                    }
                    else if([[[user valueForKey:@"userType"] objectAtIndex:0] isEqualToString:@"Mentor"])
                    {
                        // perform segue to present the views for an mentor userType.
                        [self performSegueWithIdentifier:@"mentorSegue" sender:self];
                    }
                }
                else
                {
                    NSLog(@"error in getting entities");
                }
            }
            else
            {
                // Failed login. Display alert to inform the user.
                [self displayAlert:@"Did you type the username and password correctly?" title:@"Login Failure"];
            }
        }];
    }
    else
    {
        // show alert if user does not input both the fields.
        [self displayAlert:@"Username and/or Password is missing" title:@"Missing Credentials"];
    }
}

/*
 This method is called whenever a segue is triggered.
 */
 -(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    // Depending on the type of the Segue, the corresponding view controller is pushed on the navigation controller.
    if ([segue.identifier isEqualToString:@"internSegue"])
    {
        UIViewController *internView = [storyboard instantiateViewControllerWithIdentifier:@"IPInternMainViewController"];
        [self.navigationController pushViewController:internView animated:YES];
    }
    else if ([segue.identifier isEqualToString:@"mentorSegue"])
    {
        UIViewController *mentorView = [storyboard instantiateViewControllerWithIdentifier:@"IPMentorMainViewController"];
        [self.navigationController pushViewController:mentorView animated:YES];
    }
}

/*
 Displays an alert message.
 */
- (void)displayAlert:(NSString *)message title:(NSString *)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Try again"
                                           otherButtonTitles:nil];
    [alert show];
}

/*
 dismisses the keyboard when user clicks anywhere outside the text field.
 */
- (IBAction)dismissKeyboard:(id)sender
{
    [self.view endEditing:YES];
}

@end
