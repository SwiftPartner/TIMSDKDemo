//
//  VideoMessageContent.h
//  TIMKitDemo
//
//  Created by ryan on 2019/10/29.
//  Copyright © 2019 windbird. All rights reserved.
//

#import "MessageContent.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoMessageContent : MessageContent

@property(assign, nonatomic) NSTimeInterval duration;

@property(assign, nonatomic) CGFloat width;
@property(assign, nonatomic) CGFloat height;
@property(copy, nonatomic) NSString *thumbnailKey;
@property(copy, nonatomic) NSString *thumbnailBucket;

@end

NS_ASSUME_NONNULL_END
