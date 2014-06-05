//
//  IPViewController.m
//  Intern Progress
//
//  Created by Pooja Jain on 6/4/14.
//  Copyright (c) 2014 pjain. All rights reserved.
//

#import "IPLoginViewController.h"

@interface IPLoginViewController ()

@end

@implementation IPLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissKeyboard:(id)sender
{
    [self.view endEditing:YES];
}

@end
