//
//  PropertyCell.h
//  Globus
//
//  Created by Patrik Oprandi on 28.03.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kPropertyCellID;

@interface PropertyCell : UITableViewCell
{
}

@property (nonatomic, strong) NSString *icon;

+ (CGFloat)heightForType:(NSString *)typeString value:(NSString *)valueString accessory:(BOOL)hasAccessory;

@end
