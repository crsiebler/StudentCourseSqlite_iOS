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

#import "CourseViewController.h"

@interface CourseViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameField;

@property (strong, nonatomic) CourseDBManager *crsDB;

@end

@implementation CourseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.crsDB = [[CourseDBManager alloc] initDatabaseName:@"coursedb"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Stores a new course in the database
- (IBAction)saveCourse:(id)sender {
    if (self.nameField.text && self.nameField.text.length > 0) {
        NSString *maxCourseIdQuery = [NSString stringWithFormat:@"SELECT MAX(courseid) FROM course;"];
        
        NSArray *queryRes = [self.crsDB executeQuery:maxCourseIdQuery];
        
        if (queryRes.count > 0) {
            NSInteger maxId = [queryRes[0][0] integerValue];
            NSString *addCourseQuery = [NSString stringWithFormat:@"INSERT INTO course VALUES ('%@', %ld);", self.nameField.text, ((long) maxId + 1)];
            
            if ([self.crsDB executeUpdate:addCourseQuery]) {
                NSLog(@"SUCCESS: Course added");
            } else {
                NSLog(@"ERROR: Course not added");
            }
        } else {
            NSLog(@"ERROR: Could not retrieve Max ID");
        }
    } else {
        NSLog(@"ERROR: Invalid Input");
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.nameField resignFirstResponder];
}

@end
