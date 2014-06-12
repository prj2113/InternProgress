//
//  IPRegisterViewController.m
//  Intern Progress
//
//  Created by Pooja Jain on 6/5/14.
//  Copyright (c) 2014 pjain. All rights reserved.
//

#import "IPRegisterViewController.h"
#import "IPAppDelegate.h"

@interface IPRegisterViewController ()
{
    NSArray *typeOfUsers;
    ApigeeClient *apigeeClient;
}
@end

@implementation IPRegisterViewController

#pragma mark initialization
@synthesize fullName, emailId, password, userType;

#pragma mark View Managing methods
/*
 This method is called whenever a view is loaded for the first time
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    typeOfUsers = [[NSArray alloc] initWithObjects:@"Intern", @"Mentor",nil];
    
    // create an instance of IPAppDelegate.
    IPAppDelegate *appDelegate =(IPAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    // assigns apigeeClient to the instance of apigeeClient in app delegate.
    apigeeClient = appDelegate.apigeeClient;
  
    // Customize navigation bar but putting background images for the bar buttons
    [self.navigationItem.leftBarButtonItem setBackgroundImage:[UIImage imageNamed:@"leftButton"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.navigationItem.rightBarButtonItem setBackgroundImage:[UIImage imageNamed:@"rightButton"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
}

#pragma mark Picker Related methods
/*
 it returns the number of compoents in the picker view.
 */
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

/*
 it returns the number of rows in eachcompoents in the picker view.
 */
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [typeOfUsers count];
}

/*
 It returns the title for each row in the picker view.
 */
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [typeOfUsers objectAtIndex:row];
}

/*
 This method is called whenever a user selects a row in the picker view.
 */
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // sets the user type label based on the user selection.
    switch (row)
    {
        case 0:
            userType.text = @"Intern";
            break;
            
        case 1:
            userType.text = @"Mentor";
            break;
    }
}


#pragma mark Methods based on user actions
/*
 This method is called when a user clicks on the Add button.
 */
- (IBAction)AddUser:(id)sender
{
    
    NSString *NameValue = fullName.text;
    NSString *emailValue = emailId.text;
    NSString *username = emailId.text;
    NSString *passwordValue = password.text;
    NSString *userTypeValue = userType.text;
    
    // Regular expression to check for the email format.
    NSString *emailReg = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailReg];
    
    // tests if email is in the correct format
    if (([emailTest evaluateWithObject:emailValue] != YES) || [emailValue isEqualToString:@""])
    {
        UIAlertView *emailalert = [[UIAlertView alloc] initWithTitle:@"Incorrect Email Format" message:@"abc@example.com format" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        // show alert if entered email id is invalid or empty
        [emailalert show];
    }
    else if([passwordValue length] < 8 || [passwordValue  length]> 30)
    {
        // checks for the password length.
        UIAlertView *passwordalert = [[UIAlertView alloc] initWithTitle:@"Password incorrect length" message:@"Password can be only between 8 to 30 characters." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [passwordalert show];
    }
    else
    {
        ApigeeQuery *query = [[ApigeeQuery alloc] init]; // initialize a query

        
        // Add a filtering condition to the query i.e. to retrieve information only about the current user.
        [query addRequirement:[NSString stringWithFormat:@"username='%@'",username]];
        [[apigeeClient dataClient] getUsers:query completionHandler:^(ApigeeClientResponse *response)
         {
            if ([response completedSuccessfully])
            {
                // if entities are returned, then username already exists.
                if([response.response[@"entities"] count] > 0)
                {
                    [self displayAlert:@"This email id is already taken. Please try logging in or sign up using another email id."];
                }
                else
                {
                    // Add new user.
                    ApigeeClientResponse *result = [[apigeeClient dataClient] addUser:username email:emailValue name:NameValue password:passwordValue];
                    
                    
                    if([result completedSuccessfully])
                    {
                        //call longInUser to initiate the API call
                        [[apigeeClient dataClient] logInUser:username password:passwordValue];
                        @try
                        {
                            // store the userType to teh users collection
                            NSMutableDictionary *updatedentity = [[NSMutableDictionary alloc] init];
                            [updatedentity setObject:userTypeValue forKey:@"userType"];
                            [updatedentity setObject:@"users" forKey:@"type"];
                            [[apigeeClient dataClient] updateEntity:username entity:updatedentity];
                            [self displayAlert:@"User added successfully. Please login with these details."];
                            
                            // logout and redirect user to login again for security.
                            [[apigeeClient dataClient] logOut];

                        }
                        @catch (NSException * e)
                        {
                            [self displayAlert:@"Authentication failed."];
                        }
                    }
                    else
                    {
                        // Log a message.
                        ApigeeLogError(@"AddUser", @"Error while adding new user.");
                        [self displayAlert:@"User could not be added. Please try again."];
                    }
                }
            }
            else
            {
                ApigeeLogError(@"getAppUsers", @"Error while getting user data.");
            }
            
        }];
    }
}


/*
 Called when the Cancel button is clicked.
 */

-(IBAction)cancel:(id)sender
{
    // pops the registration view controller and displays the login page again
    [self.navigationController popViewControllerAnimated:YES];
}

/*
 Displays an alert message.
 */
- (void)displayAlert:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Users"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    if([message isEqualToString:@"User added successfully. Please login with these details."])
    {
        [alert setTag:1];
    }
    [alert show];
}

/*
 When Ok button is clicked on the alert box for successful addition
*/
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 1 && buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
/*
 dismisses the keyboard when user clicks anywhere outside the text field.
 */
- (IBAction)dismissKeyboard:(id)sender
{
    [self.view endEditing:YES];
}

@end
