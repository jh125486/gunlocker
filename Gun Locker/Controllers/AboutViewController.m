//
//  AboutViewController.m
//  Gun Locker
//
//  Created by Jacob Hochstetler on 5/27/13.
//
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"about.html" ofType:nil];
    NSString *contentsOfAboutPage = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:contentsOfAboutPage baseURL:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [super viewDidUnload];
}
@end
