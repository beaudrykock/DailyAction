//
//  CallScript.h
//  DailyAction
//
//  Created by Beaudry Kock on 3/26/17.
//  Copyright © 2017 Beaudry Kock. All rights reserved.
//



#import <UIKit/UIKit.h>
#import "Opportunity.h"
#import "Constants.h"
#import "OpportunityDataManager.h"
#import "UserDataManager.h"

@protocol CallScriptDelegate <NSObject>

- (void)showCallScript;
- (void)cancelScript;
- (void)makeCall;
- (void)showUpdateNameModal;

@end

@interface CallScript : UIView <UITextViewDelegate>

@property (nonatomic, strong) IBOutlet UIView *titleContainer;
@property (nonatomic, strong) IBOutlet UIView *scriptContainer;
@property (nonatomic, strong) IBOutlet UILabel *lb_actionTitle;
@property (nonatomic, strong) IBOutlet UITextView *tv_actionScript;
@property (nonatomic, strong) IBOutlet UIButton *btn_takeAction;
@property (nonatomic, assign) NSNumber *actionType;
@property (nonatomic, assign) NSNumber *opportunityID;
@property (nonatomic, strong) UIAlertAction *okAction;
@property (nonatomic, assign) id delegate;

- (void)parameterizeWithOpportunity:(Opportunity*)opportunity;
- (void)generateScript;

@end
