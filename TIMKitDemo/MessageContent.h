//
//  MessageElement.h
//  TIMKitDemo
//
//  Created by ryan on 2019/10/17.
//  Copyright © 2019 windbird. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageType.h"

NS_ASSUME_NONNULL_BEGIN

@interface MessageContent : NSObject

@property(nonatomic, assign) MessageType type;


- (nullable instancetype)initWithJson:(NSString *)json;
- (nullable instancetype)initWithData:(NSData *)data;
- (NSString *)jsonString;
- (NSData *)jsonData;

@end

NS_ASSUME_NONNULL_END
