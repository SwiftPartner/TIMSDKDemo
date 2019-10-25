//
//  ImageMessageContent.m
//  TIMKitDemo
//
//  Created by ryan on 2019/10/25.
//  Copyright © 2019 windbird. All rights reserved.
//

#import "ImageMessageContent.h"

@implementation ImageMessageContent

+ (instancetype)contentWithImage:(UIImage *)image {
    ImageMessageContent *imageContent = [ImageMessageContent new];
    imageContent.image = image;
    imageContent.type = MessageTypeImage;
    imageContent.width = image.size.width;
    imageContent.height = image.size.height;
    return imageContent;
}

- (NSArray *)mj_ignoredPropertyNames {
    return @[@"image"];
}

@end
