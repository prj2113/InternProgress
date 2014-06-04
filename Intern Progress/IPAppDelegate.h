//
//  IPAppDelegate.h
//  Intern Progress
//
//  Created by Pooja Jain on 6/4/14.
//  Copyright (c) 2014 pjain. All rights reserved.
//


@interface IPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ApigeeClient *apigeeClient; //object for initializing the SDK
@property (strong, nonatomic) ApigeeMonitoringClient *monitoringClient; //client object for Apigee App Monitoring methods
@property (strong, nonatomic) ApigeeDataClient *dataClient;	//client object for data methods


@end
