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
    
    if (opportunity.actedOn)
        self.iv_actedOn.hidden = NO;
    else
        self.iv_actedOn.hidden = YES;
    
    Action *action = [[OpportunityDataManager sharedInstance] actionForOpportunityWithID:opportunity.opportunityID];
    
    self.actionType = action.actionType;
    
    if (action.actionType.integerValue == K_EMAIL_ACTION_TYPE)
    {
        EmailAction *emailAction = [[OpportunityDataManager sharedInstance] emailActionForActionWithID:action.actionID];
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"E-mail %@", emailAction.emailName]];
        NSRange selectedRange = NSMakeRange(7, emailAction.emailName.length); // 4 characters, starting at index 22
        
        [string beginEditing];
        
        [string addAttribute:NSFontAttributeName
                       value:[UIFont fontWithName:@"Avenir-Heavy" size:18.0]
                       range:selectedRange];
        
        [string addAttribute:NSForegroundColorAttributeName
                       value:[UIColor blackColor]
                       range:NSMakeRange(0, string.length)];
        
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

- (IBAction)takeAction:(id)sender
{
    // get the action
    Action *action = [[OpportunityDataManager sharedInstance] actionForOpportunityWithID:self.opportunityID];
   
    switch (self.actionType.integerValue) {
        case K_EMAIL_ACTION_TYPE:
            if (![MFMailComposeViewController canSendMail]) {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
                 hud.label.text = @"Please set up e-mail";
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    // Do something...
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUDForView:self animated:YES];
                    });
                });
                return;
            }
            else
            {
                // get the subaction
                EmailAction *emailAction = [[OpportunityDataManager sharedInstance] emailActionForActionWithID:action.actionID];
                
                MFMailComposeViewController* composeVC = [[MFMailComposeViewController alloc] init];
                composeVC.mailComposeDelegate = _parentController;
                
                // Configure the fields of the interface.
                [composeVC setToRecipients:@[emailAction.emailAddress]];
                [composeVC setSubject:@"Hear me roar"];
                [composeVC setMessageBody:emailAction.emailScript isHTML:NO];
                
                // Present the view controller modally.
                [_parentController presentViewController:composeVC animated:YES completion:nil];
            }
            break;
            
        case K_PHONE_ACTION_TYPE:
        {
            // get the subaction
            PhoneAction *phoneAction = [[OpportunityDataManager sharedInstance] phoneActionForActionWithID:action.actionID];
            
            NSURL *phoneUrl = [NSURL URLWithString:[@"telprompt://" stringByAppendingString:phoneAction.phoneNumber]];
            NSURL *phoneFallbackUrl = [NSURL URLWithString:[@"tel://" stringByAppendingString:phoneAction.phoneNumber]];
            
            if ([UIApplication.sharedApplication canOpenURL:phoneUrl]) {
                [UIApplication.sharedApplication openURL:phoneUrl options:@{} completionHandler:^(BOOL success) {
                    
                }];
            } else if ([UIApplication.sharedApplication canOpenURL:phoneFallbackUrl]) {
                [UIApplication.sharedApplication openURL:phoneFallbackUrl options:@{} completionHandler:^(BOOL success) {
                    
                }];
            } else {
                // device cannot do phone calls
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
                hud.label.text = @"Phone functions not available on your device";
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    // Do something...
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUDForView:self animated:YES];
                    });
                });

            }
        }
            break;
        default:
            break;
    }
}

@end
