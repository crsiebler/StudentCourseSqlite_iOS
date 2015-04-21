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

#import "StudentTableViewController.h"
#import "StudentViewController.h"

@interface StudentTableViewController ()

@property (strong, nonatomic) NSString * query;
@property (strong, nonatomic) CourseDBManager * crsDB;

@property (strong, nonatomic) IBOutlet UITableView *studentTV;

- (IBAction)removeCourse:(id)sender;

@end

@implementation StudentTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.studentTV.dataSource = self;
    self.query = [NSString stringWithFormat:@"SELECT name FROM student,studenttakes,course WHERE course.coursename = '%@' AND course.courseid = studenttakes.courseid AND student.studentid = studenttakes.studentid;",self.selectedCourse];
    self.crsDB = [[CourseDBManager alloc] initDatabaseName:@"coursedb"];
    self.navigationItem.title = [self.selectedCourse stringByAppendingString:@" - Students"];
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
    NSArray * queryRes = [self.crsDB executeQuery:self.query];
    return queryRes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"studentTVCell" forIndexPath:indexPath];
    
    NSArray * queryRes = [self.crsDB executeQuery:self.query];
    NSString * whichStud = @"unknown";
    
    if (queryRes.count > indexPath.row) {
        whichStud = queryRes[indexPath.row][0];
    }
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: @"studentTVCell"];
    }
    
    cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = whichStud;
    return cell;
}

// Deletes a course from the database
- (IBAction)removeCourse:(id)sender {
    NSLog(@"DELETING: %@", self.selectedCourse);
    
    NSInteger courseId;
    NSString *courseIdQuery = [NSString stringWithFormat:@"SELECT courseid FROM course WHERE coursename LIKE '%@'", self.selectedCourse];
    
    NSArray *queryRes = [self.crsDB executeQuery:courseIdQuery];
    
    if (queryRes.count > 0) {
        courseId = [queryRes[0][0] integerValue];
        
        NSString *delete = [NSString stringWithFormat:@"DELETE FROM course WHERE courseid = %ld", (long)courseId];
        NSString *deleteRegistrarQuery = [NSString stringWithFormat:@"DELETE FROM studenttakes WHERE courseid = %ld;", (long)courseId];
    
        if ([self.crsDB executeUpdate:deleteRegistrarQuery] && [self.crsDB executeUpdate:delete]) {
            NSLog(@"SUCCESS: Course deleted");
        } else {
            NSLog(@"ERROR: Could not delete course");
        }
    } else {
        NSLog(@"ERROR: Could not retrieve Course ID");
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"editStudent"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSArray * queryRes = [self.crsDB executeQuery:self.query];
        NSString * whichCrs = @"unknown";
        
        if (queryRes.count > indexPath.row) {
            whichCrs = queryRes[indexPath.row][0];
        }
        
        StudentViewController *destViewController = segue.destinationViewController;
        NSLog(@"prepareForSeque setting course to %@",whichCrs);
        destViewController.parent = self;
        destViewController.selectedStudent = whichCrs;
        destViewController.isEdit = YES;
    } else if ([segue.identifier isEqualToString:@"addStudent"]) {
        StudentViewController *destViewController = segue.destinationViewController;
        destViewController.parent = self;
        destViewController.selectedStudent = nil;
        destViewController.isEdit = NO;
    }
}

@end
