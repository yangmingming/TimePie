//
//  SettingsThemeViewController.h
//  TimePie
//
//  Created by 大畅 on 14-5-8.
//  Copyright (c) 2014年 TimePieOrg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsThemeViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *themeList;
    NSMutableArray *themeColorList;
}
@property (strong, nonatomic) UITableView *STVC_Vessel;

@end
