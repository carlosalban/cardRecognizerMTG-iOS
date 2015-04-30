//
//  rightVC.m
//  MTG Recognizer
//
//  Created by Omega Tango - Carlos on 2/14/15.
//  Copyright (c) 2015 TTU Software Engineering. All rights reserved.
//

#import "rightVC.h"

@interface rightVC ()

@end

@implementation rightVC{
    
    NSArray *pickerData;
    NSUInteger maxScansInt;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    pickerData = @[@"1", @"2", @"3", @"4", @"5", @"6",@"7",@"8",@"9",@"10"];
    self.maxScans.delegate = self;
    self.maxScans.dataSource = self;
    

}

-(void)viewWillAppear:(BOOL)animated{
    
    NSUserDefaults *cardScans = [NSUserDefaults standardUserDefaults];
    NSInteger maxScansSaved = [cardScans integerForKey:@"selectedMax"];
    maxScansInt = maxScansSaved;
    [self.maxScans selectRow:maxScansInt-1 inComponent:0 animated:NO];
}

// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [pickerData count];
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return pickerData[row];
}

// Catpure the picker view selection
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // This method is triggered whenever the user makes a change to the picker selection.
    // The parameter named row and component represents what was selected.
    NSUInteger value = [pickerView selectedRowInComponent:0];
    NSUInteger selectedMax = [[pickerData objectAtIndex:value] integerValue];
    NSLog(@"Selected max is %ld", selectedMax);
    
    NSUserDefaults *cardScans = [NSUserDefaults standardUserDefaults];
    [cardScans setInteger:selectedMax forKey:@"selectedMax"]; //update cardCount
    [cardScans synchronize];
    
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

@end
