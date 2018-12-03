/*
 Copyright (c) 2013 OpenSourceRF.com.  All right reserved.
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 See the GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import <QuartzCore/QuartzCore.h>


#import "AppViewController.h"
@interface AppViewController()
@end

@implementation AppViewController
{
    MFMailComposeViewController* mailComposeViewController;
   
}
@synthesize rfduino;

+ (void)load
{
    // customUUID = @"c97433f0-be8f-4dc8-b6f0-5343e6100eb4";
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIButton *backButton = [UIButton buttonWithType:101];  // left-pointing shape
        [backButton setTitle:@"Disconnect" forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(disconnect:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        [[self navigationItem] setLeftBarButtonItem:backItem];
        
        [[self navigationItem] setTitle:@"RFduino Temp"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
 
    [rfduino setDelegate:self];
    
    UIColor *start = [UIColor colorWithRed:58/255.0 green:108/255.0 blue:183/255.0 alpha:0.15];
    UIColor *stop = [UIColor colorWithRed:58/255.0 green:108/255.0 blue:183/255.0 alpha:0.45];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = [self.view bounds];
    gradient.colors = [NSArray arrayWithObjects:(id)start.CGColor, (id)stop.CGColor, nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
//location manager properties
    locationManager = [[CLLocationManager alloc]init]; // initializing locationManager
    locationManager.delegate = self; // we set the delegate of locationManager to self.
    locationManager.desiredAccuracy = kCLLocationAccuracyBest; // setting the accuracy
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    [locationManager startUpdatingLocation];  //requesting location updates
    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)disconnect:(id)sender
{
    NSLog(@"disconnect pressed");

    [rfduino disconnect];
}

- (void)didReceive:(NSData *)data
{
    NSLog(@"RecievedRX");
    
    float celsius = dataFloat(data);
    
    NSLog(@"c=%.2f", celsius);
    
    NSString* string1 = [NSString stringWithFormat:@"%.2f", celsius];
    //NSString* string2 = [NSString stringWithFormat:@"%.2f F", fahrenheit];
   
    NSDate * now = [NSDate date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HH:mm:ss"];
    NSString *newDateString = [outputFormatter stringFromDate:now];
    //NSLog(@"newDateString %@", newDateString);
    //[outputFormatter release];
    
    [label1 setText:string1];
    //[label2 setText:string2];
    NSString *final = [NSString stringWithFormat:@"%@,%@\n", newDateString,string1];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    documentsDirectory =[documentsDirectory stringByAppendingPathComponent:@"myfile.txt"];

    NSError *error;
 
    NSString* contents = [NSString stringWithContentsOfFile:documentsDirectory
                                                   encoding:NSUTF8StringEncoding
                                                      error:&error];
    if(error) { // If error object was instantiated, handle it.
        [final writeToFile:documentsDirectory
                        atomically:YES encoding:NSUTF8StringEncoding error:&error];
        NSLog(@"ERROR while loading from file: %@", error);
        // …
    }
    contents = [contents stringByAppendingString:final];

    [contents writeToFile:documentsDirectory atomically:YES
                 encoding:NSUTF8StringEncoding
                    error:&error];
   
    // NSLog(@"contents: %@", contents);


}

//location manager properties
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There was an error retrieving your location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [errorAlert show];
    NSLog(@"Error: %@",error.description);
   
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
     NSLog(@"we are here");
    CLLocation *crnLoc = [locations lastObject];
    latitude.text = [NSString stringWithFormat:@"%.8f",crnLoc.coordinate.latitude];
    longitude.text = [NSString stringWithFormat:@"%.8f",crnLoc.coordinate.longitude];
    altitude.text = [NSString stringWithFormat:@"%.0f m",crnLoc.altitude];
    speed.text = [NSString stringWithFormat:@"%.1f m/s", crnLoc.speed];
    NSLog(@"%@", [locations lastObject]);
    
    NSString *final = [NSString stringWithFormat:@"%@", [locations lastObject]];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    documentsDirectory =[documentsDirectory stringByAppendingPathComponent:@"myfile.txt"];
    
    NSError *error;
    
    NSString* contents = [NSString stringWithContentsOfFile:documentsDirectory
                                                   encoding:NSUTF8StringEncoding
                                                      error:&error];
    if(error) { // If error object was instantiated, handle it.
        [final writeToFile:documentsDirectory
                atomically:YES encoding:NSUTF8StringEncoding error:&error];
        NSLog(@"ERROR while loading from file: %@", error);
        // …
    }
    contents = [contents stringByAppendingString:final];
    
    [contents writeToFile:documentsDirectory atomically:YES
                 encoding:NSUTF8StringEncoding
                    error:&error];
    
}

- (IBAction)sendEMail:(id)sender {
    
    if (![MFMailComposeViewController canSendMail]) {
        NSLog(@"Can not send Email");
    }else{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
        documentsDirectory =[documentsDirectory stringByAppendingPathComponent:@"myfile.txt"];
        NSData *noteData = [NSData dataWithContentsOfFile:documentsDirectory];
        mailComposeViewController = [[MFMailComposeViewController alloc] init];
        mailComposeViewController.mailComposeDelegate = self;
      
//        MFMailComposeViewController *_mailController = [[MFMailComposeViewController alloc] init];
        [mailComposeViewController setToRecipients:@[@"anna.shats@gmail.com"]];
        [mailComposeViewController setSubject:@"A File Sent By Email"];
        [mailComposeViewController setMailComposeDelegate:self];
        [mailComposeViewController addAttachmentData:noteData mimeType:@"text/plain" fileName:@"myfile.txt"];
        
          [self presentViewController:mailComposeViewController animated:YES completion:nil];
    }
    
}


-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    if (error) {
        NSLog(@"failed to send mail");
    }
    [mailComposeViewController dismissViewControllerAnimated:YES completion:nil];
}






- (void)didSend:(NSData *)data
{
    
}


    

    






@end
