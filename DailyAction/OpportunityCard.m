//
//  OpportunityCard
//  DailyAction
//
//  Created by Beaudry Kock on 3/6/17.
//  Copyright © 2017 Beaudry Kock. All rights reserved.
//

#import "OpportunityCard.h"
#import <QuartzCore/QuartzCore.h>

@implementation OpportunityCard

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)parameterizeWithOpportunity:(Opportunity*)opportunity
{
    // TODO
    self.actionTitle.text = opportunity.title;
    [self.actionTitle sizeToFit];
    CGRect frame = self.actionTitle.frame;
    frame.size.width = frame.size.width+20.0;
    self.actionTitle.frame = frame;
    self.actionTitle.center = self.dividingLine.center;
    self.btn_action.layer.cornerRadius = 15.0;
    self.inner_container.layer.cornerRadius = 15.0;
    self.text.text = opportunity.detail;
    self.lb_criticality.text = [Utilities criticalityFromIndex:opportunity.criticality.integerValue];
    self.lb_ease.text = [Utilities easeFromIndex:opportunity.difficulty.integerValue];
    self.lb_actionsTaken.text = [NSString stringWithFormat:@"%u actions taken",arc4random_uniform(1000)];
    
    Action *action = [[OpportunityDataManager sharedInstance] actionForOpportunityWithID:opportunity.opportunityID];
    
    if (action.actionType.integerValue == K_EMAIL_ACTION_TYPE)
    {
        EmailAction *emailAction = [[OpportunityDataManager sharedInstance] emailActionForActionWithID:action.actionID];
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"E-mail %@", emailAction.emailName]];
        NSRange selectedRange = NSMakeRange(7, emailAction.emailName.length); // 4 characters, starting at index 22
        
        [string beginEditing];
        
        [string addAttribute:NSFontAttributeName
                       value:[UIFont fontWithName:@"Avenir-Heavy" size:18.0]
                       range:selectedRange];
        
        [string endEditing];
        
        [self.btn_action setAttributedTitle:string forState:UIControlStateNormal];
    }
    else if (action.actionType.integerValue == K_PHONE_ACTION_TYPE)
    {
        PhoneAction *phoneAction = [[OpportunityDataManager sharedInstance] phoneActionForActionWithID:action.actionID];
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Call %@", phoneAction.phoneName]];
        NSRange selectedRange = NSMakeRange(5, phoneAction.phoneName.length); // 4 characters, starting at index 22
        
        [string beginEditing];
        
        [string addAttribute:NSFontAttributeName
                       value:[UIFont fontWithName:@"Avenir-Heavy" size:18.0]
                       range:selectedRange];
        
        [string endEditing];

        
        [self.btn_action setAttributedTitle:string forState:UIControlStateNormal];
    }
}

@end
