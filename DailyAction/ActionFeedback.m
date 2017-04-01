//
//  ActionFeedback.m
//  DailyAction
//
//  Created by Beaudry Kock on 3/31/17.
//  Copyright © 2017 Beaudry Kock. All rights reserved.
//

#import "ActionFeedback.h"
#import <QuartzCore/QuartzCore.h>

@implementation ActionFeedback

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)setupWithOpportunity:(Opportunity*)opportunity
{
    self.titleContainer.layer.cornerRadius = 17.0;
    self.mainContainer.layer.cornerRadius = 15.0;
    
    Action *action = [[OpportunityDataManager sharedInstance] actionForOpportunityWithID:opportunity.opportunityID];
    
    if (action.actionType.integerValue == K_EMAIL_ACTION_TYPE)
    {
        EmailAction *emailAction = [[OpportunityDataManager sharedInstance] emailActionForActionWithID:action.actionID];
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"E-mail %@", emailAction.emailName]];
        NSRange selectedRange = NSMakeRange(7, emailAction.emailName.length); // 4 characters, starting at index 22
        
        [string beginEditing];
        
        
        [string addAttribute:NSFontAttributeName
                       value:[UIFont fontWithName:@"Avenir-Heavy" size:15.0]
                       range:selectedRange];
        
        [string addAttribute:NSForegroundColorAttributeName
                       value:[UIColor blackColor]
                       range:NSMakeRange(0, string.length)];
        
        [string endEditing];
        
        [self.lb_title setAttributedText:string];
    }
    else if (action.actionType.integerValue == K_PHONE_ACTION_TYPE)
    {
        PhoneAction *phoneAction = [[OpportunityDataManager sharedInstance] phoneActionForActionWithID:action.actionID];
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Call %@", phoneAction.phoneName]];
        NSRange selectedRange = NSMakeRange(5, phoneAction.phoneName.length); // 4 characters, starting at index 22
        
        [string beginEditing];
       [string addAttribute:NSFontAttributeName
                           value:[UIFont fontWithName:@"Avenir-Heavy" size:15.0]
                           range:selectedRange];
       [string endEditing];
        
        
        [self.lb_title setAttributedText:string];
    }
    
    UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedFeedback:)];
    [singleTap setNumberOfTapsRequired:1];
    
    self.feedback_0.tag = 0;
    [self.feedback_0 addGestureRecognizer:singleTap];
    self.feedback_1.tag = 1;
    [self.feedback_1 addGestureRecognizer:singleTap];
    self.feedback_2.tag = 2;
    [self.feedback_2 addGestureRecognizer:singleTap];
    self.feedback_3.tag = 3;
    [self.feedback_3 addGestureRecognizer:singleTap];
    self.feedback_4.tag = 4;
    [self.feedback_4 addGestureRecognizer:singleTap];
}

- (void)tappedFeedback:(UIGestureRecognizer*)recognizer
{
    UIImageView *tappedView  = (UIImageView*) recognizer.view;
    
    [tappedView setHighlighted:YES];
    
    [self.delegate provideFeedbackWithIndex:tappedView.tag];
}

@end
