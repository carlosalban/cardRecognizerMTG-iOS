//
//  CustomTableViewCell.m
//  MTG Recognizer
//
//  Created by Omega Tango - Carlos on 2/19/15.
//  Copyright (c) 2015 Omega Tango. All rights reserved.
//

#import "CustomTableViewCell.h"

@implementation CustomTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [UIColor colorWithRed:199.0f/255.0 green:214.0f/255.0 blue:244.0f/255.0 alpha:0.3f];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    
}



@end
