//
//  cardDetailVC.m
//  MTG Recognizer
//
//  Created by Omega Tango - Carlos on 4/2/15.
//  Copyright (c) 2015 TTU Software Engineering. All rights reserved.
//

#import "cardDetailVC.h"

@interface cardDetailVC ()

@end

@implementation cardDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[self.cardTitle setText:[self cardTitle]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)doneBtn:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
