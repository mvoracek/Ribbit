//
//  FriendsViewController.h
//  Ribbit
//
//  Created by Matthew Voracek on 3/7/14.
//  Copyright (c) 2014 Matthew Voracek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FriendsViewController : UITableViewController

@property (nonatomic, strong) PFRelation *friendsRelation;
@property (nonatomic, strong) NSArray *friends;

-(BOOL)isFriend: (PFUser *)user;

@end
