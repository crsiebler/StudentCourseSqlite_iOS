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

#import <Foundation/Foundation.h>

@interface CourseDBManager : NSObject

@property (strong, nonatomic) NSMutableArray * arrColNames;
@property (assign, nonatomic) int64_t lastInsertID;

- (id) initDatabaseName: (NSString *) dbName;

/**
 * method for executing insert, update, and delete statements.
 * The return value indicates whether the update was successful
 * The lastInsertID property is set when this method is called.
 */
- (BOOL) executeUpdate: (NSString *) query;

/**
 * method for executing select statements. The query must be a
 * select statement. The return value is an array of arrays
 * Subscriptig the return gives you the row, and subscripting
 * the row gives you each column. For each column, the
 * property arrColumnNames contains, at the same index,
 * the name of the column.
 */
- (NSArray *) executeQuery: (NSString *) query;

@end
