//
//  StoreTableView.h
//  Globus
//
//  Created by Patrik Oprandi on 18.05.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import <UIKit/UIKit.h>


@class Store;

@protocol StoreTableViewDelegate;


@interface StoreTableView : UITableView <UITableViewDelegate, UITableViewDataSource>
{
	IBOutlet id <StoreTableViewDelegate> __unsafe_unretained nextDelegate;
	NSArray *sectionArray;
	NSArray *indexArray;
}

@property (nonatomic, unsafe_unretained) id <StoreTableViewDelegate> nextDelegate;
@property (nonatomic, strong) NSArray *sectionArray;
@property (nonatomic, strong) NSArray *indexArray;

@end


@protocol StoreTableViewDelegate <NSObject>

@optional
- (void)storeTableView:(StoreTableView *)tableView didSelectStore:(Store *)theStore;

@end
