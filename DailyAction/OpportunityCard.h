//
//  OpportunityCard
//  DailyAction
//
//  Created by Beaudry Kock on 3/6/17.
//  Copyright © 2017 Beaudry Kock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Opportunity.h"
#import "OpportunityDataManager.h"
#import <MessageUI/MessageUI.h>
#import "MBProgressHUD.h"

@interface OpportunityCard : UIView 

@property (nonatomic, weak) id parentController;
@property (nonatomic, assign) NSNumber *actionType;
@property (nonatomic, assign) NSNumber *opportunityID;
@property (nonatomic, strong) IBOutlet UILabel *lb_actionsTaken;
@property (nonatomic, strong) IBOutlet UILabel *lb_criticality;
@property (nonatomic, strong) IBOutlet UILabel *lb_ease;
@property (nonatomic, strong) IBOutlet UILabel *actionTitle;
@property (nonatomic, strong) IBOutlet UITextView *text;
@property (nonatomic, strong) IBOutlet UIButton *btn_action;
@property (nonatomic, strong) IBOutlet UIView *inner_container;
@property (nonatomic, strong) IBOutlet UIView *dividingLine;

- (void)parameterizeWithOpportunity:(Opportunity*)opportunity;

@end
