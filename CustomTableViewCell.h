//
//  CustomTableViewCell.h
//  MTG Recognizer
//
//  Created by SDG - Carlos on 2/19/15.
//  Copyright (c) 2015 TTU Software Engineering. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "leftVC.h"

@interface CustomTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end
