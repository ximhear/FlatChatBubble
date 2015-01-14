//
//  ViewController.m
//  NewChatBubble
//
//  Created by Siba Prasad Hota  on 1/3/15.
//  Copyright (c) 2015 Wemakeappz. All rights reserved.
//

#import "ViewController.h"
#import "SPHTextBubbleCell.h"
#import "SPHMediaBubbleCell.h"
#import "Constantvalues.h"
#import "SPH_PARAM_List.h"

@interface ViewController ()<TextCellDelegate,MediaCellDelegate>
{
    NSMutableArray *sphBubbledata;
    BOOL isfromMe;
}

@property(nonatomic, weak) IBOutlet NSLayoutConstraint* bottomConstraint;
@property(nonatomic, weak) IBOutlet NSLayoutConstraint* textViewHeightConstraint;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isfromMe=YES;
    sphBubbledata =[[NSMutableArray alloc]init];
    
    self.chattable.backgroundColor = [UIColor clearColor];
    
    [self SetupDummyMessages];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.chattable addGestureRecognizer:tap];
    self.chattable.backgroundColor =[UIColor clearColor];
    self.chattable.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
//    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
//    self.messageField.leftView = paddingView;
//    self.messageField.leftViewMode = UITextFieldViewModeAlways;
    
    // Do any additional setup after loading the view, typically from a nib.
    
    CGFloat cornerRadius = 10.0f;
    
    self.messageField.backgroundColor = [UIColor whiteColor];
    self.messageField.layer.borderWidth = 0.5f;
    self.messageField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.messageField.layer.cornerRadius = cornerRadius;
    
    self.messageField.scrollIndicatorInsets = UIEdgeInsetsMake(cornerRadius, 0.0f, cornerRadius, 0.0f);
    
    self.messageField.textContainerInset = UIEdgeInsetsMake(4.0f, 2.0f, 4.0f, 2.0f);
    self.messageField.contentInset = UIEdgeInsetsMake(2.0f, 0.0f, 2.0f, 0.0f);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self addKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self removeKeyboardNotifications];
}

#pragma mark tableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return sphBubbledata.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPH_PARAM_List *feed_data=[[SPH_PARAM_List alloc]init];
    feed_data=[sphBubbledata objectAtIndex:indexPath.row];
    
    if ([feed_data.chat_media_type isEqualToString:kImagebyme]||[feed_data.chat_media_type isEqualToString:kImagebyOther])  return 180;
    
    CGSize labelSize =[feed_data.chat_message boundingRectWithSize:CGSizeMake(226.0f, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{ NSFontAttributeName:[UIFont systemFontOfSize:14.0f] }
                                            context:nil].size;
    return labelSize.height + 30 + TOP_MARGIN < 80 ? 80 : labelSize.height + 30 + TOP_MARGIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *L_CellIdentifier = @"SPHTextBubbleCell";
    static NSString *R_CellIdentifier = @"SPHMediaBubbleCell";
    
    SPH_PARAM_List *feed_data=[[SPH_PARAM_List alloc]init];
    feed_data=[sphBubbledata objectAtIndex:indexPath.row];
    
    if ([feed_data.chat_media_type isEqualToString:kTextByme]||[feed_data.chat_media_type isEqualToString:kTextByOther])
    {
        SPHTextBubbleCell *cell = (SPHTextBubbleCell *) [tableView dequeueReusableCellWithIdentifier:L_CellIdentifier];
        if (cell == nil)
        {
            cell = [[SPHTextBubbleCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:L_CellIdentifier];
        }
        cell.bubbletype=([feed_data.chat_media_type isEqualToString:kTextByme])?@"LEFT":@"RIGHT";
        cell.textLabel.text = feed_data.chat_message;
        cell.textLabel.tag=indexPath.row;
        cell.timestampLabel.text = @"02:20 AM";
        cell.CustomDelegate=self;
        cell.AvatarImageView.image=([feed_data.chat_media_type isEqualToString:kTextByme])?[UIImage imageNamed:@"ProfilePic"]:[UIImage imageNamed:@"person"];
        return cell;

    }
    
    SPHMediaBubbleCell *cell = (SPHMediaBubbleCell *) [tableView dequeueReusableCellWithIdentifier:R_CellIdentifier];
    if (cell == nil)
    {
        cell = [[SPHMediaBubbleCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:R_CellIdentifier];
    }
    cell.bubbletype=([feed_data.chat_media_type isEqualToString:kImagebyme])?@"LEFT":@"RIGHT";
    cell.textLabel.text = feed_data.chat_message;
    cell.messageImageView.tag=indexPath.row;
    cell.CustomDelegate=self;
    cell.timestampLabel.text = @"02:20 AM";
    cell.AvatarImageView.image=([feed_data.chat_media_type isEqualToString:kImagebyme])?[UIImage imageNamed:@"ProfilePic"]:[UIImage imageNamed:@"person"];
    
    return cell;
}



//=========***************************************************=============
#pragma mark - CELL CLICKED  PROCEDURE
//=========***************************************************=============


-(void)textCellDidTapped:(SPHTextBubbleCell *)tesxtCell AndGesture:(UIGestureRecognizer*)tapGR;
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tesxtCell.textLabel.tag inSection:0];
    NSLog(@"Forward Pressed =%@ and IndexPath=%@",tesxtCell.textLabel.text,indexPath);
    [tesxtCell showMenu];
}
// 7684097905

-(void)cellCopyPressed:(SPHTextBubbleCell *)tesxtCell
{
    NSLog(@"copy Pressed =%@",tesxtCell.textLabel.text);
    
}

-(void)cellForwardPressed:(SPHTextBubbleCell *)tesxtCell
{
    NSLog(@"Forward Pressed =%@",tesxtCell.textLabel.text);
    
}
-(void)cellDeletePressed:(SPHTextBubbleCell *)tesxtCell
{
    NSLog(@"Delete Pressed =%@",tesxtCell.textLabel.text);
    
}

//=========*******************  BELOW FUNCTIONS FOR IMAGE  **************************=============

-(void)mediaCellDidTapped:(SPHMediaBubbleCell *)mediaCell AndGesture:(UIGestureRecognizer*)tapGR;
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:mediaCell.messageImageView.tag inSection:0];
    NSLog(@"Media cell Pressed  and IndexPath=%@",indexPath);

    [mediaCell showMenu];
}

-(void)mediaCellCopyPressed:(SPHMediaBubbleCell *)mediaCell
{
    NSLog(@"copy Pressed =%@",mediaCell.messageImageView.image);
    
}

-(void)mediaCellForwardPressed:(SPHMediaBubbleCell *)mediaCell
{
    NSLog(@"Forward Pressed =%@",mediaCell.messageImageView.image);
   
}
-(void)mediaCellDeletePressed:(SPHMediaBubbleCell *)mediaCell
{
    NSLog(@"Delete Pressed =%@",mediaCell.messageImageView.image);
   
}


/////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark               KEYBOARD UPDOWN EVENT
/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)dismissKeyboard
{
    [self.view endEditing:YES];
}


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
//    if (sphBubbledata.count>2) {
//        [self performSelector:@selector(scrollTableview) withObject:nil afterDelay:0.0];
//    }
//    CGRect tableviewframe=self.chattable.frame;
//    tableviewframe.size.height-=210;
//    
//    [UIView animateWithDuration:0.25 animations:^{
//        self.msgInPutView.frame=CGRectMake(0,self.view.frame.size.height-265, self.view.frame.size.width, 50);
//        self.chattable.frame=tableviewframe;
//    }];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
//    CGRect tableviewframe=self.chattable.frame;
//    tableviewframe.size.height+=210;
//    [UIView animateWithDuration:0.25 animations:^{
//        self.msgInPutView.frame=CGRectMake(0,self.view.frame.size.height-50,  self.view.frame.size.width, 50);
//        self.chattable.frame=tableviewframe;  }];
//    if (sphBubbledata.count>2) {
//        [self performSelector:@selector(scrollTableview) withObject:nil afterDelay:0.25];
//    }
}



-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}






/////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark       SEND MESSAGE PRESSED   
/////////////////////////////////////////////////////////////////////////////////////////////////////

- (IBAction)sendMessageNow:(id)sender
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm a"];
    
    if ([self.messageField.text length]>0) {
        
        if (isfromMe)
        {
            NSString *rowNum=[NSString stringWithFormat:@"%d",(int)sphBubbledata.count];
            [self adddMediaBubbledata:kTextByme mediaPath:self.messageField.text mtime:[formatter stringFromDate:date] thumb:@"" downloadstatus:@"" sendingStatus:kSending msg_ID:[self genRandStringLength:7]];
            [self performSelector:@selector(messageSent:) withObject:rowNum afterDelay:1];
            
            isfromMe=NO;
        }
        else
        {
            [self adddMediaBubbledata:kTextByOther mediaPath:self.messageField.text mtime:[formatter stringFromDate:date] thumb:@"" downloadstatus:@"" sendingStatus:kSent msg_ID:[self genRandStringLength:7]];
            isfromMe=YES;
        }
        self.messageField.text = @"";
        [self.messageField layoutIfNeeded];
        [self.chattable reloadData];
        CGSize descriptionSize = self.messageField.contentSize;
        NSLog(@"height : %f", descriptionSize.height);
        [self.textViewHeightConstraint setConstant:descriptionSize.height];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self scrollTableview];
        });
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)messageSent:(NSString*)rownum
{
    int rowID=[rownum intValue];
    
    SPH_PARAM_List *feed_data=[[SPH_PARAM_List alloc]init];
    feed_data=[sphBubbledata objectAtIndex:rowID];
    
    [sphBubbledata  removeObjectAtIndex:rowID];
    feed_data.chat_send_status=kSent;
    [sphBubbledata insertObject:feed_data atIndex:rowID];
    
    // [self.chattable reloadData];
    
    NSArray *indexPaths = [NSArray arrayWithObjects:
                           [NSIndexPath indexPathForRow:rowID inSection:0],
                           // Add some more index paths if you want here
                           nil];
    BOOL animationsEnabled = [UIView areAnimationsEnabled];
    [UIView setAnimationsEnabled:NO];
    [self.chattable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [UIView setAnimationsEnabled:animationsEnabled];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)scrollTableview
{
    
    NSInteger item = [self.chattable numberOfRowsInSection:0] - 1;
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForItem:item inSection:0];
    [self.chattable scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)adddMediaBubbledata:(NSString*)mediaType  mediaPath:(NSString*)mediaPath mtime:(NSString*)messageTime thumb:(NSString*)thumbUrl  downloadstatus:(NSString*)downloadstatus sendingStatus:(NSString*)sendingStatus msg_ID:(NSString*)msgID
{
    
    SPH_PARAM_List *feed_data=[[SPH_PARAM_List alloc]init];
    feed_data.chat_message=mediaPath;
    feed_data.chat_date_time=messageTime;
    feed_data.chat_media_type=mediaType;
    feed_data.chat_send_status=sendingStatus;
    feed_data.chat_Thumburl=thumbUrl;
    feed_data.chat_downloadStatus=downloadstatus;
    feed_data.chat_messageID=msgID;
    [sphBubbledata addObject:feed_data];
}


/////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark  GENERATE RANDOM ID to SAVE IN LOCAL
/////////////////////////////////////////////////////////////////////////////////////////////////////


-(NSString *) genRandStringLength: (int) len {
    
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    
    return randomString;
}



/////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark       SETUP DUMMY MESSAGE / REPLACE THEM IN LIVE
/////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)SetupDummyMessages
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm a"];
    
    //  msg_ID  Any Random ID
    
    //  mediaPath  : Your Message  or  Path of the Image
    
//    [self adddMediaBubbledata:kTextByme mediaPath:@"Hi, check this new control!" mtime:[formatter stringFromDate:date] thumb:@"" downloadstatus:@"" sendingStatus:kSent msg_ID:[self genRandStringLength:7]];
//    //[self performSelector:@selector(messageSent:) withObject:@"0" afterDelay:1];
//    
//    [self adddMediaBubbledata:kTextByOther mediaPath:@"Hello! How are you?" mtime:[formatter stringFromDate:date] thumb:@"" downloadstatus:@"" sendingStatus:kSent msg_ID:[self genRandStringLength:7]];
//    
//    [self adddMediaBubbledata:kTextByme mediaPath:@"I'm doing Great!" mtime:[formatter stringFromDate:date] thumb:@"" downloadstatus:@"" sendingStatus:kSent msg_ID:[self genRandStringLength:7]];
//    
//    [self adddMediaBubbledata:kImagebyme mediaPath:@"ImageUrl" mtime:[formatter stringFromDate:date] thumb:@"" downloadstatus:@"" sendingStatus:kSent msg_ID:[self genRandStringLength:7]];
//    
//    [self adddMediaBubbledata:kImagebyOther mediaPath:@"Yeah its cool!" mtime:[formatter stringFromDate:date] thumb:@"" downloadstatus:@"" sendingStatus:kSent msg_ID:[self genRandStringLength:7]];
//    
//    [self adddMediaBubbledata:kTextByme mediaPath:@"Supports Image too.\nSupports Image too.\nSupports Image too.\ng한글도\nwkf나오나궁금하네, 가족의 비밀.. 하튼ㄴㄴㄴㄴㄴ" mtime:[formatter stringFromDate:date] thumb:@"" downloadstatus:@"" sendingStatus:kSent msg_ID:[self genRandStringLength:7]];
//    
//    [self adddMediaBubbledata:kTextByOther mediaPath:@"Yup. I like the tail part of it." mtime:[formatter stringFromDate:date] thumb:@"" downloadstatus:@"" sendingStatus:kSent msg_ID:[self genRandStringLength:7]];
//    
//    [self adddMediaBubbledata:kImagebyme mediaPath:@"ImageUrl" mtime:[formatter stringFromDate:date] thumb:@"" downloadstatus:@"" sendingStatus:kSending msg_ID:@"ABFCXYZ"];
//    
//    [self adddMediaBubbledata:kImagebyOther mediaPath:@"Hi, check this new control!" mtime:[formatter stringFromDate:date] thumb:@"" downloadstatus:@"" sendingStatus:kSent msg_ID:[self genRandStringLength:7]];
//    [self adddMediaBubbledata:kTextByme mediaPath:@"lets meet some time for dinner! hope you will like it." mtime:[formatter stringFromDate:date] thumb:@"" downloadstatus:@"" sendingStatus:kSent msg_ID:[self genRandStringLength:7]];
    

    [self adddMediaBubbledata:kTextByme mediaPath:@"aaa" mtime:[formatter stringFromDate:date] thumb:@"" downloadstatus:@"" sendingStatus:kSent msg_ID:[self genRandStringLength:7]];
    [self adddMediaBubbledata:kTextByOther mediaPath:@"aaa" mtime:[formatter stringFromDate:date] thumb:@"" downloadstatus:@"" sendingStatus:kSent msg_ID:[self genRandStringLength:7]];

    
    [self.chattable reloadData];
}


- (void)addKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#if 1
- (void)keyboardWillShowNotification:(NSNotification *)notification {
    
    CGRect keyboardBounds;
    [notification.userInfo[UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    NSNumber *curve = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateKeyframesWithDuration:[duration doubleValue] delay:0 options:[curve intValue] animations:^{
        self.bottomConstraint.constant = keyboardBounds.size.height;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

- (void)keyboardWillHideNotification:(NSNotification *)notification {
    
    CGRect keyboardBounds;
    [notification.userInfo[UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    NSNumber *curve = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    
    [UIView animateKeyframesWithDuration:[duration doubleValue] delay:0 options:[curve intValue] animations:^{
        self.bottomConstraint.constant = 0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}
#endif

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    CGSize descriptionSize = textView.contentSize;
    
    NSLog(@"height : %f", descriptionSize.height);
    
    [self.textViewHeightConstraint setConstant:descriptionSize.height];
    
    [self.messageField setNeedsLayout];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    CGSize descriptionSize = textView.contentSize;
    
    NSLog(@"height : %f", descriptionSize.height);
    
    [self.textViewHeightConstraint setConstant:descriptionSize.height];
    
    [self.messageField setNeedsLayout];
}

- (void)textViewDidChange:(UITextView *)textView {
    
    CGSize descriptionSize = textView.contentSize;
    
    NSLog(@"height : %f", descriptionSize.height);
    
    [self.textViewHeightConstraint setConstant:descriptionSize.height];
    
    [self.messageField setNeedsLayout];
}

@end
