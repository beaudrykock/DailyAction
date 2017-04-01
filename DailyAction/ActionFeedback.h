//
//  ActionFeedback.h
//  DailyAction
//
//  Created by Beaudry Kock on 3/31/17.
//  Copyright © 2017 Beaudry Kock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpportunityDataManager.h"

@protocol ActionFeedbackDelegate <NSObject>

- (void)provideFeedbackWithIndex:(NSInteger) index;

@end

@interface ActionFeedback : UIView

@property (nonatomic, strong) IBOutlet UIImageView *feedback_0;
@property (nonatomic, strong) IBOutlet UIImageView *feedback_1;
@property (nonatomic, strong) IBOutlet UIImageView *feedback_2;
@property (nonatomic, strong) IBOutlet UIImageView *feedback_3;
@property (nonatomic, strong) IBOutlet UIImageView *feedback_4;
@property (nonatomic, strong) IBOutlet UIView *titleContainer;
@property (nonatomic, strong) IBOutlet UIView *mainContainer;
@property (nonatomic, strong) IBOutlet UILabel *lb_title;
@property (nonatomic, assign) id delegate;
- (void)setupWithOpportunity:(Opportunity*)opportunity;

@end
