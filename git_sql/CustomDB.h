//
//  CustomDB.h
//  git_sql
//
//  Created by jaimin rami on 9/20/17.
//  Copyright © 2017 jaimin rami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface CustomDB : NSObject
{
    sqlite3 *personDB;
    NSString *dbPathString;
}
-(void)createWith:(NSString *)strFileName;
-(void)insertInToDB:(NSString*)strQuery;
-(NSArray *)selectFromDB:(NSString *)strQuery;
-(void)deleteFromDB:(NSString*)strQuery;
@end
