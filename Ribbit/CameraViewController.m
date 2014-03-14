//
//  CameraViewController.m
//  Ribbit
//
//  Created by Matthew Voracek on 3/11/14.
//  Copyright (c) 2014 Matthew Voracek. All rights reserved.
//

#import "CameraViewController.h"

@interface CameraViewController ()

@end

@implementation CameraViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pickerController = [UIImagePickerController new];
    self.pickerController.delegate = self;
    self.pickerController.allowsEditing = NO;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        self.pickerController.sourceType =UIImagePickerControllerSourceTypeCamera;
    }
    else
    {
        self.pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    self.pickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:self.pickerController.sourceType];
    [self presentViewController:self.pickerController animated:NO completion:nil];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

@end
