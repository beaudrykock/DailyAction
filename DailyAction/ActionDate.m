//
//  ActionDate.m
//  DailyAction
//
//  Created by Beaudry Kock on 3/14/17.
//  Copyright © 2017 Beaudry Kock. All rights reserved.
//

#import "ActionDate.h"

@implementation ActionDate


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.date_container.layer.cornerRadius = 15.0;
    self.backgroundColor = [UIColor clearColor];
}


@end
