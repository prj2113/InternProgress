//
//  IPAppDelegate.m
//  Intern Progress
//
//  Created by Pooja Jain on 6/4/14.
//  Copyright (c) 2014 pjain. All rights reserved.
//

#import "IPAppDelegate.h"

@implementation IPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    IPAppDelegate *appDelegate = (IPAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Register on developers.apigee.com to get your own credentials
    NSString *orgName = @"pjain"; //organization name
    NSString *appName = @"internprogress"; //app name
    
    //Instantiate ApigeeClient to initialize the SDK
    appDelegate.apigeeClient = [[ApigeeClient alloc] initWithOrganizationId:orgName applicationId:appName];
    
    //Retrieve instances of ApigeeClient.monitoringClient and ApigeeClient.dataClient
    self.monitoringClient = [appDelegate.apigeeClient monitoringClient]; //used to call App Monitoring methods
    self.dataClient = [appDelegate.apigeeClient dataClient]; //used to call data methods
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
