//
//  ImagesForCouponsJSONReader.h
//  Globus
//
//  Created by Patrik Oprandi on 08.05.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebserviceWithAuth.h"

@interface ImagesForCouponsJSONReader : WebserviceWithAuth <ABWebserviceDelegate>
{
@private
	int counter;
}
- (void)startLoadingImages:(NSMutableArray *)theImages;


@end
