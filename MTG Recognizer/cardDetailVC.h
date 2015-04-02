//
//  cardDetailVC.h
//  MTG Recognizer
//
//  Created by SDG - Carlos on 4/2/15.
//  Copyright (c) 2015 TTU Software Engineering. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface cardDetailVC : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *cardTitle;
@property (strong, nonatomic) IBOutlet UITextView *cardDetails;
@property (strong, nonatomic) IBOutlet UIImageView *cardImage;
- (IBAction)doneBtn:(id)sender;

@end
