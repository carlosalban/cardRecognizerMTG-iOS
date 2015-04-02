//
//  PageContentViewController.h
//  MTG Recognizer
//
//  Created by SDG - Carlos on 2/14/15.
//  Copyright (c) 2015 TTU Software Engineering. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageContentViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property NSUInteger pageIndex; //current page number
@property NSString *titleText;
@property NSString *imageFile;


@end
