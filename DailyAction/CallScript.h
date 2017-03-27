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

@interface CallScript : UIView <UITextViewDelegate>

@property (nonatomic, weak) id parentController;
@property (nonatomic, strong) IBOutlet UILabel *lb_actionTitle;
@property (nonatomic, strong) IBOutlet UITextView *tv_actionScript;
@property (nonatomic, strong) IBOutlet UIButton *btn_takeAction;
@property (nonatomic, assign) NSNumber *actionType;
@property (nonatomic, assign) NSNumber *opportunityID;
@property (nonatomic, strong) UIAlertAction *okAction;

@end
