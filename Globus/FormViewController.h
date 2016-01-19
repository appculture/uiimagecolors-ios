//
//  FormViewController.h
//
//  Copyright 2010 by youngculture AG, Zurich. All rights reserved.
//  Don't use, modify or redistribute the source or parts of it without prior permission of youngculture
//

#import <UIKit/UIKit.h>
#import "ABTableViewController.h"
#import "WebViewController.h"
#import "FormfieldCell.h"


@protocol FormViewControllerDelegate;


@interface FormViewController : ABTableViewController <FormfieldCellDelegate>
{
	IBOutlet id <FormViewControllerDelegate> __unsafe_unretained delegate;	

	NSDictionary *formDictionary;
	NSMutableDictionary *valueDictionary;
	NSArray *formfieldArray;

@private
	UIBarButtonItem *cancelButton;
	UIBarButtonItem *saveButton;

	IBOutlet FormViewController *formViewController;
	IBOutlet WebViewController *webViewController;
}

@property (nonatomic, unsafe_unretained) id <FormViewControllerDelegate> __unsafe_unretained delegate;
@property (nonatomic, readonly) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) NSDictionary *formDictionary;
@property (nonatomic, strong) NSArray *formfieldArray;
@property (nonatomic, strong) NSMutableDictionary *valueDictionary;

- (void)loadFormWithName:(NSString *)theFormName;
- (void)pushFormWithName:(NSString *)theFormName animated:(BOOL)animated;

- (void)focusForFormfieldName:(NSString *)theFormfieldName;
- (NSString *)nameOfFollowingFormfieldWithName:(NSString *)theFormfieldName;
- (NSIndexPath *)indexPathForFormfieldWithName:(NSString *)theFormfieldName;

- (void)reloadForm;
- (void)reloadFormAnimated;

- (void)saveAction;
- (void)cancelAction;

- (void)endEditing;

- (BOOL)hasMissingRequiredFormfields;

- (void)formfieldValuesClear;
- (NSString *)formName;
- (NSString *)formfieldValueForName:(NSString *)theName;
- (void)setFormfieldValue:(NSString *)theValue forName:(NSString *)theName;

- (NSString *)formViewController:(FormViewController *)theFormViewController titleForHeaderForFormfieldGroup:(NSDictionary *)formfieldGroupDictionary;
- (NSString *)formViewController:(FormViewController *)theFormViewController titleForFooterForFormfieldGroup:(NSDictionary *)formfieldGroupDictionary;
- (FormfieldCell *)formViewController:(FormViewController *)formViewController cellForFormfield:(NSDictionary *)formfieldDictionary;
- (BOOL)formViewController:(FormViewController *)formViewController shouldDisplayFormfieldGroup:(NSDictionary *)formfieldGroupDictionary;
- (BOOL)formViewController:(FormViewController *)formViewController shouldDisplayFormfield:(NSDictionary *)formfieldDictionary;
- (void)formViewController:(FormViewController *)formViewController didSelectRow:(NSDictionary *)formfieldDictionary;
- (BOOL)formViewControllerShouldCancel:(FormViewController *)formViewController;
- (BOOL)formViewControllerShouldSave:(FormViewController *)formViewController;

@end


@protocol FormViewControllerDelegate <NSObject>

@optional
- (void)formViewControllerDidSave:(FormViewController *)theFormViewController;
- (void)formViewControllerDidCancel:(FormViewController *)theFormViewController;

@end
