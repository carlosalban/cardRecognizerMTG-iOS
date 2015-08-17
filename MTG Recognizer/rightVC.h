//
//  rightVC.h
//  MTG Recognizer
//
//  Created by Omega Tango - Carlos on 2/14/15.
//  Copyright (c) 2015 Omega Tango. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageContentViewController.h"

@interface rightVC : PageContentViewController

@property (assign, nonatomic) NSUInteger maxCards;
@property (strong, nonatomic) IBOutlet UILabel *maxCardLabel;
@property (strong, nonatomic) IBOutlet UIStepper *maxCardStepper;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *contentView;


- (IBAction)stepperPressed:(UIStepper *)sender;



@end
