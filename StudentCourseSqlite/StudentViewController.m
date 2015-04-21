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

#import "StudentViewController.h"

@interface StudentViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *majorField;
@property (weak, nonatomic) IBOutlet UITextField *dropField;
@property (weak, nonatomic) IBOutlet UITextField *addField;

@property (strong, nonatomic) UIPickerView *dropPicker;
@property (strong, nonatomic) UIPickerView *addPicker;

@property (strong, nonatomic) NSString *query;
@property (strong, nonatomic) NSString *dropPickerQuery;
@property (strong, nonatomic) NSString *addPickerQuery;
@property (strong, nonatomic) CourseDBManager *crsDB;

@end

@implementation StudentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Student Details";
    
    self.crsDB = [[CourseDBManager alloc] initDatabaseName:@"coursedb"];
    
    self.query = [NSString stringWithFormat:@"SELECT email,major,studentid FROM student WHERE student.name LIKE '%@'", self.selectedStudent];

    self.dropPicker = [[UIPickerView alloc] init];
    self.addPicker = [[UIPickerView alloc] init];
    
    self.nameField.delegate = self;
    self.emailField.delegate = self;
    self.majorField.delegate = self;
    self.dropField.delegate = self;
    self.addField.delegate = self;
    self.dropPicker.delegate = self;
    self.addPicker.delegate = self;
    
    self.dropPicker.dataSource = self;
    self.addPicker.dataSource = self;
    
    self.dropField.inputView = self.dropPicker;
    self.addField.inputView = self.addPicker;
    
    NSArray *queryRes = [self.crsDB executeQuery:self.query];
    
    self.nameField.text = self.selectedStudent;
    
    if (queryRes.count > 0) {
        self.emailField.text = queryRes[0][0];
        self.majorField.text = queryRes[0][1];
        self.studentId = [queryRes[0][2] integerValue];
    }
    
    self.dropPickerQuery = [NSString stringWithFormat:@"SELECT coursename FROM course WHERE course.courseid IN (SELECT studenttakes.courseid FROM studenttakes WHERE studenttakes.studentid = %ld);", (long)self.studentId];
    self.addPickerQuery = [NSString stringWithFormat:@"SELECT coursename FROM course WHERE course.courseid NOT IN (SELECT studenttakes.courseid FROM studenttakes WHERE studenttakes.studentid = %ld);", (long)self.studentId];
    
    [self reloadComponents];
}

- (void)reloadComponents {
    self.dropPickerQuery = [NSString stringWithFormat:@"SELECT coursename FROM course WHERE course.courseid IN (SELECT studenttakes.courseid FROM studenttakes WHERE studenttakes.studentid = %ld);", (long)self.studentId];
    self.addPickerQuery = [NSString stringWithFormat:@"SELECT coursename FROM course WHERE course.courseid NOT IN (SELECT studenttakes.courseid FROM studenttakes WHERE studenttakes.studentid = %ld);", (long)self.studentId];
    
    [self.addPicker reloadAllComponents];
    [self.dropPicker reloadAllComponents];
    [self.dropPicker selectRow:0 inComponent:0 animated:NO];
    [self.addPicker selectRow:0 inComponent:0 animated:NO];
    
    NSArray *queryRes;
    
    queryRes = [self.crsDB executeQuery:self.addPickerQuery];
    
    if (queryRes.count > 0) {
        self.addField.text = queryRes[0][0];
        [self.addField resignFirstResponder];
    } else {
        self.addField.text = @"";
    }
    
    queryRes = [self.crsDB executeQuery:self.dropPickerQuery];
    
    if (queryRes.count > 0) {
        self.dropField.text = queryRes[0][0];
        [self.dropField resignFirstResponder];
    } else {
        self.dropField.text = @"";
    }
}

- (void)clearInputs {
    self.nameField.text = @"";
    self.emailField.text = @"";
    self.majorField.text = @"";
    [self reloadComponents];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addCourse:(id)sender {
    NSLog(@"Add Course called");
    
    if (self.addField.text && self.addField.text.length > 0 && self.isEdit) {
        NSInteger courseId;
        NSString *courseIdQuery = [NSString stringWithFormat:@"SELECT courseid FROM course WHERE coursename LIKE '%@'", self.addField.text];
        
        NSArray *queryRes = [self.crsDB executeQuery:courseIdQuery];
        
        if (queryRes.count > 0) {
            courseId = [queryRes[0][0] integerValue];
            NSString *addCourseQuery = [NSString stringWithFormat:@"INSERT INTO studenttakes VALUES (%ld,%ld);", (long)self.studentId, (long)courseId];
            
            if ([self.crsDB executeUpdate:addCourseQuery]) {
                NSLog(@"SUCCESS: Course Added");
                [self reloadComponents];
            } else {
                NSLog(@"ERROR: Course not added");
            }
        } else {
            NSLog(@"ERROR: Could not find course (%@)", self.addField.text);
        }
    } else {
        NSLog(@"ERROR: Invalid input");
    }
}

- (IBAction)dropCourse:(id)sender {
    NSLog(@"Drop Course called");
    
    if (self.dropField.text && self.dropField.text.length > 0 && self.isEdit) {
        NSInteger courseId;
        NSString *courseIdQuery = [NSString stringWithFormat:@"SELECT courseid FROM course WHERE coursename LIKE '%@';", self.dropField.text];
        
        NSArray *queryRes = [self.crsDB executeQuery:courseIdQuery];
        
        if (queryRes.count > 0) {
            courseId = [queryRes[0][0] integerValue];
            NSString *dropCourseQuery = [NSString stringWithFormat:@"DELETE FROM studenttakes WHERE studentid = %ld AND courseid = %ld;", (long)self.studentId, (long)courseId];
            
            if ([self.crsDB executeUpdate:dropCourseQuery]) {
                NSLog(@"SUCCESS: Course Dropped");
                [self reloadComponents];
            } else {
                NSLog(@"ERROR: Course not dropped");
            }
        } else {
            NSLog(@"ERROR: Could not find course (%@)", self.dropField.text);
        }
    } else {
        NSLog(@"ERROR: Invalid input");
    }
}

- (IBAction)saveStudent:(id)sender {
    NSLog(@"Save Student called");
    NSString *updateStudentQuery;
    
    if (self.isEdit) {
        NSLog(@"Updating student");
        updateStudentQuery = [NSString stringWithFormat:@"UPDATE student SET name = '%@', major = '%@', email = '%@' WHERE studentid = %ld;", self.nameField.text, self.majorField.text, self.emailField.text, (long)self.studentId];
    } else {
        NSLog(@"Inserting student");
        NSString *maxStudentIdQuery = [NSString stringWithFormat:@"SELECT MAX(studentid) FROM student;"];
        
        NSArray *queryRes = [self.crsDB executeQuery:maxStudentIdQuery];
        
        if (queryRes.count > 0) {
            NSInteger maxId = [queryRes[0][0] integerValue];
            updateStudentQuery = [NSString stringWithFormat:@"INSERT INTO student VALUES ('%@', '%@', '%@', %ld);", self.nameField.text, self.majorField.text, self.emailField.text, ((long) maxId + 1)];
        } else {
            NSLog(@"ERROR: Could not retrieve Max ID");
        }
    }
    
    if ([self.crsDB executeUpdate:updateStudentQuery]) {

        NSString *studentIdQuery = [NSString stringWithFormat:@"SELECT studentid FROM student WHERE name LIKE '%@';", self.nameField.text];
        NSArray *queryRes = [self.crsDB executeQuery:studentIdQuery];
        
        if (queryRes.count > 0) {
            self.isEdit = YES;
            self.studentId = [queryRes[0][0] integerValue];
            NSLog(@"SUCCESS: Student Updated (%ld)", (long)self.studentId);
        } else {
            NSLog(@"ERROR: Coult not find Student after insert");
        }
    } else {
        NSLog(@"ERROR: Student not updated (%ld)", (long)self.studentId);
    }
}

- (IBAction)deleteStudent:(id)sender {
    NSLog(@"Delete Student called");
    
    NSString *deleteRegistrarQuery = [NSString stringWithFormat:@"DELETE FROM studenttakes WHERE studentid = %ld;", (long)self.studentId];
    NSString *deleteStudentQuery = [NSString stringWithFormat:@"DELETE FROM student WHERE studentid = %ld;", (long)self.studentId];
    
    if ([self.crsDB executeUpdate:deleteRegistrarQuery] && [self.crsDB executeUpdate:deleteStudentQuery]) {
        NSLog(@"SUCCESS: Student Deleted");
        [self clearInputs];
    } else {
        NSLog(@"ERROR: Student not deleted");
    }
}

- (IBAction)selectContacts:(id)sender {
    NSLog(@"Select from Contacts called");
    ABPeoplePickerNavigationController *picker =
    [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person {
    NSLog(@"ACCESSING: Person information");
    NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
    
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    
    if (ABMultiValueGetCount(emails) > 0) {
        NSString *email = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(emails, 0);
        
        self.emailField.text = email;
        
        CFRelease(emails);
    }
    
    self.nameField.text = fullName;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    [self dismissViewControllerAnimated:YES completion:nil];
    return NO;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSArray *queryRes;
    
    if (pickerView == self.dropPicker) {
        queryRes = [self.crsDB executeQuery:self.dropPickerQuery];
        if (row < queryRes.count) {
            self.dropField.text = queryRes[row][0];
            [self.dropField resignFirstResponder];
        }
    } else {
        queryRes = [self.crsDB executeQuery:self.addPickerQuery];
        if (row < queryRes.count) {
            self.addField.text = queryRes[row][0];
            [self.addField resignFirstResponder];
        }
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSArray *queryRes;
    NSString *result = @"Unknown";
    
    if (pickerView == self.dropPicker) {
        queryRes = [self.crsDB executeQuery:self.dropPickerQuery];
    } else {
        queryRes = [self.crsDB executeQuery:self.addPickerQuery];
    }
    
    if (row < queryRes.count) {
        result = queryRes[row][0];
    }
    
    return result;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSArray *queryRes;
    
    if (pickerView == self.dropPicker) {
        queryRes = [self.crsDB executeQuery:self.dropPickerQuery];
    } else {
        queryRes = [self.crsDB executeQuery:self.addPickerQuery];
    }
    
    return queryRes.count;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.nameField resignFirstResponder];
    [self.emailField resignFirstResponder];
    [self.majorField resignFirstResponder];
    [self.dropField resignFirstResponder];
    [self.addField resignFirstResponder];
}

@end
