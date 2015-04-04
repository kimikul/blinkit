//
//  BIMyBlinksBaseViewController.m
//  BlinkIt
//
//  Created by Kimberly Hsiao on 7/28/14.
//  Copyright (c) 2014 hsiao. All rights reserved.
//

#import "BIMyBlinksBaseViewController.h"
#import "BIPaginationTableViewCell.h"
#import "BIHomeTableViewCell.h"

@interface BIMyBlinksBaseViewController () <BIHomeTableViewCellDelegate, BIExpandImageHelperDelegate>

@end

@implementation BIMyBlinksBaseViewController

#pragma mark - init

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.useEmptyTableFooter = YES;
        self.useRefreshTableHeaderView = NO;
    }
    
    return self;
}


#pragma mark - setter/getter

- (NSMutableArray*)allBlinksArray {
    if (!_allBlinksArray) {
        _allBlinksArray = [NSMutableArray new];
    }
    
    return _allBlinksArray;
}


#pragma mark - lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableViewDefaults];
}

- (void)setupTableViewDefaults {
    self.tableView.scrollsToTop = YES;
    
    [self.tableView registerNib:[UINib nibWithNibName:[BIHomePhotoTableViewCell reuseIdentifier] bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[BIHomePhotoTableViewCell reuseIdentifier]];
    [self.tableView registerNib:[UINib nibWithNibName:[BIHomeTableViewCell reuseIdentifier] bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[BIHomeTableViewCell reuseIdentifier]];
}

#pragma mark - UITableViewDelegate / UITableViewDataSource

- (void)reloadTableData {
    [super reloadTableData];
    self.noBlinksView.hidden = (self.allBlinksArray.count > 0) ? YES : NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return ((self.allBlinksArray.count > 0) || self.isLoading) ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allBlinksArray.count + self.canPaginate;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // pagination row
    if (indexPath.row == self.allBlinksArray.count) {
        return [BIPaginationTableViewCell cellHeight];
    }
    
    // regular row
    CGFloat height = 0;
    PFObject *blink = [self.allBlinksArray objectAtIndex:indexPath.row];
    NSString *content = blink[@"content"];
    PFFile *imageFile = blink[@"imageFile"];
    
    if (imageFile) {
        height = [BIHomePhotoTableViewCell heightForContent:content];
    } else {
        height = [BIHomeTableViewCell heightForContent:content];
    }
    
    return height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // pagination row
    if (indexPath.row == self.allBlinksArray.count) {
        BIPaginationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[BIPaginationTableViewCell reuseIdentifier]];
        [cell.aiv startAnimating];
        return cell;
    }
    
    // regular row
    PFObject *blink = [self.allBlinksArray objectAtIndex:indexPath.row];
    BIHomeTableViewCell *cell;
    
    if (blink[@"imageFile"]) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:[BIHomePhotoTableViewCell reuseIdentifier]];
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:[BIHomeTableViewCell reuseIdentifier]];
    }
    
    cell.blink = blink;
    cell.delegate = self;
    cell.contentTextView.delegate = self;
    
    return cell;
}

#pragma mark - BIHomeTableViewCellDelegate

- (void)homeCell:(BIHomeTableViewCell*)homeCell togglePrivacyTo:(BOOL)private {
    // do nothing here
}

- (void)homeCell:(BIHomeTableViewCell *)homeCell didTapImageView:(UIImageView*)imageView {
    BIExpandImageHelper *expandImageHelper = [BIExpandImageHelper new];
    expandImageHelper.delegate = self;
    [expandImageHelper animateImageView:imageView];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([URL.absoluteString hasPrefix:@"#"]) {
        BIHashtagViewController *hashtagVC = [self.storyboard instantiateViewControllerWithIdentifier:@"BIHashtagViewController"];
        hashtagVC.hashtag = URL.absoluteString;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:hashtagVC];
        
        [self presentViewController:nav animated:YES completion:nil];
        
        return NO;
    }
    
    return YES;
}

@end
