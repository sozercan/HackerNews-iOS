//
//  JSONSerializable.h
//
//  Created by Sertac Ozercan on 2/13/13.
//  Copyright (c) 2013 Sertac Ozercan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JSONSerializable <NSObject>

- (void)readfromJSONDictionary:(NSDictionary*)d;

@end
