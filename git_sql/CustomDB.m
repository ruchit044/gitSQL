//
//  CustomDB.m
//  git_sql
//
//  Created by jaimin rami on 9/20/17.
//  Copyright © 2017 jaimin rami. All rights reserved.
//

#import "CustomDB.h"

@implementation CustomDB

- (void)createWith:(NSString *)strFileName;
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [path objectAtIndex:0];
    
    dbPathString = [docPath stringByAppendingPathComponent:strFileName];
    NSLog(@"%@",dbPathString);
    char *error;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:dbPathString]) {
        const char *dbPath = [dbPathString UTF8String];
        
        //creat db here
        if (sqlite3_open(dbPath, &personDB)==SQLITE_OK) {
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS PERSONS (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, AGE INTEGER)";
            sqlite3_exec(personDB, sql_stmt, NULL, NULL, &error);
            sqlite3_close(personDB);
        }
    }
}
-(void)insertInToDB:(NSString *)strQuery{
    char *error;
    if (sqlite3_open([dbPathString UTF8String], &personDB)==SQLITE_OK) {
        NSString *inserStmt = [NSString stringWithFormat:@"%@", strQuery];
        const char *insert_stmt = [inserStmt UTF8String];
        
        if (sqlite3_exec(personDB, insert_stmt, NULL, NULL, &error)==SQLITE_OK) {
            NSLog(@"Insert successfully");
        }
        sqlite3_close(personDB);
    }
    
    
    
}
-(NSArray *)selectFromDB:(NSString *)strQuery{
    sqlite3_stmt *statement;
    id result;
    NSMutableArray *thisArray = [[NSMutableArray alloc]init];
    
    if (sqlite3_open([dbPathString UTF8String], &personDB)==SQLITE_OK) {
        
        NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM PERSONS"];
        const char* query_sql = [querySql UTF8String];
        
        if (sqlite3_prepare(personDB, query_sql, -1, &statement, NULL)==SQLITE_OK) {
            while (sqlite3_step(statement)==SQLITE_ROW) {
                NSMutableDictionary *thisDict = [[NSMutableDictionary alloc]init];
                for (int i = 0 ; i < sqlite3_column_count(statement) ; i++) {
                    if(sqlite3_column_type(statement,i) == SQLITE_NULL){
                        continue;
                    }
                    if (sqlite3_column_decltype(statement,i) != NULL &&
                        strcasecmp(sqlite3_column_decltype(statement,i),"Boolean") == 0) {
                        result = [NSNumber numberWithBool:(BOOL)sqlite3_column_int(statement,i)];
                    } else if (sqlite3_column_type(statement,i) == SQLITE_INTEGER) {
                        result = [NSNumber numberWithInt:(int)sqlite3_column_int(statement,i)];
                    } else if (sqlite3_column_type(statement,i) == SQLITE_FLOAT) {
                        result = [NSNumber numberWithFloat:(float)sqlite3_column_double(statement,i)];
                    } else {
                        if((char *)sqlite3_column_text(statement,i) != NULL){
                            result = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement,i)];
                            [thisDict setObject:result
                                         forKey:[NSString stringWithUTF8String:sqlite3_column_name(statement,i)]];
                            result = nil;
                        }
                    }
                    if (result) {
                        [thisDict setObject:result
                                     forKey:[NSString stringWithUTF8String:sqlite3_column_name(statement,i)]];
                    }
                }
                [thisArray addObject:[NSDictionary dictionaryWithDictionary:thisDict]];
            }
        }
    }
    return thisArray;
}
-(void)deleteFromDB:(NSString *)strQuery{
    char *error;
    
    if (sqlite3_exec(personDB, [strQuery UTF8String], NULL, NULL, &error)==SQLITE_OK) {
        NSLog(@"Person deleted");
    }
}
@end

