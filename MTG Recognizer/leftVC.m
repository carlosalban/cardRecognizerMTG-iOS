//
//  leftVC.m
//  MTG Recognizer
//
//  Created by Omega Tango - Carlos on 2/19/15.
//  Copyright (c) 2015 TTU Software Engineering. All rights reserved.
//

#import "leftVC.h"
#import "CustomTableViewCell.h"

@interface leftVC ()

@end

@implementation leftVC{
    NSArray *lastScans;
    NSArray *lastScansDetails;
    NSUInteger maxScans;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //lastScans = @[@"Scan1",@"Scan2",@"Scan3"];
    //lastScansDetails = @[@"detail1",@"detail2",@"detail3"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    

}

-(void)viewWillAppear:(BOOL)animated{
    
    NSUserDefaults *cardScans = [NSUserDefaults standardUserDefaults];
    NSInteger maxScansSaved = [cardScans integerForKey:@"selectedMax"];
    maxScans = maxScansSaved;
    NSLog(@"Max scans is %ld", maxScans);
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated{
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSUserDefaults *cardScans = [NSUserDefaults standardUserDefaults];
    NSInteger cardCount = [cardScans integerForKey:@"cardIndex"];
    NSLog(@"Card count is %ld", cardCount);
    
    if (cardCount > maxScans){
        return maxScans;
    }
    else{
       return cardCount;
    }
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellID = @"CustomCell";
    NSLog(@"indexPath.row is %ld", indexPath.row+1);
    
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    
    NSUserDefaults *cardScans = [NSUserDefaults standardUserDefaults];
    NSInteger cardIndex = [cardScans integerForKey:@"cardIndex"];
    //for (int i = 0; i < cardIndex; i++) {
    NSData *data = [cardScans objectForKey:[NSString stringWithFormat:@"%ld", cardIndex - indexPath.row]];
    NSDictionary *jsonResults = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSLog(@"cardIndex is %ld Json Results are %@", cardIndex, jsonResults);
    
    cell.titleLabel.text = [jsonResults objectForKey:@"name"];
    cell.descriptionText.text = [jsonResults objectForKey:@"description"];
    cell.imagePreview.image = [jsonResults objectForKey:@"image"];

    //}
       return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
    NSUserDefaults *cardScans = [NSUserDefaults standardUserDefaults];
    NSInteger cardIndex = [cardScans integerForKey:@"cardIndex"];
    NSData *data = [cardScans objectForKey:[NSString stringWithFormat:@"%ld", cardIndex - indexPath.row]];
    NSDictionary *jsonResults = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSLog(@"JSON: %@", jsonResults);
    
    cardDetailVC *cardDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"cardDetailVC"];
    [cardDetailVC view];
    cardDetailVC.cardTitle.text = [jsonResults valueForKey:@"name"];
    cardDetailVC.cardDetails.text = [jsonResults valueForKey:@"description"];
    cardDetailVC.cardImage.image = [jsonResults valueForKey:@"image"];
    
    [self presentViewController:cardDetailVC animated:YES completion:nil];

}


-(void)viewDidLayoutSubviews{
    //CGFloat height = MIN(self.view.bounds.size.height, self.tablewView.contentSize.height);
    //self.
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
