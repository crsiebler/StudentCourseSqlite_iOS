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

#import "CourseDBManager.h"
#import "sqlite3.h"

@interface CourseDBManager()

@property (strong, nonatomic) NSString * documentsDirectory;
@property (strong, nonatomic) NSString * databaseFilename;
@property (strong, nonatomic) NSString * bundlePath;
@property (strong, nonatomic) NSMutableArray * arrResults;

@end

@implementation CourseDBManager

- (id) initDatabaseName:(NSString *) dbName {
    if (self = [super init]) {
        self.bundlePath = [[NSBundle mainBundle] pathForResource: dbName ofType:@"db"];
        // Set the documents directory path to the documentsDirectory property.
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.documentsDirectory = [paths objectAtIndex:0];
        self.databaseFilename = [dbName stringByAppendingString:@".db"];
        [self copyDatabaseIntoDocumentsDirectory];
    }
    
    return self;
}

// So the database can be modified, when the app is first installed, copy the db from the bundle to Documents
-(void)copyDatabaseIntoDocumentsDirectory{
    // Check whether the database file exists in the documents directory.
    NSString *destinationPath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];
    
//    NSLog(@"%@", destinationPath);
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        // The database file does not exist in the documents directory, so copy it from the main bundle now.
        NSString * sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.databaseFilename];
        NSError * error;
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:destinationPath error:&error];
        
        if (error != nil) {
            NSLog(@"Error in copying database to documents directory: %@", [error localizedDescription]);
        } else {
            NSLog(@"Database copied to documents directory");
        }
    } else {
        NSLog(@"Database already exists in documents directory. No copy necessary.");
    }
}

// Perform a SELECT SQL statement
-(NSArray *)executeQuery:(NSString *)query {
    sqlite3 * sqlite3DB;
    self.arrResults = [[NSMutableArray alloc] init];
    self.arrColNames = [[NSMutableArray alloc] init];
    
    // Set the database file path.
    NSString * dbPath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];
    
    int openResult = sqlite3_open([dbPath UTF8String], &sqlite3DB);
    
    if (openResult == SQLITE_OK) {
        sqlite3_stmt *compiledStmt;
        int preparedStmt = sqlite3_prepare_v2(sqlite3DB, [query UTF8String], -1, &compiledStmt, NULL);
        
        if (preparedStmt == SQLITE_OK) {
            NSMutableArray * dataRow;
            
            // Loop through the results and add them to the results array row by row.
            while (sqlite3_step(compiledStmt) == SQLITE_ROW) {
                dataRow = [[NSMutableArray alloc] init];
                int totalColumns = sqlite3_column_count(compiledStmt);
                
                for (int i = 0; i < totalColumns; i++){
                    // Convert the column data to characters.
                    char * dataAsChars = (char *)sqlite3_column_text(compiledStmt, i);
                    
                    if (dataAsChars != NULL) {
                        [dataRow addObject:[NSString  stringWithUTF8String:dataAsChars]];
                    }
                    
                    if (self.arrColNames.count != totalColumns) {
                        dataAsChars = (char *)sqlite3_column_name(compiledStmt, i);
                        [self.arrColNames addObject:[NSString stringWithUTF8String:dataAsChars]];
                    }
                }
                
                if (dataRow.count > 0) {
                    [self.arrResults addObject: dataRow];
                    //NSLog(@"adding %@ to result",arrDataRow);
                }
            }
        } else {
            NSLog(@"Error in preparing SQL query: %s", sqlite3_errmsg(sqlite3DB));
        }
        
        sqlite3_finalize(compiledStmt);
    }
    
    sqlite3_close(sqlite3DB);
    
    return self.arrResults;
}

// Perform an INSERT, DELETE, or UPDATE SQL statement
-(BOOL)executeUpdate:(NSString *)query {
    BOOL ret = NO;
    sqlite3 * sqlite3DB;

    // Set the database file path.
    NSString * dbPath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFilename];

    int openResult = sqlite3_open([dbPath UTF8String], &sqlite3DB);
    
    if (openResult == SQLITE_OK) {
        sqlite3_stmt *compiledStmt;
        int preparedStmt = sqlite3_prepare_v2(sqlite3DB, [query UTF8String], -1, &compiledStmt, NULL);
        
        if (preparedStmt == SQLITE_OK) {
            if (sqlite3_step(compiledStmt) == SQLITE_DONE) {
                ret = YES;
            }
        }
        
        sqlite3_finalize(compiledStmt);
    }
    
    sqlite3_close(sqlite3DB);
    
    return ret;
}

@end
