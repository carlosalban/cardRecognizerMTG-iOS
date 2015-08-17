//
//  rightVC.m
//  MTG Recognizer
//
//  Created by Omega Tango - Carlos on 2/14/15.
//  Copyright (c) 2015 Omega Tango. All rights reserved.
//

#import "rightVC.h"

@interface rightVC ()

@end

@implementation rightVC{
    
    
    NSUInteger maxScansInt;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.maxCards = 10;
    self.maxCardStepper.userInteractionEnabled = YES;
    self.maxCardStepper.minimumValue = 10;
    self.maxCardStepper.maximumValue = 30;
    self.maxCardStepper.stepValue = 1;
    
    self.scrollView.contentInset = UIEdgeInsetsZero;

}

-(void)viewDidLayoutSubviews{
    
}


- (IBAction)stepperPressed:(UIStepper *)sender{
    
    //NSLog(@"Stepper pressed!");
    self.maxCards = sender.value;
    self.maxCardLabel.text = [NSString stringWithFormat:@"%lu", self.maxCards];
    
    //update cardCount
        NSUserDefaults *cardScans = [NSUserDefaults standardUserDefaults];
        [cardScans setInteger:self.maxCards forKey:@"selectedMax"];
        [cardScans synchronize];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
