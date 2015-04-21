/**
 * Copyright 2015 Cory Siebler
 * <p/>
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 * <p/>
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * <p/>
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * @author Cory Siebler csiebler@asu.edu
 * @version April 11, 2015
 */

#import "CourseTableViewController.h"
#import "StudentTableViewController.h"

@interface CourseTableViewController ()

@property (strong, nonatomic) IBOutlet UITableView *courseTableView;
@property (strong, nonatomic) CourseDBManager * crsDB;

@end

@implementation CourseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.courseTableView.dataSource = self;
    self.navigationItem.title = @"Courses";
    self.crsDB = [[CourseDBManager alloc] initDatabaseName:@"coursedb"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData]; // to reload selected cell
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray * queryRes = [self.crsDB executeQuery:@"SELECT coursename FROM course;"];
    return queryRes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"courseTVCell" forIndexPath:indexPath];
    
    NSArray * queryRes = [self.crsDB executeQuery:@"SELECT coursename FROM course;"];
    NSString * whichCrs = @"unknown";
    
    if (queryRes.count > indexPath.row) {
        whichCrs = queryRes[indexPath.row][0];
    }

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: @"courseTVCell"];
    }
    
    cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = whichCrs;
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showStudents"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSArray * queryRes = [self.crsDB executeQuery:@"SELECT coursename FROM course;"];
        NSString * whichCrs = @"unknown";
        
        if (queryRes.count > indexPath.row) {
            whichCrs = queryRes[indexPath.row][0];
        }
        
        StudentTableViewController *destViewController = segue.destinationViewController;
        NSLog(@"prepareForSeque setting course to %@",whichCrs);
        destViewController.parent = self;
        destViewController.selectedCourse = whichCrs;
    }
}

@end
