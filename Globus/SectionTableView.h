//
//  SectionTableView.h
//  Globus
//
//  Created by Patrik Oprandi on 28.03.12.
//  Copyright (c) 2012 youngculture AG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABTableView.h"


@protocol SectionTableViewDelegate;


@interface SectionTableView : ABTableView <UITableViewDelegate, UITableViewDataSource>
{
	IBOutlet id <SectionTableViewDelegate> __unsafe_unretained nextDelegate;
	NSArray *sectionArray;
}

@property (nonatomic, unsafe_unretained) id <SectionTableViewDelegate> nextDelegate;
@property (nonatomic, strong) NSArray *sectionArray;

@end


@protocol SectionTableViewDelegate <NSObject>

@optional
- (void)sectionTableView:(SectionTableView *)tableView didSelectRow:(NSDictionary *)theRowDictionary;
- (NSIndexPath *)sectionTableView:(SectionTableView *)tableView willSelectRow:(NSDictionary *)theRowDictionary indexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)sectionTableView:(SectionTableView *)tableView cellForRow:(NSDictionary *)theRowDictionary;
- (CGFloat)sectionTableView:(SectionTableView *)tableView heightForRow:(NSDictionary *)theRowDictionary;

@end
