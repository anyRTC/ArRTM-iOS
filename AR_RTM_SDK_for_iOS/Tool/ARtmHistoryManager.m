//
//  ARtmHistoryManager.m
//  AR_RTM_SDK_for_iOS
//
//  Created by 余生丶 on 2020/7/16.
//  Copyright © 2020 AR. All rights reserved.
//

#import "ARtmHistoryManager.h"
#import <FMDB/FMDB.h>

@implementation ARtmHistoryManager

static FMDatabase *_historydb;
static NSDate *_date;
+ (void)initialize{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"history.sqlite"];
    
    _historydb = [FMDatabase databaseWithPath:path];
    BOOL res = [_historydb open];
    
    if (res == NO) {
        NSLog(@"数据库打开失败");
    }
    [_historydb executeUpdate:@"CREATE TABLE IF NOT EXISTS t_history (id integer PRIMARY KEY, modelData text ,peerId text)"];
    [_historydb close];
}

+ (void)saveHistoryWithMainModel:(ARtmMessageModel *)model {
    ARtmMessageModel *messageModel = [ARtmHistoryManager geHistoryList:model.peerId];
    if (model.isOfflineMessage) {
        model.num = messageModel.num + 1;
    }
    [self removeHistoryData:model.peerId];
    BOOL open = [_historydb open];
    if (open) {
        NSData *modelData = [NSKeyedArchiver archivedDataWithRootObject:model];
        [_historydb executeUpdateWithFormat:@"INSERT INTO t_history(modelData,peerId) VALUES(%@,%@);",modelData,model.peerId];
        [_historydb close];
    }
}

+ (void)updateHistoyModel:(ARtmMessageModel *)model {
    BOOL open = [_historydb open];
    if (open) {
        NSData *modelData = [NSKeyedArchiver archivedDataWithRootObject:model];
        [_historydb executeUpdateWithFormat:@"UPDATE t_history SET modelData = %@ WHERE peerId = %@;",modelData,model.peerId];
        [_historydb close];
    }
}

+ (ARtmMessageModel *)geHistoryList:(NSString *)peerId {
    BOOL open = [_historydb open];
    ARtmMessageModel *messageModel;
    if (open) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM t_history WHERE peerId = %@;",peerId];
        FMResultSet *set = [_historydb executeQuery:sql];
        if (set) {
            while (set.next) {
                NSData *data = [set objectForColumnName:@"modelData"];
                messageModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            }
        }
        [_historydb close];
    }
    return messageModel;
}

+ (NSMutableArray *)getAllHistoryList{
    BOOL open = [_historydb open];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    if (open) {
        //降序
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM t_history order by id desc"];
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

+ (void)removeHistoryData:(NSString *)peerId{
    BOOL open = [_historydb open];
    if (open) {
        NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM t_history where peerId = '%@'",peerId];
        [_historydb executeUpdate:deleteSql];
        [_historydb close];
    }
}

+ (void)removeAllObject{
    BOOL open = [_historydb open];
    if (open) {
        [_historydb executeUpdate:@"DELETE FROM t_history"];
        [_historydb close];
    }
}

@end
