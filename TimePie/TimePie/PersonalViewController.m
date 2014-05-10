//
//  PersonalViewController.m
//  TimePie
//
//  Created by Storm Max on 3/27/14.
//  Copyright (c) 2014 TimePieOrg. All rights reserved.
//

#import "PersonalViewController.h"
#import "BasicUIColor+UIPosition.h"
#import "PersonalViewAvgTimeCell.h"
#import "timeDistributeCell.h"
#import "PersonalViewEventTrackCell.h"
#import "PersonalViewPicker.h"

@interface PersonalViewController ()

@end

@implementation PersonalViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    if(_exitButton) _exitButton.hidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initNavBar];
    [self initMainView];
    [self initExitButton];
    [self initDarkUILayer];
}

#pragma mark - init UI
- (void)initNavBar
{
    UIButton *tempBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 42, 22)];
    [tempBtn setImage:[UIImage imageNamed:@"settingsButton"] forState:UIControlStateNormal];
    [tempBtn addTarget:self action:@selector(settingsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithCustomView:tempBtn];
    
    self.title = @"个人中心";
    self.navigationItem.rightBarButtonItem = settingsButton;
    [self navigationController].navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: MAIN_UI_COLOR};
}

- (void)initExitButton
{
    _exitButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-47, SCREEN_HEIGHT-62, 94, 57)];
    [_exitButton setImage:[UIImage imageNamed:@"TimePie_Personal_Exit_Button"] forState:UIControlStateNormal];
    [_exitButton addTarget:self action:@selector(exitButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    _exitButton.tag = 3001;
    [[self navigationController].view addSubview:_exitButton];
    [[self navigationController].view bringSubviewToFront:_exitButton];
}

- (void)initMainView
{
    _mainView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 26) style:UITableViewStyleGrouped];
    _mainView.backgroundView = nil;
    _mainView.backgroundColor = [UIColor clearColor];
    _mainView.dataSource = self;
    _mainView.delegate = self;
    _mainView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _mainView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    _mainView.separatorInset = UIEdgeInsetsZero;
    timeRangeInfo = @"过去一周";
    [self.view addSubview:_mainView];
}

- (void)initDarkUILayer
{
    darkUILayer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    darkUILayer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    darkUILayer.userInteractionEnabled = NO;
    [self.view addSubview:darkUILayer];
}

#pragma mark - target selector
- (void)exitButtonPressed
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromTop;
    [self.view.window.layer addAnimation:transition forKey:nil];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)settingsButtonPressed
{
    SettingsViewController *sVC = [[SettingsViewController alloc] init];
    sVC.delegate = self;
    self.exitButton.hidden = YES;
    [[self navigationController] pushViewController:sVC animated:YES];
}

-(void)donePressed
{
    timeRangeInfo = [_pVCPicker.pickerData objectAtIndex:[_pVCPicker.picker selectedRowInComponent:0]];
    [_mainView reloadData];
    [self pushViewAnimationWithView:_pVCPicker willHidden:YES];
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    self.view.userInteractionEnabled = YES;
}

-(void)cancelPressed
{
    [self pushViewAnimationWithView:_pVCPicker willHidden:YES];
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    self.view.userInteractionEnabled = YES;
}

#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2)
    {
        return 5;
    }
    else if(section == 0) return 2;
    else return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    if (section == 0 && row == 0)
    {
        static NSString *rangeCellIdentifier = @"Cell";
        UITableViewCell *rangeCell = [tableView dequeueReusableCellWithIdentifier:rangeCellIdentifier];
        if(rangeCell == nil)
        {
            rangeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:rangeCellIdentifier];
        }
        rangeCell.textLabel.text = @"查看范围";
        rangeCell.textLabel.textColor = MAIN_UI_COLOR;
        rangeCell.detailTextLabel.text = timeRangeInfo;
        rangeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        rangeCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return rangeCell;
    }
    else if(section == 0 && row == 1)
    {
        static NSString *avgTimeCellIdentifier = @"AvgTimeIdentifier";
        PersonalViewAvgTimeCell *avgTimeCell = [tableView dequeueReusableCellWithIdentifier:avgTimeCellIdentifier];
        if (avgTimeCell == nil)
        {
            avgTimeCell = [[PersonalViewAvgTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:avgTimeCellIdentifier];
        }
        avgTimeCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return avgTimeCell;
    }
    else if(section == 1)
    {
        static NSString *timeDistributeCellIdentifier = @"timeDistributeIdentifier";
        timeDistributeCell *timeDrtbCell = [tableView dequeueReusableCellWithIdentifier:timeDistributeCellIdentifier];
        if (timeDrtbCell == nil)
        {
            timeDrtbCell = [[timeDistributeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:timeDistributeCellIdentifier];
            
        }
        timeDrtbCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return timeDrtbCell;
    }
    else
    {
        static NSString *itemTrackCellIdentifier = @"PersonalViewEventTrackCell";
        PersonalViewEventTrackCell *itemTrackCell = [tableView dequeueReusableCellWithIdentifier:itemTrackCellIdentifier];
        if(itemTrackCell == nil)
        {
            itemTrackCell = [[PersonalViewEventTrackCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:itemTrackCellIdentifier];
        }
        if(indexPath.row == 0) [itemTrackCell initCellColorWith:REDNO1];
        //todo: set with index path
        if (indexPath.row == 1)
        {
            itemTrackCell.PVETCEventLabel.text = @"酱油";
            itemTrackCell.PVETCAvgTimeLabel.text = @"2.6";
            itemTrackCell.PVETCEventLabel.textColor = itemTrackCell.PVETCAvgTimeLabel.textColor = itemTrackCell.PVETCHourIndicatorLabel.textColor = BLUENO2;
            [itemTrackCell initCellColorWith:BLUENO2];
        }
        else if(indexPath.row == 2)
        {
            itemTrackCell.PVETCEventLabel.text = @"健身";
            itemTrackCell.PVETCAvgTimeLabel.text = @"3.9";
            itemTrackCell.PVETCEventLabel.textColor = itemTrackCell.PVETCAvgTimeLabel.textColor = itemTrackCell.PVETCHourIndicatorLabel.textColor = GREENNO3;
            [itemTrackCell initCellColorWith:GREENNO3];
        }
        itemTrackCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return itemTrackCell;
    }
}

#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    if (section == 0 || section == 2) return 50.0;
    else return 142.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) return 0.01;
    else return 18.0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, -7, tableView.frame.size.width, 16)];
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, -17, tableView.frame.size.width, 35)];
        bgView.backgroundColor = MAIN_DARK_BG_COLOR;
        label.text = @"时间分布比";
        label.textColor = MAIN_UI_COLOR;
        [view addSubview:label];
        [view addSubview:bgView];
        [view sendSubviewToBack:bgView];
        return view;
    }
    else if (section == 2)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, -7, tableView.frame.size.width, 16)];
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, -17, tableView.frame.size.width, 35)];
        bgView.backgroundColor = MAIN_DARK_BG_COLOR;
        label.text = @"事件日均时间跟踪";
        label.textColor = MAIN_UI_COLOR;
        [view addSubview:label];
        [view addSubview:bgView];
        [view sendSubviewToBack:bgView];
        return view;
    }
    else return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && indexPath.row == 0)
    {
        self.view.userInteractionEnabled = NO;
        self.navigationController.navigationBar.userInteractionEnabled = NO;
        _pVCPicker = [[PersonalViewPicker alloc] initWithFrame:CGRectMake(0, 568, SCREEN_WIDTH, 215)];
        [_pVCPicker addTargetForCancelButton:self action:@selector(cancelPressed)];
        [_pVCPicker addTargetForDoneButton:self action:@selector(donePressed)];
        [[self navigationController].view addSubview:_pVCPicker];
        [self pushViewAnimationWithView:_pVCPicker willHidden:NO];
        _pVCPicker.hidden = NO;
    }
}

#pragma mark - settingsViewController Delegate
- (void)reverseCloseButton
{
    self.exitButton.hidden = NO;
}

#pragma mark - utility functions
- (void)pushViewAnimationWithView:(UIView*)view willHidden:(BOOL)hidden
{
    [UIView animateWithDuration:0.25 animations:^{
        if (hidden)
        {
            view.frame = CGRectMake(0, 568, SCREEN_WIDTH, 215);
            darkUILayer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        }
        else
        {
            [view setHidden:hidden];
            view.frame = CGRectMake(0, SCREEN_HEIGHT - 215, SCREEN_WIDTH, 215);
            darkUILayer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        }
    } completion:^(BOOL finished){
        [view setHidden:hidden];
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
