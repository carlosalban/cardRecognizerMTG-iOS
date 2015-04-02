//
//  ViewController.h
//  MTG Recognizer
//
//  Created by SDG - Carlos on 2/14/15.
//  Copyright (c) 2015 TTU Software Engineering. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageContentViewController.h"

@interface ViewController : UIViewController <UIPageViewControllerDataSource>

- (IBAction)startWalkthrough:(id)sender;
@property (strong,nonatomic) UIPageViewController *pageViewController;
@property (strong,nonatomic) NSArray *pageTitles;
@property (strong,nonatomic) NSArray *pageImages;


@end

