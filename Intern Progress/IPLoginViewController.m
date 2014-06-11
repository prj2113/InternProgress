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

@synthesize username, password;

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate =(IPAppDelegate *)[[UIApplication sharedApplication]delegate];
    apigeeClient = appDelegate.apigeeClient;

    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil] ;
    user = [[NSMutableArray alloc] init];
    
	// Do any additional setup after loading the view, typically from a nib.
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
}
-(void)viewDidAppear:(BOOL)animated
{
     self.navigationController.navigationBarHidden = YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)Login:(id)sender
{
    
    NSString *usernameValue = username.text;
    NSString *passwordValue = password.text;
    if([usernameValue length] > 0 && [passwordValue length] > 0)
    {
        
        [[apigeeClient dataClient] logInUser:usernameValue password:passwordValue completionHandler:^(ApigeeClientResponse *response)
        {
            if([response completedSuccessfully])
            {
                appDelegate.username = usernameValue;
                ApigeeQuery *query = [[ApigeeQuery alloc] init];
                [query addRequirement:[NSString stringWithFormat:@"username='%@'",usernameValue]];
                ApigeeClientResponse *result = [[apigeeClient dataClient] getUsers:query];
                
                if ([result completedSuccessfully])
                {
                    user = result.response[@"entities"];
                    appDelegate.uuid = [user valueForKey:@"uuid"];
                    if([[[user valueForKey:@"userType"] objectAtIndex:0] isEqualToString:@"Intern"])
                    {
                        [self performSegueWithIdentifier:@"internSegue" sender:self];
                    }
                    else if([[[user valueForKey:@"userType"] objectAtIndex:0] isEqualToString:@"Mentor"])
                    {
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
                [self displayAlert:@"Did you type the username and password correctly?" title:@"Login Failure"];
            }
        }];
    }
    else
    {
        [self displayAlert:@"Username and/or Password is missing" title:@"Missing Credentials"];
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
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

/**
 * Displays an alert message.
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

- (IBAction)dismissKeyboard:(id)sender
{
    [self.view endEditing:YES];
}

@end
