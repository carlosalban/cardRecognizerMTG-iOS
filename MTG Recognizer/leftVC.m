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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    lastScans = @[@"Scan1",@"Scan2",@"Scan3"];
    lastScansDetails = @[@"detail1",@"detail2",@"detail3"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [lastScans count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellID = @"CustomCell";
    
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.titleLabel.text = [lastScans objectAtIndex:indexPath.row];
    cell.detailLabel.text = [lastScansDetails objectAtIndex:indexPath.row];
    return cell;
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
