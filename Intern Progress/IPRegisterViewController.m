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

@synthesize fullName, emailId, password, userType;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    typeOfUsers = [[NSArray alloc] initWithObjects:@"Intern", @"Mentor",nil];
    
    IPAppDelegate *appDelegate =(IPAppDelegate *)[[UIApplication sharedApplication]delegate];
    apigeeClient = appDelegate.apigeeClient;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
            self.userType.text = @"Intern";
            break;
            
        case 1:
            self.userType.text = @"Mentor";
            break;
    }
}

- (IBAction)dismissKeyboard:(id)sender
{
    [self.view endEditing:YES];
}

- (IBAction)AddUser:(id)sender
{
    
    NSString *NameValue = fullName.text;
    NSString *emailValue = emailId.text;
    NSString *username = emailId.text;
    NSString *passwordValue = password.text;
    NSString *userTypeValue = userType.text;
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
