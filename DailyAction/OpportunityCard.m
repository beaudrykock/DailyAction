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
    self.btn_action.layer.cornerRadius = 15.0;
    self.inner_container.layer.cornerRadius = 15.0;
}

@end
