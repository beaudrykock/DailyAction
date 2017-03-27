//
//  CallScript.m
//  DailyAction
//
//  Created by Beaudry Kock on 3/26/17.
//  Copyright © 2017 Beaudry Kock. All rights reserved.
//

#import "CallScript.h"
#import <QuartzCore/QuartzCore.h>

@implementation CallScript

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)parameterizeWithOpportunity:(Opportunity*)opportunity
{
    self.lb_actionTitle.layer.cornerRadius = 16;
    self.scriptContainer.layer.cornerRadius = 15;
    self.btn_takeAction.layer.cornerRadius = 15;
    
    self.opportunityID = opportunity.opportunityID;
    
    [self generateScript];
}

- (void)generateScript
{
    Action *action = [[OpportunityDataManager sharedInstance] actionForOpportunityWithID:self.opportunityID];
    self.actionType = action.actionType;
    
    if (action.actionType.integerValue == K_EMAIL_ACTION_TYPE)
    {
        // TODO if needed
    }
    else if (action.actionType.integerValue == K_PHONE_ACTION_TYPE)
    {
        PhoneAction *phoneAction = [[OpportunityDataManager sharedInstance] phoneActionForActionWithID:action.actionID];
        
        // check if name exists for user
        NSString *userFullName = [[UserDataManager sharedInstance] userFullName];
        
        // check if city exists for user
        NSString *city = [[UserDataManager sharedInstance] userCity];
        
        NSDictionary *linkAttributes = @{NSForegroundColorAttributeName: [UIColor greenColor],
                                         NSUnderlineColorAttributeName: [UIColor lightGrayColor],
                                         NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone)};
        
        NSString *nameText;
        NSString *cityText;
        
        if (userFullName.length==0)
        {
            nameText = @"[Tap to add your name]";
        }
        else if (userFullName.length>0)
        {
            nameText = userFullName;
        }
        cityText = city;
        
        NSString *text = [NSString stringWithFormat:@"Hi, my name is %@ and I'm a constituent from %@.\n\n%@\n\nThanks for your hard work answering the phones.", nameText, cityText, phoneAction.phoneScript];
        
        // create first link for adding name
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
        [attributedString addAttribute:NSLinkAttributeName
                                 value:@"newname://"
                                 range:[[attributedString string] rangeOfString:nameText]];
        
        [attributedString addAttribute:NSLinkAttributeName
                                 value:@"newcity://"
                                 range:[[attributedString string] rangeOfString:cityText]];
        
        self.tv_actionScript.linkTextAttributes = linkAttributes;
        self.tv_actionScript.attributedText = attributedString;
        self.tv_actionScript.delegate = self;
    }
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([[URL scheme] isEqualToString:@"newname"]) {
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"What's your name?"
                                              message:@"Enter your first and last name"
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
         {
             textField.placeholder = @"";
             [textField addTarget:self
                           action:@selector(alertTextFieldDidChange:)
                 forControlEvents:UIControlEventEditingChanged];
         }];
        
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:@"Cancel"
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action)
                                       {
                                           NSLog(@"Cancel action");
                                       }];
        
       self.okAction = [UIAlertAction
                 actionWithTitle:@"Update"
                 style:UIAlertActionStyleDefault
                 handler:^(UIAlertAction *action)
                 {
                     UITextField *name = alertController.textFields.firstObject;
                     
                     [[UserDataManager sharedInstance] updateUserFullName: name.text];
                     
                     [self generateScript];
                     
                 }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:self.okAction];
        self.okAction.enabled = NO;
        
        [self.parentController presentViewController:alertController animated:YES completion:nil];
        return NO;
    }
        return YES; // let the system open this URL
}

- (void)alertTextFieldDidChange:(UITextField *)sender
{
    UIAlertController *alertController = (UIAlertController *)((UIViewController*)self.parentController).presentedViewController;
    if (alertController)
    {
        UITextField *login = alertController.textFields.firstObject;
        
        if ([login.text rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]].location == NSNotFound && login.text.length >= 2)
        {
            self.okAction.enabled = YES;
        }
        else
        {
            self.okAction.enabled = NO;
        }
    }
}

@end
