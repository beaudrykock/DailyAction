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
    self.opportunityID = opportunity.opportunityID;
    
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
    
    BOOL actedOn = opportunity.actedOn;
    
    if (actedOn)
    {
        self.iv_actedOn.hidden = NO;
        self.btn_action.enabled = NO;
        
    }
    else
    {
        self.iv_actedOn.hidden = YES;
        self.btn_action.enabled = YES;
    }
    
    Action *action = [[OpportunityDataManager sharedInstance] actionForOpportunityWithID:opportunity.opportunityID];
    
    self.actionType = action.actionType;
    
    if (action.actionType.integerValue == K_EMAIL_ACTION_TYPE)
    {
        EmailAction *emailAction = [[OpportunityDataManager sharedInstance] emailActionForActionWithID:action.actionID];
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"E-mail %@", emailAction.emailName]];
        NSRange selectedRange = NSMakeRange(7, emailAction.emailName.length); // 4 characters, starting at index 22
        
        [string beginEditing];
        
        if (!actedOn)
        {
            [string addAttribute:NSFontAttributeName
                           value:[UIFont fontWithName:@"Avenir-Heavy" size:18.0]
                           range:selectedRange];
            
            [string addAttribute:NSForegroundColorAttributeName
                       value:[UIColor blackColor]
                       range:NSMakeRange(0, string.length)];
        }
        else
        {
            [string addAttribute:NSForegroundColorAttributeName
                           value:[UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0]
                           range:NSMakeRange(0, string.length)];
        }
        [string endEditing];
        
        [self.btn_action setAttributedTitle:string forState:UIControlStateNormal];
    }
    else if (action.actionType.integerValue == K_PHONE_ACTION_TYPE)
    {
        PhoneAction *phoneAction = [[OpportunityDataManager sharedInstance] phoneActionForActionWithID:action.actionID];
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Call %@", phoneAction.phoneName]];
        NSRange selectedRange = NSMakeRange(5, phoneAction.phoneName.length); // 4 characters, starting at index 22
        
        [string beginEditing];
        if (!actedOn)
        {
            [string addAttribute:NSFontAttributeName
                           value:[UIFont fontWithName:@"Avenir-Heavy" size:18.0]
                           range:selectedRange];
        }
        else
        {
            [string addAttribute:NSForegroundColorAttributeName
                           value:[UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0]
                           range:NSMakeRange(0, string.length)];
        }
        [string endEditing];

        
        [self.btn_action setAttributedTitle:string forState:UIControlStateNormal];
    }
    
    
}

- (IBAction)takeAction:(id)sender
{
    switch (self.actionType.integerValue) {
        case K_EMAIL_ACTION_TYPE:
            [self.delegate composeEmail];
            break;
            
        case K_PHONE_ACTION_TYPE:
        {
            [self.delegate showCallScript];
        }
            break;
        default:
            break;
    }
}

@end
