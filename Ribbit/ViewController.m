//
//  ViewController.m
//  Ribbit
//
//  Created by Matthew Voracek on 3/3/14.
//  Copyright (c) 2014 Matthew Voracek. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    _items = [NSMutableArray arrayWithObjects:@"A", @"B", nil];
    [super viewDidLoad];
    
    NSArray *tabBarItems = self.tabBarController.tabBar.items;
    self.tabBarController.selectedIndex = 2;
    UITabBarItem *tab = [tabBarItems objectAtIndex:2];
    tab.badgeValue = @"3";
    
}



@end
