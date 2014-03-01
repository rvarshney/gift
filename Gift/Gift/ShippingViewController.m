//
//  ShippingViewController.m
//  Gift
//
//  Created by Ruchi Varshney on 2/8/14.
//
//

#import <Parse/Parse.h>
#import "ShippingViewController.h"
#import "STPView.h"
#import "Client.h"

#define STRIPE_PUBLISHABLE_KEY @"pk_test_WYMOjn1zNM8emFRAEFDkgxVS"

#define ALBUM_PRICE_USD 35.00

@interface ShippingViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UITextField *stateTextField;
@property (weak, nonatomic) IBOutlet UITextField *zipTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *quantityTextField;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet STPView *stripeView;
@property (weak, nonatomic) IBOutlet UILabel *creditCardLabel;
@property (weak, nonatomic) IBOutlet UIView *shippingView;
@property (weak, nonatomic) IBOutlet UIView *orderView;

- (IBAction)quantityChanged:(id)sender;

@end

@implementation ShippingViewController

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

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    self.title = @"Order";

    // Setup order button
    UIBarButtonItem *orderButton = [[UIBarButtonItem alloc] initWithTitle:@"Order" style:UIBarButtonItemStyleBordered target:self action:@selector(orderHandler:)];
    orderButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = orderButton;

    // Stripe view
    self.stripeView.key = STRIPE_PUBLISHABLE_KEY;

    // Set the delegates
    self.stripeView.delegate = self;
    self.nameTextField.delegate = self;
    self.addressTextField.delegate = self;
    self.cityTextField.delegate = self;
    self.zipTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.quantityTextField.delegate = self;

    self.shippingView.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
    self.shippingView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.shippingView.layer.borderWidth = 5.0f;
    self.shippingView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.shippingView.layer.shadowRadius = 3.0f;
    self.shippingView.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.shippingView.layer.shadowOpacity = 0.5f;

    self.orderView.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
    self.orderView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.orderView.layer.borderWidth = 5.0f;
    self.orderView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.orderView.layer.shadowRadius = 3.0f;
    self.orderView.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.orderView.layer.shadowOpacity = 0.5f;

    self.stripeView.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];

    // Start with one album
    self.quantityTextField.text = @"1";
    self.priceLabel.text = [NSString stringWithFormat:@"%.02f", ALBUM_PRICE_USD];
    self.totalLabel.text = self.priceLabel.text;

}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)deregisterFromKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerForKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self deregisterFromKeyboardNotifications];
    [super viewWillDisappear:animated];
}

- (void)viewDidLayoutSubviews {
//    [self.scrollView setContentSize:CGSizeMake(1000, 1000)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Stripe view delegate

- (void)stripeView:(STPView *)view withCard:(PKCard *)card isValid:(BOOL)valid
{
    self.navigationItem.rightBarButtonItem.enabled = valid;
}

- (void)orderHandler:(id)sender
{
    [self.stripeView createToken:^(STPToken *token, NSError *error) {
        if (error) {
            [self hasError:error];
        } else {
            [self hasToken:token];
        }
    }];
}

- (void)hasError:(NSError *)error
{
    NSLog(@"Stripe token error : %@", [error localizedDescription]);
}

- (void)hasToken:(STPToken *)token
{
    NSLog(@"Received token %@", token.tokenId);

    NSNumber *quantity = [NSNumber numberWithInteger:[self.quantityTextField.text integerValue]];
    NSNumber *price = [NSNumber numberWithFloat:[self.priceLabel.text floatValue]];
    NSNumber *total = [NSNumber numberWithFloat:[self.totalLabel.text floatValue]];
    NSString *cardToken = token.tokenId;
    NSData *fileData = [NSData dataWithContentsOfFile:self.albumFile];

    NSDictionary *shippingInfo = @{@"name": self.nameTextField.text,
                                   @"email": self.emailTextField.text,
                                   @"address": self.addressTextField.text,
                                   @"zip": self.zipTextField.text,
                                   @"city": self.cityTextField.text,
                                   @"state": self.stateTextField.text};

    // Create an order
    Order *order = [[Client instance] createOrderForUser:[PFUser currentUser] album:self.album fileData:fileData price:price quantity:quantity total:total shippingInfo:shippingInfo cardToken:cardToken];
    
    [PFCloud callFunctionInBackground:@"purchaseItem" withParameters:@{@"order": order.objectId} block:^(id object, NSError *error) {
        if (error) {
            NSLog(@"Error ordering album");
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

#pragma mark - Keyboard notification methods

- (void)keyboardDidShow:(NSNotification *)notification
{
    //NSDictionary* info = [notification userInfo];
    //CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    //NSDictionary* info = [notification userInfo];
    //CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
}

#pragma mark - Private methods

- (IBAction)quantityChanged:(id)sender
{
    NSInteger quantity = [self.quantityTextField.text integerValue];
    self.totalLabel.text = [NSString stringWithFormat:@"%.02f", (ALBUM_PRICE_USD * quantity)];
}

@end
