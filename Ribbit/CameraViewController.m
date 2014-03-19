//
//  CameraViewController.m
//  Ribbit
//
//  Created by Matthew Voracek on 3/11/14.
//  Copyright (c) 2014 Matthew Voracek. All rights reserved.
//

#import "CameraViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface CameraViewController ()

@end

@implementation CameraViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.friendsRelation = [[PFUser currentUser] objectForKey:@"friendsRelation"];
    self.recepients = [NSMutableArray new];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    PFQuery *query = [self.friendsRelation query];
    [query orderByAscending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error)
         {
             NSLog(@"Error: %@ %@", error, [error userInfo]);
         }
         else
         {
             self.friends = objects;
             [self.tableView reloadData];
         }
     }];
    if (self.image == nil && [self.videoFilePath length] == 0)
    {
        self.pickerController = [UIImagePickerController new];
        self.pickerController.delegate = self;
        self.pickerController.allowsEditing = NO;
        self.pickerController.videoMaximumDuration = 10;
        
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
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    cell.textLabel.text = user.username;
    
    if ([self.recepients containsObject:user.objectId])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.recepients addObject:user.objectId];
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.recepients removeObject:user.objectId];

    }
}

#pragma mark - Image Picker Controller delegate

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.tabBarController setSelectedIndex:0];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        self.image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (self.pickerController.sourceType == UIImagePickerControllerSourceTypeCamera)
        {
            UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
        }
    }
    else
    {
        self.videoFilePath = (__bridge NSString *)([[info objectForKey:UIImagePickerControllerMediaURL] path]);
        if (self.pickerController.sourceType == UIImagePickerControllerSourceTypeCamera)
        {
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.videoFilePath))
            {
                UISaveVideoAtPathToSavedPhotosAlbum(self.videoFilePath, nil, nil, nil);
            }
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IBActions

- (IBAction)onCancelButtonPressed:(id)sender
{
    [self reset];
    
    [self.tabBarController setSelectedIndex:0];
}

- (IBAction)onSendButtonPressed:(id)sender
{
    if (self.image == nil && [self.videoFilePath length] == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Try Again!" message:@"Please select a file" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alertView show];
        [self presentViewController:self.pickerController animated:NO completion:nil];
    }
    else
    {
        [self uploadMessage];
        [self.tabBarController setSelectedIndex:0];
    }
}

#pragma mark - helper methods

-(void)reset
{
    self.image = nil;
    self.videoFilePath = nil;
    [self.recepients removeAllObjects];
}

-(void) uploadMessage
{
    NSData *fileData;
    NSString *fileName;
    NSString *fileType;
    
    if (self.image != nil )
    {
        UIImage *newImage = [self resizeImage:self.image toWidth:320.0f andHeight:480.0f];
        fileData = UIImagePNGRepresentation(newImage);
        fileName = @"image.png";
        fileType = @"image";
    }
    else
    {
        fileData = [NSData dataWithContentsOfFile:self.videoFilePath];
        fileName = @"video.mov";
        fileType = @"video";
    }
    
    PFFile *file = [PFFile fileWithName:fileName data:fileData];
    
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Please try sending your message again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            
            [alertView show];
        }
        else
        {
            PFObject *message = [PFObject objectWithClassName:@"Messages"];
            [message setObject:file forKey:@"file"];
            [message setObject:fileType forKey:@"fileType"];
            [message setObject:self.recepients forKey:@"recepientIds"];
            [message setObject:[[PFUser currentUser] objectId] forKey:@"senderId"];
            [message setObject:[[PFUser currentUser] username] forKey:@"senderName"];
            [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error)
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Please try sending your message again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    
                    [alertView show];
                }
                else
                {
                    //success
                    [self reset];
                }
            }];
        }
    }];
}

-(UIImage *)resizeImage:(UIImage *)image toWidth:(float)width andHeight:(float)height
{
    CGSize newSize = CGSizeMake(width, height);
    CGRect newRectangle = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContext(newSize);
    [self.image drawInRect:newRectangle];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

@end
