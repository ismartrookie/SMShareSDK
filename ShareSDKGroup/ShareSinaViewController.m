//
//  ShareSinaViewController.m
//  CordovaLib
//
//  Created by administrator on 14-1-10.
//
//

#import "ShareSinaViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ShareSDK.h"

@interface ShareSinaViewController ()<UITextViewDelegate> {
    UITextView *contentView;
    UIView *toolview;
    UILabel *textCountL;
}

@end

@implementation ShareSinaViewController

+ (ShareSinaViewController *)shareInstance
{
    static ShareSinaViewController *sharevctrl = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharevctrl = [[ShareSinaViewController alloc] init];
    });
    return sharevctrl;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor grayColor]];

    UIToolbar *toolBar = [[UIToolbar alloc] init];
    [toolBar setFrame:CGRectMake(0, 0, 320, 44)];
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(leftBarClickAction:)];
    UIBarButtonItem *centerBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarClickAction:)];
    NSArray *barItemArr = [NSArray arrayWithObjects:leftBarItem,centerBarItem,rightBarItem, nil];
    [toolBar setItems:barItemArr];
    
    contentView = [[UITextView alloc] init];
    [contentView setFrame:CGRectMake(15, CGRectGetHeight(toolBar.frame)+10, 290, 120)];
    [contentView.layer setCornerRadius:10];
    [contentView setFont:[UIFont systemFontOfSize:17.0f]];
    [contentView setDelegate:self];
    
    toolview = [[UIView alloc] init];
    [toolview setFrame:CGRectMake(0, CGRectGetMaxY(contentView.frame)+5, 320, 44)];
    [toolview setBackgroundColor:[UIColor whiteColor]];
    
    textCountL = [[UILabel alloc] init];
    [textCountL setFrame:CGRectMake(200, 2, 100, 40)];
    [textCountL setText:[NSString stringWithFormat:@"0/140"]];
    [textCountL setFont:[UIFont systemFontOfSize:16.0f]];
    [textCountL setContentMode:UIViewContentModeCenter];
    [textCountL setTextColor:[UIColor redColor]];
    [toolview addSubview:textCountL];

    [self.view addSubview:toolBar];
    [self.view addSubview:contentView];
    [self.view addSubview:toolview];
}

- (void)leftBarClickAction:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (void)rightBarClickAction:(UIBarButtonItem *)sender
{
     WBAuthorizeRequest *request = [WBAuthorizeRequest request];
     request.redirectURI = @"http://jinher.com";
     request.scope = @"all";
     request.userInfo = @{@"SSO_From": @"ShareSinaViewController",
                         @"ShareContent": contentView.text};
     [WeiboSDK sendRequest:request];
    
    [contentView resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [contentView resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITextViewDelegate


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *new = [textView.text stringByReplacingCharactersInRange:range withString:text];
    NSInteger res = 140-[new length];
    if(res >= 0){
        [textCountL setText:[NSString stringWithFormat:@"%d/140",[new length]]];
        return YES;
    }
    else{
        NSRange rg = {0,[text length]+res};
        if (rg.length>0) {
            NSString *s = [text substringWithRange:rg];
            [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:s]];
        }
        [textCountL setText:[NSString stringWithFormat:@"140/140"]];
        return NO;
    }
}









@end
