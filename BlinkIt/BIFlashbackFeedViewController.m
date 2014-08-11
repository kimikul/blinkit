//
//  BIFlashbackFeedViewController.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 8/10/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIFlashbackFeedViewController.h"

@interface BIFlashbackFeedViewController ()
@property (nonatomic, strong) NSDictionary *blinksDict;
@end

@implementation BIFlashbackFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - segmented control

- (void)segmentedControlChanged:(UISegmentedControl*)segmentedControl {
    NSInteger index = segmentedControl.selectedSegmentIndex;
    NSDate *date = self.flashbackDates[index];
    
    NSArray *currentBlinks = [self.blinksDict objectForKey:date];
    if (currentBlinks) {
        self.blinksArray = [NSMutableArray arrayWithObject:currentBlinks];
        self.dateArray = [NSMutableArray arrayWithObject:[NSDate spelledOutDate:date]];
    } else {
        self.blinksArray = nil;
        self.dateArray = nil;
    }
    
    [self reloadTableData];
}

- (void)fetchFlashbackFeed {
    NSDate *begOneMonthDate = self.flashbackDates[0];
    NSDate *endOneMonthDate = [NSDate endOfDay:self.flashbackDates[0]];
    NSDate *begThreeMonthsDate = self.flashbackDates[1];
    NSDate *endThreeMonthsDate = [NSDate endOfDay:self.flashbackDates[1]];
    NSDate *begSixMonthsDate = self.flashbackDates[2];
    NSDate *endSixMonthsDate = [NSDate endOfDay:self.flashbackDates[2]];
    NSDate *begOneYearDate = self.flashbackDates[3];
    NSDate *endOneYearDate = [NSDate endOfDay:self.flashbackDates[3]];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"((date >= %@) AND (date < %@)) OR ((date >= %@) AND (date < %@)) OR ((date >= %@) AND (date < %@)) OR ((date >= %@) AND (date < %@))",begOneMonthDate,endOneMonthDate,begThreeMonthsDate,endThreeMonthsDate,begSixMonthsDate,endSixMonthsDate,begOneYearDate,endOneYearDate];
    
    NSMutableArray *followedFriends = [[[BIDataStore shared] followedFriends] mutableCopy];
    NSString *myID = [[PFUser currentUser] objectForKey:@"facebookID"];
    if (myID) {
        [followedFriends addObject:myID];
    }
    
    PFQuery *followedUsers = [PFUser query];
    [followedUsers whereKey:@"facebookID" containedIn:followedFriends];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Blink" predicate:pred];
    [query whereKey:@"user" matchesQuery:followedUsers];
    [query whereKey:@"private" equalTo:@(NO)];
    [query includeKey:@"user"];
    [query orderByDescending:@"date"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableDictionary *newBlinksDict = [NSMutableDictionary new];
        for (PFObject *blink in objects) {
            NSDate *truncatedDate = [NSDate beginningOfDay:blink[@"date"]];
            NSMutableArray *existingBlinksForDate = [newBlinksDict objectForKey:truncatedDate];
            if (existingBlinksForDate) {
                [existingBlinksForDate addObject:blink];
            } else {
                existingBlinksForDate = [[NSMutableArray alloc] initWithObjects:blink, nil];
                [newBlinksDict setObject:existingBlinksForDate forKey:truncatedDate];
            }
        }
        
        self.blinksDict = newBlinksDict;
        self.segmentedControl.selectedSegmentIndex = self.segmentedControl.selectedSegmentIndex;
        [self segmentedControlChanged:self.segmentedControl];
    }];
}

@end
