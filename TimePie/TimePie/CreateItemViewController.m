//
//  CreateItemViewController.m
//  TimePie
//
//  Created by Storm Max on 3/27/14.
//  Copyright (c) 2014 TimePieOrg. All rights reserved.
//

#import "CreateItemViewController.h"
#import "BasicUIColor+UIPosition.h"
#import <QuartzCore/QuartzCore.h>
#import "TimingItemStore.h"
#import "TimingItem1.h"
#import "Tag.h"
#import "ColorThemes.h"

#define TAG_LIMIT_COUNT     200
#define TAG_INPUT_FIELD_1   4001
#define TAG_INPUT_LABEL     4002
#define TAG_COLOR_TAG       4003
#define TAG_INPUT_FIELD_2   4004

static NSInteger routineItemFlag = 1;

@interface CreateItemViewController ()
{
    ColorPickerView *colorPicker;
    BOOL colorPickerIsAble;
    BOOL colorIsSelected;
    int currentColorTag;
}
@end

@implementation CreateItemViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        colorPickerIsAble = NO;
        colorIsSelected = NO;
        _isEditView = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initNavBar];
    [self initMainVessel];
    [self initNeededData];
    [NSTimer scheduledTimerWithTimeInterval:0.033f target:self
                                   selector:@selector(mainLoop:) userInfo:nil repeats:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [routineButton setSelected:NO];
    routineItemFlag = 1;
    [routineButton setImage:[UIImage imageNamed:@"AddRoutineButtonActive"] forState:UIControlStateNormal];
    [self performSelector:@selector(respondInput:) withObject:self afterDelay:0.033f];
}

- (void)initNeededData
{
//    currentColorTag = [[ColorThemes colorThemes] getAColor];
    if (_isEditView) {
        currentColorTag = _editItem.itemColor;
    }
}

- (void) mainLoop: (id) sender
{
    if(inputField.text.length > 0) initInputLabel.text = @"";
    else initInputLabel.text = @"名称";
    if (tagInputField.text.length > 0) addTagLabel.text = @"";
    else addTagLabel.text = @"新建标签";
    [NSTimer scheduledTimerWithTimeInterval:0.033f target:self
                                   selector:@selector(mainLoop:) userInfo:nil repeats:NO];
}

- (void)respondInput:(id)sender
{
    [inputField becomeFirstResponder];
}

- (void)initNavBar
{
    UIButton *tempBtn_cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 42, 22)];
    [tempBtn_cancel setImage:[UIImage imageNamed:@"CIVC_cancelButton"] forState:UIControlStateNormal];
    [tempBtn_cancel addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithCustomView:tempBtn_cancel];
    UIButton *tempBtn_confirm = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 42, 22)];
    [tempBtn_confirm setImage:[UIImage imageNamed:@"CIVC_confirmButton"] forState:UIControlStateNormal];
    [tempBtn_confirm addTarget:self action:@selector(confirmButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *confirmButton = [[UIBarButtonItem alloc] initWithCustomView:tempBtn_confirm];
    
    self.title = _isEditView ? @"编辑事项" : @"新建事项";
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = confirmButton;
    [self navigationController].navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: MAIN_UI_COLOR};
}

- (void)initMainVessel
{
    _CIVC_mainVessel = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _CIVC_mainVessel.separatorInset = UIEdgeInsetsZero;
    _CIVC_mainVessel.dataSource = self;
    _CIVC_mainVessel.delegate = self;
    _CIVC_mainVessel.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
    NSMutableArray *tempTagArray = [NSMutableArray arrayWithArray:[[TimingItemStore timingItemStore] getAllTags]];
    for (int i = 0; i<tempTagArray.count; i++)
    {
        if ([[[tempTagArray objectAtIndex:i] tag_name] isEqualToString:@""] || [[tempTagArray objectAtIndex:i] tag_name] == nil)
        {
            [tempTagArray removeObjectAtIndex:i];
        }
    }
    tagTextArray = tempTagArray;
    [self initTagCellSelectedFlag];
    [self.view addSubview:_CIVC_mainVessel];
}

- (void)initTagCellSelectedFlag
{
    tagCellSelectedFlag = [[NSMutableArray alloc] init];
    if (_isEditView) {
        for (int i = 0; i < tagTextArray.count; i++)
        {
            if ([[[tagTextArray objectAtIndex:i] tag_name] isEqualToString:_editItemTag])
            {
                [tagCellSelectedFlag addObject:@"y"];
            }
            else [tagCellSelectedFlag addObject:@"n"];
        }
    }
    else{
        for (int i = 0; i < tagTextArray.count; i++)
            [tagCellSelectedFlag addObject:@"n"];
    }
}

#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tagTextArray.count + 3;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier =[NSString stringWithFormat:@"%d",indexPath.row];
    NSInteger row = indexPath.row;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    if (row == 0)
    {
        if (_itemName.length == 0) [self initTextFieldInView:cell];
    }
    else if(row >= 1 && row <= tagTextArray.count)
    {
        [self initTagCellView:cell withIndexPath:indexPath];
        if ([[tagCellSelectedFlag objectAtIndex:indexPath.row - 1] isEqualToString:@"y"])
        {
            [self initTagCheckViewInView:cell WithImage:[UIImage imageNamed:@"TagCheck"] AtIndexPath:indexPath];
        }
    }
    else if(row == tagTextArray.count + 1)
    {
        [self initAddTagButtonInView:cell];
    }
    else
    {
        [self initRoutineCell:cell];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >=1 && indexPath.row <= tagTextArray.count)
    {
        UITableViewCell *cell = (UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        if ([[tagCellSelectedFlag objectAtIndex:indexPath.row - 1] isEqualToString:@"y"])
        {
            [tagCellSelectedFlag replaceObjectAtIndex:indexPath.row - 1 withObject:@"n"];
            [self initTagCheckViewInView:cell WithImage:[UIImage imageNamed:@"TagCheckTransparent"] AtIndexPath:indexPath];
            _currentTagOfItem = @"其他";
        }
        else
        {
            for (int i= 0; i < tagCellSelectedFlag.count; i++)
            {
                [tagCellSelectedFlag replaceObjectAtIndex:i withObject:@"n"];
                UITableViewCell *tempCell = (UITableViewCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i+1 inSection:0]];
                [self initTagCheckViewInView:tempCell WithImage:[UIImage imageNamed:@"TagCheckTransparent"] AtIndexPath:[NSIndexPath indexPathForRow:i+1 inSection:0]];
            }
            [tagCellSelectedFlag replaceObjectAtIndex:indexPath.row - 1 withObject:@"y"];
            [self initTagCheckViewInView:cell WithImage:[UIImage imageNamed:@"TagCheck"] AtIndexPath:indexPath];
            _currentTagOfItem = [[tagTextArray objectAtIndex:indexPath.row - 1] tag_name];
        }
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (inputField.text.length > 0) {
        _itemName = inputField.text;
        initInputLabel.text = @"";
    }
    if (tagInputField.text.length > 0)
    {
        [[TimingItemStore timingItemStore] addTag:tagInputField.text];
        [[TimingItemStore timingItemStore] saveData];
        
        tagTextArray = [NSMutableArray arrayWithArray:[[TimingItemStore timingItemStore] getAllTags]];
        [tagCellSelectedFlag addObject:@"n"];
        tagInputField.text = @"";
        [_CIVC_mainVessel reloadData];
    }
    colorTagButton.userInteractionEnabled = NO;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    colorTagButton.userInteractionEnabled = YES;
    [textField resignFirstResponder];
    if (textField.tag == TAG_INPUT_FIELD_1) _itemName = textField.text;
    else if (textField.text.length > 0)
    {
        [[TimingItemStore timingItemStore] addTag:textField.text];
        [[TimingItemStore timingItemStore] saveData];
        
        tagTextArray = [NSMutableArray arrayWithArray:[[TimingItemStore timingItemStore] getAllTags]];
        [tagCellSelectedFlag addObject:@"n"];
        textField.text = @"";
        [_CIVC_mainVessel reloadData];
    }
    return YES;
}

#pragma mark - ColorPickerViewDelegate

- (void)sendChosenColorWithColor:(UIColor *)chosenItemColor ColorTag:(int)chosenColorTag
{
    if (IS_IPHONE_HIGHERINCHE) {
        [UIView animateWithDuration:.5f animations:^{
            colorPicker.frame = CGRectMake(0, 568, SCREEN_WIDTH, 68);
        } completion:^(BOOL finished){
            colorPickerIsAble = NO;
        }];
    }
    else{
        [UIView animateWithDuration:.5f animations:^{
            colorPicker.frame = CGRectMake(0, 480, SCREEN_WIDTH, 68);
        } completion:^(BOOL finished){
            colorPickerIsAble = NO;
        }];
    }
    colorTagButton.backgroundColor = chosenItemColor;
    currentColorTag = chosenColorTag;
    colorIsSelected = YES;
}

#pragma mark - target selector
- (void)cancelButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)confirmButtonPressed
{
    if (!_isEditView) {
        if (inputField.text.length > 0)
        {
            _itemName = inputField.text;
        }
        if (_itemName.length > 0)
        {
            TimingItem* item = [[TimingItemStore timingItemStore] createItem];
            item.itemName = _itemName;
            item.itemColor = currentColorTag;
            
            if(routineItemFlag == 1)
            {
                // By default daily of item is on:
                [[TimingItemStore timingItemStore] addDaily:_itemName tag:_currentTagOfItem];
                
            }
            
            if([[TimingItemStore timingItemStore] allItems].count == 0){
                item.timing= YES;
            }
            [[TimingItemStore timingItemStore] addTag:item TagName:_currentTagOfItem];
            [[TimingItemStore timingItemStore] saveData];
            //        [[TimingItemStore timingItemStore] viewAllItem];
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"事项名称不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    else
    {
        if (inputField.text.length > 0)
        {
            _itemName = inputField.text;
        }
        if (_itemName.length > 0)
        {
            [[TimingItemStore timingItemStore] setNameByItem:_editItem toName:_itemName];
            [[TimingItemStore timingItemStore] setColorByItem:_editItem toColor:currentColorTag];
            [[TimingItemStore timingItemStore] setTagByItem:_editItem withTag:_currentTagOfItem];
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"事项名称不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

- (void)routineButtonPressed:(id)sender
{
    if ([sender isSelected])
    {
        [sender setImage:[UIImage imageNamed:@"AddRoutineButtonNormal"] forState:UIControlStateNormal];
        [sender setSelected:NO];
        routineItemFlag = 0;
    }
    else
    {
        [sender setImage:[UIImage imageNamed:@"AddRoutineButtonActive"] forState:UIControlStateSelected];
        [sender setSelected:YES];
        routineItemFlag = 1;
    }
}

- (void)tagColorPressed:(id)sender
{
    NSLog(@"colorPicker");
    if (!colorPickerIsAble)
    {
        colorPicker = [[ColorPickerView alloc] initWithFrame:CGRectMake(0, 568, SCREEN_WIDTH, 68)];
        colorPicker.delegate = self;
        [self.view addSubview:colorPicker];
        [self pushAnimateView:colorPicker];
    }
}

- (void)addTagButtonPressed:(id)sender
{
    
}

#pragma mark - utilities methods
- (void)initTextFieldInView:(UIView*)view
{
    colorTagButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 14, 22, 22)];
    if (!_isEditView) {
        currentColorTag = [[ColorThemes colorThemes] getAColor];
    }
    colorTagButton.backgroundColor = _isEditView? _editItemColor : [[ColorThemes colorThemes] getColorAt:currentColorTag];
    colorTagButton.tag =  TAG_COLOR_TAG;
    [colorTagButton addTarget:self action:@selector(tagColorPressed:) forControlEvents:UIControlEventTouchUpInside];
    if([view viewWithTag:TAG_COLOR_TAG]) [[view viewWithTag:TAG_COLOR_TAG] removeFromSuperview];
    [self setRoundedView:colorTagButton toDiameter:18];
    [view addSubview:colorTagButton];
    
    if([view viewWithTag:TAG_INPUT_FIELD_1]) [[view viewWithTag:TAG_INPUT_FIELD_1] removeFromSuperview];
    inputField = [[UITextField alloc] initWithFrame:CGRectMake(38.5, 0, SCREEN_WIDTH, 48)];
    inputField.returnKeyType = UIReturnKeyDone;
    inputField.textColor = MAIN_UI_COLOR;
    inputField.tag = TAG_INPUT_FIELD_1;
    inputField.text = _isEditView? _editItemName : @"";
    inputField.delegate = self;
    [view addSubview:inputField];
    
    if([view viewWithTag:TAG_INPUT_FIELD_2]) [[view viewWithTag:TAG_INPUT_FIELD_2] removeFromSuperview];
    initInputLabel = [[UILabel alloc] initWithFrame:CGRectMake(38.5, 0, 120, 48)];
    initInputLabel.text = @"名称";
    initInputLabel.textColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
    initInputLabel.tag = TAG_INPUT_FIELD_2;
    [view addSubview:initInputLabel];
}

-(void)setRoundedView:(UIView *)roundedView toDiameter:(float)newSize;
{
    roundedView.clipsToBounds = YES;
    CGPoint saveCenter = roundedView.center;
    CGRect newFrame = CGRectMake(roundedView.frame.origin.x, roundedView.frame.origin.y, newSize, newSize);
    roundedView.frame = newFrame;
    roundedView.layer.cornerRadius = newSize / 2.0;
    roundedView.center = saveCenter;
}

- (void)initTagCellView:(UIView*)view withIndexPath:(NSIndexPath*)indexPath
{
    if ([view viewWithTag:indexPath.row - 1])
        [[view viewWithTag:indexPath.row - 1] removeFromSuperview];
    UILabel *tempTagLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 120, 48)];
    tempTagLabel.text = [[tagTextArray objectAtIndex:indexPath.row - 1] tag_name];
    tempTagLabel.tag = indexPath.row - 1;
    [view addSubview:tempTagLabel];
    [tagInputField removeFromSuperview];
    [addTagLabel removeFromSuperview];
}

- (void)initAddTagButtonInView:(UIView*)view
{
    tagInputField = [[UITextField alloc] initWithFrame:CGRectMake(40, 0, SCREEN_WIDTH, 48)];
    tagInputField.returnKeyType = UIReturnKeyDone;
    tagInputField.tag = 1;
    tagInputField.delegate = self;
    addTagLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 120, 48)];
    addTagLabel.text = @"新建标签";
    addTagLabel.textColor = [UIColor colorWithRed:0.67 green:0.67 blue:0.67 alpha:1.0];
    [routineButton removeFromSuperview];
    [view addSubview:addTagLabel];
    [view addSubview:tagInputField];
}

- (void)initRoutineCell:(UIView*)view
{
    routineButton = [[UIButton alloc] initWithFrame:CGRectMake(0, -1, SCREEN_WIDTH, 48)];
    if(routineItemFlag == 0)
    {
        [routineButton setImage:[UIImage imageNamed:@"AddRoutineButtonNormal"] forState:UIControlStateNormal];
        [routineButton setSelected:NO];
    }
    else
    {
        [routineButton setImage:[UIImage imageNamed:@"AddRoutineButtonActive"] forState:UIControlStateNormal];
        [routineButton setSelected:YES];
    }
    [routineButton addTarget:self action:@selector(routineButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:routineButton];
}

- (void)initTagCheckViewInView:(UIView*)view WithImage:(UIImage*)image AtIndexPath:(NSIndexPath*)indexPath
{
    if ([view viewWithTag:indexPath.row * TAG_LIMIT_COUNT])
        [[view viewWithTag:indexPath.row * TAG_LIMIT_COUNT] removeFromSuperview];
    tagCheck = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 20, 18)];
    tagCheck.tag = indexPath.row * TAG_LIMIT_COUNT;
    tagCheck.image = image;
    [view addSubview:tagCheck];
}

- (void)pushAnimateView:(UIView*)view
{
    if (IS_IPHONE_HIGHERINCHE)
    {
        [UIView animateWithDuration:.5f animations:^{
            view.frame = CGRectMake(0, 500, SCREEN_WIDTH, 68);
        } completion:^(BOOL finished){
            colorPickerIsAble = YES;
        }];
    }
    else
    {
        [UIView animateWithDuration:.5f animations:^{
            view.frame = CGRectMake(0, 480 - 68, SCREEN_WIDTH, 68);
        } completion:^(BOOL finished){
            colorPickerIsAble = YES;
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
