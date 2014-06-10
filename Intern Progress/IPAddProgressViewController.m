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
    NSDateFormatter *formatter;
    ApigeeClient *apigeeClient;
    IPAppDelegate *appDelegate;
    NSString *username;
    
}
@end

@implementation IPAddProgressViewController
@synthesize selectedDate,datePicker, description;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate =(IPAppDelegate *)[[UIApplication sharedApplication]delegate];
    apigeeClient = appDelegate.apigeeClient;
    username = appDelegate.username;
    
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    formatString = [NSDateFormatter dateFormatFromTemplate:@"dMMMyyyy" options:0 locale:usLocale];
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:formatString];
    
    selectedDate.text =[formatter stringFromDate:datePicker.date];
    
    [datePicker addTarget:self  action:@selector(dateChanged:)
         forControlEvents:UIControlEventValueChanged];
}
- (void)dateChanged:(id)sender
{
    selectedDate.text =[formatter stringFromDate:datePicker.date];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)BackButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)AddNewProgress:(id)sender
{
    NSString *date = selectedDate.text;
    NSString *desc = description.text;
    NSMutableDictionary *newProgress = [[NSMutableDictionary alloc] init];
    [newProgress setObject:@"progresses" forKey:@"type"];
    [newProgress setObject:date forKey:@"date"];
    [newProgress setObject:desc forKey:@"description"];
    [newProgress setObject:username forKey:@"username"];

    ApigeeClientResponse *response = [[apigeeClient dataClient] createEntity:newProgress];
    if([response completedSuccessfully])
    {
        NSArray *entity = [response valueForKey:@"entities"];
        NSString *uuid = [[NSString alloc] init];
        for(ApigeeEntity *eachEntity in entity)
        {
            uuid = [[eachEntity get:@"uuid"] description];
        }
        
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
    
    // create new entity in progresses
    // makea connection from current user to this new entity
}

- (IBAction)dismissKeyboard:(id)sender
{
    [self.view endEditing:YES];
}
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
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag== 3 && buttonIndex==0)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
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
