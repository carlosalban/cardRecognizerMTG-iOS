//
//  leftVC.h
//  MTG Recognizer
//
//  Created by Omega Tango - Carlos on 2/19/15.
//  Copyright (c) 2015 Omega Tango. All rights reserved.
//

#import "PageContentViewController.h"
#import "cardDetailVC.h"

@interface leftVC : PageContentViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;




@end
