//
//  LinkFeedCell.m
//  Interview App
//
//  Created by Gautham Ilango on 10/01/15.
//  Copyright (c) 2015 Gautham Ilango. All rights reserved.
//

#import "LinkFeedCell.h"
#import <UIImageView+WebCache.h>

@interface LinkFeedCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *feedPostInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *fullPictureImageView;
@property (weak, nonatomic) IBOutlet UIImageView *fromUserImageView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;

@end
@implementation LinkFeedCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFeed:(Feed *)feed
{
    
    [self.fromUserImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",feed.from_id]]
                              placeholderImage:nil
                                       options:SDWebImageRefreshCached];
    self.messageLabel.numberOfLines = 5;
    self.nameLabel.text = feed.from;
    self.messageLabel.text = feed.message;
    NSTimeInterval timeInterval = [feed.created_time timeIntervalSinceNow];
    if (timeInterval<0) {
        timeInterval = timeInterval*-1;
    }
    NSString *feedPostInfo;
    double minutes = floorf(timeInterval/60.0);
    if (minutes < 2) {
        feedPostInfo = [NSString stringWithFormat:@"%.0f minute ago",minutes];
        
    }
    else
    {
        feedPostInfo = [NSString stringWithFormat:@"%.0f minutes ago",minutes];
        
    }
    if (minutes>59) {
        double hours = minutes/60.0;
        if (hours < 2) {
            feedPostInfo = [NSString stringWithFormat:@"%.0f hour ago",hours];
        }
        else
        {
            feedPostInfo = [NSString stringWithFormat:@"%.0f hours ago",hours];
        }
        
        if (hours>23.9) {
            double days = hours/24.0;
            if (days < 2) {
                feedPostInfo = [NSString stringWithFormat:@"%.0f day ago",days];
                
            }
            else
            {
                feedPostInfo = [NSString stringWithFormat:@"%.0f days ago",days];
                
            }
            if (days>10) {
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                
                
                NSDateComponents *presentDayComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
                NSDateComponents *feedCreatedDayComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:feed.created_time];
                if (presentDayComponents.year!=feedCreatedDayComponents.year) {
                    df.dateFormat = @"MMMM d, YYYY";
                }
                else
                {
                    df.dateFormat = @"MMMM d";
                }
                feedPostInfo = [df stringFromDate:feed.created_time];
            }
        }
    }
    
    self.descriptionLabel.numberOfLines = 5;
    self.captionLabel.numberOfLines = 5;
    
    self.descriptionLabel.text = feed.feed_description;
    self.captionLabel.text = feed.caption;
    
    feed.story = [feed.story stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@ ",feed.from] withString:@""];
    feed.story = [feed.story stringByReplacingOccurrencesOfString:@"." withString:@""];
    feed.story = [feed.story stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    
    
    self.feedPostInfoLabel.text = [NSString stringWithFormat:@"%@ %@",feed.story,feedPostInfo];
    
    [self.fullPictureImageView sd_setImageWithURL:[NSURL URLWithString:feed.picture]];
    self.fullPictureImageView.layer.cornerRadius = 5;
    self.fullPictureImageView.layer.masksToBounds = YES;
    
    self.fromUserImageView.layer.cornerRadius = 4;
    self.fromUserImageView.layer.masksToBounds = YES;
    
}


@end
