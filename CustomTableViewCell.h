//
//  CustomTableViewCell.h
//  MTG Recognizer
//
//  Created by Omega Tango - Carlos on 2/19/15.
//  Copyright (c) 2015 TTU Software Engineering. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "leftVC.h"
#import "cardDetailVC.h"

@interface CustomTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UITextView *descriptionText;
@property (strong, nonatomic) IBOutlet UIImageView *imagePreview;


@end
