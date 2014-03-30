//
//  TOViewController.m
//  TOWebViewControllerExample
//
//  Created by Tim Oliver on 6/05/13.
//  Copyright (c) 2013 Tim Oliver. All rights reserved.
//

#import "TOViewController.h"
#import "TOWebViewController.h"

#ifndef NSFoundationVersionNumber_iOS_6_1
    #define NSFoundationVersionNumber_iOS_6_1  993.00
#endif

/* Detect if we're running iOS 7.0 or higher */
#define MINIMAL_UI (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)

@interface TOViewController ()

@end

@implementation TOViewController

- (void)viewDidLoad
{
    self.title = @"Navigation Controller";
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.backgroundView = [UIView new];
    
    if (MINIMAL_UI) {
        self.view.backgroundColor = [UIColor whiteColor];
        self.tableView.backgroundView.backgroundColor = [UIColor whiteColor];
    }
    else {
        self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    }
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
}

#pragma mark - Table View Protocols -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tableCellIdentifier = @"TableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Present as Modal View Controller";
    }
    else {
        cell.textLabel.text = @"Push onto Navigation Controller";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        TOWebViewController *webViewController = [[TOWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://google.com/"]];
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:webViewController] animated:YES completion:nil];
    }
    else {
        TOWebViewController *webViewController = [[TOWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://apple.com/"]];
        [self.navigationController pushViewController:webViewController animated:YES];
    }
}

@end
