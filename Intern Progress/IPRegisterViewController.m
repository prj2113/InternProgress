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
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    typeOfUsers = [[NSArray alloc] initWithObjects:@"Intern", @"Mentor",nil];
    
    IPAppDelegate *appDelegate =(IPAppDelegate *)[[UIApplication sharedApplication]delegate];
    apigeeClient = appDelegate.apigeeClient;
  
    
    [self.navigationItem.leftBarButtonItem setBackgroundImage:[UIImage imageNamed:@"leftButton"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.navigationItem.rightBarButtonItem setBackgroundImage:[UIImage imageNamed:@"rightButton"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
}

#pragma mark Picker Related methods

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 2;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [typeOfUsers objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
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

- (IBAction)AddUser:(id)sender
{
    
    NSString *NameValue = fullName.text;
    NSString *emailValue = emailId.text;
    NSString *username = emailId.text;
    NSString *passwordValue = password.text;
    NSString *userTypeValue = userType.text;
    
    // Regular expression to checl the email format.
    NSString *emailReg = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailReg];
    if (([emailTest evaluateWithObject:emailValue] != YES) || [emailValue isEqualToString:@""])
    {
        UIAlertView *emailalert = [[UIAlertView alloc] initWithTitle:@"Incorrect Email Format" message:@"abc@example.com format" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [emailalert show];
    }
    else if([passwordValue length] < 8 || [passwordValue  length]> 30)
    {
        UIAlertView *passwordalert = [[UIAlertView alloc] initWithTitle:@"Password incorrect length" message:@"Password can be only between 8 to 30 characters." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [passwordalert show];
    }
    else
    {
        ApigeeQuery *query = [[ApigeeQuery alloc] init];
        [query addRequirement:[NSString stringWithFormat:@"username='%@'",username]];
        [[apigeeClient dataClient] getUsers:query completionHandler:^(ApigeeClientResponse *response)
         {
            if ([response completedSuccessfully])
            {
                if([response.response[@"entities"] count] > 0)
                {
                    [self displayAlert:@"This email id is already taken. Please try logging in or sign up using another email id."];
                }
                else
                {
                    ApigeeClientResponse *result = [[apigeeClient dataClient] addUser:username email:emailValue name:NameValue password:passwordValue];
                    
                    
                    if([result completedSuccessfully])
                    {
                        //call longInUser to initiate the API call
                        [[apigeeClient dataClient] logInUser:username password:passwordValue];
                        @try
                        {
                            NSMutableDictionary *updatedentity = [[NSMutableDictionary alloc] init];
                            [updatedentity setObject:userTypeValue forKey:@"userType"];
                            [updatedentity setObject:@"users" forKey:@"type"];
                            [[apigeeClient dataClient] updateEntity:username entity:updatedentity];
                            [self displayAlert:@"User added successfully. Please login with these details."];
                            [[apigeeClient dataClient] logOut];

                        }
                        @catch (NSException * e)
                        {
                            [self displayAlert:@"Authentication failed."];
                        }
                    }
                    else
                    {
                        // Log (or display) a message.
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
 * Called when the Cancel button is clicked. Dismisses the
 * current UI.
 
*/

-(IBAction)cancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 * Displays an alert message.
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 1 && buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)dismissKeyboard:(id)sender
{
    [self.view endEditing:YES];
}

@end
