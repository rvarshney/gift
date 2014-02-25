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
#define PRICE_PER_ALBUM 20.00

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

@property (nonatomic, strong) STPView *stripeView;

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

    // Setup order button
    UIBarButtonItem *orderButton = [[UIBarButtonItem alloc] initWithTitle:@"Order" style:UIBarButtonItemStyleBordered target:self action:@selector(orderHandler:)];
    orderButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = orderButton;

    // Stripe view
    self.stripeView = [[STPView alloc] initWithFrame:CGRectMake(374, 360, 290, 55) andKey:STRIPE_PUBLISHABLE_KEY];
    self.stripeView.delegate = self;
    [self.view addSubview:self.stripeView];

    // Set the delegates
    self.nameTextField.delegate = self;
    self.addressTextField.delegate = self;
    self.cityTextField.delegate = self;
    self.zipTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.quantityTextField.delegate = self;
    
    // Start with one album
    self.quantityTextField.text = @"1";
    self.priceLabel.text = [NSString stringWithFormat:@"%.02f", PRICE_PER_ALBUM];
    self.totalLabel.text = self.priceLabel.text;
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

- (IBAction)quantityChanged:(id)sender
{
    NSInteger quantity = [self.quantityTextField.text integerValue];
    self.totalLabel.text = [NSString stringWithFormat:@"%.02f", (PRICE_PER_ALBUM * quantity)];
}

@end
