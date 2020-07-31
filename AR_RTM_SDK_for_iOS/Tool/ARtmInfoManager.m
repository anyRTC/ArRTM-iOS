//
//  ARtmInfoManager.m
//  AR_RTM_SDK_for_iOS
//
//  Created by 余生丶 on 2020/7/16.
//  Copyright © 2020 AR. All rights reserved.
//

#import "ARtmInfoManager.h"
#import <FMDB/FMDB.h>

@implementation ARtmInfoManager

static FMDatabase *_historydb;
static NSDate *_date;
+ (void)initialize{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"info.sqlite"];
    
    _historydb = [FMDatabase databaseWithPath:path];
    BOOL res = [_historydb open];
    
    if (res == NO) {
        NSLog(@"数据库打开失败");
    }
    [_historydb executeUpdate:@"CREATE TABLE IF NOT EXISTS t_info (id integer PRIMARY KEY, modelData text ,peerId text)"];
    [_historydb close];
}

+ (void)saveMessageWithInfoModel:(ARtmMessageModel *)model {
    [ARtmHistoryManager saveHistoryWithMainModel:model];
    BOOL open = [_historydb open];
    if (open) {
        NSData *modelData = [NSKeyedArchiver archivedDataWithRootObject:model];
        [_historydb executeUpdateWithFormat:@"INSERT INTO t_info(modelData,peerId) VALUES(%@,%@);",modelData,model.peerId];
        [_historydb close];
    }
}

+ (NSMutableArray *)getMessageUidList:(NSString *)peerId {
    BOOL open = [_historydb open];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    if (open) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM t_info WHERE peerId = %@;",peerId];
        FMResultSet *set = [_historydb executeQuery:sql];
        if (set) {
            while (set.next) {
                NSData *data = [set objectForColumnName:@"modelData"];
                ARtmMessageModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                [arr addObject:model];
            }
        }
        [_historydb close];
    }
    return arr;
}

+ (void)removeMessageData:(NSString *)peerId {
    [ARtmHistoryManager removeHistoryData:peerId];
    BOOL open = [_historydb open];
    if (open) {
        NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM t_info where peerId = '%@'",peerId];
        [_historydb executeUpdate:deleteSql];
        [_historydb close];
    }
}

+ (void)removeAllObject {
    BOOL open = [_historydb open];
    [ARtmHistoryManager removeAllObject];
    if (open) {
        [_historydb executeUpdate:@"DELETE FROM t_info"];
        [_historydb close];
    }
}


@end
