/*
 * Copyright (c) 2015 RF Digital Corp. All Rights Reserved.
 *
 * The source code contained in this file and all intellectual property embodied in
 * or covering the source code is the property of RF Digital Corp. or its licensors.
 * Your right to use this source code and intellectual property is non-transferable,
 * non-sub licensable, revocable, and subject to terms and conditions of the
 * SIMBLEE SOFTWARE LICENSE AGREEMENT.
 * http://www.simblee.com/licenses/SimbleeSoftwareLicenseAgreement.txt
 *
 * THE SOURCE CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND.
 *
 * This heading must NOT be removed from this file.
 */

//#include "DLog.h"

#import "UIAlertViewBlock.h"
#import "SimbleeManager.h"
#import "DFUHelper.h"
#import "UnzipFirmware.h"
#import "OTABootloaderViewController.h"

//#import "AppDelegate.h"

NSString *simbleeServiceUUID = @"fe84";
NSString *otaBootloaderServiceUUID = @"00001530-1212-efde-1523-785feabcd123";

@interface OTABootloaderViewController ()
{
    id previousPeripheralDelegate;
    id previousCentralManagerDelegate;

    SimbleeManager *simbleeManager;
}

@property(strong, nonatomic) DFUOperations *dfuOperations;
@property (strong, nonatomic) DFUHelper *dfuHelper;

@property BOOL isTransferring;
@property BOOL isTransfered;
@property BOOL isTransferCancelled;
@property BOOL isConnected;
@property BOOL isErrorKnown;

@end

@implementation OTABootloaderViewController

+ (NSURL *)hexFileURL
{
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:resourcePath error:nil];
    for (NSString *file in contents) {
        if ([file hasSuffix:@".hex"]) {
            NSLog(@"application: %@", file);
            return [[NSBundle mainBundle] URLForResource:file withExtension:nil];
        }
    }
    return nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self) {
        //PACKETS_NOTIFICATION_INTERVAL = [[[NSUserDefaults standardUserDefaults] valueForKey:@"dfu_number_of_packets"] intValue];
        //NSLog(@"PACKETS_NOTIFICATION_INTERVAL %d",PACKETS_NOTIFICATION_INTERVAL);
        /*
        // Custom initialization
        UIButton *backButton = [UIButton buttonWithType:101];  // left-pointing shape
        [backButton setTitle:@"Disconnect" forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(disconnect:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        [[self navigationItem] setLeftBarButtonItem:backItem];
         */
        [[self navigationItem] setHidesBackButton:YES];
        [[self navigationItem] setTitle:@"OTA Bootloader"];

        _dfuOperations = [[DFUOperations alloc] initWithDelegate:self];
        _dfuHelper = [[DFUHelper alloc] initWithData:_dfuOperations];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIColor *start = [UIColor colorWithRed:58/255.0 green:108/255.0 blue:183/255.0 alpha:0.15];
    UIColor *stop = [UIColor colorWithRed:58/255.0 green:108/255.0 blue:183/255.0 alpha:0.45];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    //gradient.frame = [self.view bounds];
    gradient.frame = CGRectMake(0.0, 0.0, 1024.0, 1024.0);
    gradient.colors = @[(id)start.CGColor, (id)stop.CGColor];
    [self.view.layer insertSublayer:gradient atIndex:0];

    [self startScan];
    /*
    // increase width
    [progress setTransform:CGAffineTransformMakeScale(1.0, 3.0)];

    previousPeripheralDelegate = _simblee.peripheral.delegate;

    CBCentralManager *central = _simblee.simbleeManager.central;
    previousCentralManagerDelegate = central.delegate;
    [_dfuOperations setCentralManager:_simblee.simbleeManager.central];

    [self clearUI];
    self.dfuHelper.applicationURL = [OTABootloaderViewController hexFileURL];
    [self performDFU];
     */
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    [self setViewsFrame];
}

- (void)setViewsFrame
{
    activityIndicator.frame = CGRectMake((self.view.frame.size.width - 50.0) / 2,
                                         (self.view.frame.size.height - 50.0) / 2,
                                         50.0,
                                         50.0);
    progressLabel.frame     = CGRectMake(0,
                                         activityIndicator.frame.origin.y - 40.0,
                                         self.view.frame.size.width,
                                         40.0);
    progress.frame          = CGRectMake(50.0,
                                         progressLabel.frame.origin.y - 10.0,
                                         self.view.frame.size.width - 50.0 * 2,
                                         10.0);
    uploadStatus.frame      = CGRectMake(0,
                                         progress.frame.origin.y - (40.0 + 20.0),
                                         self.view.frame.size.width,
                                         40.0);
    uploadButton.frame      = CGRectMake(0,
                                         activityIndicator.frame.origin.y + activityIndicator.frame.size.height,
                                         self.view.frame.size.width,
                                         40.0);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];

    //if DFU peripheral is connected and user press Back button then disconnect it
    if (/*[self isMovingFromParentViewController] &&*/ self.isConnected) {
        // DLog(@"isMovingFromParentViewController");
        [_dfuOperations cancelDFU];
    }

    [self stopScan];

    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSError *error = nil;
    [fileManager removeItemAtURL:self.fileURL
                           error:&error];
    if (error) {
        NSLog(@"remove file error: %@", error.localizedDescription);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)appDidEnterBackground:(NSNotification *)_notification
{
    NSLog(@"appDidEnterBackground");
    /*if (self.isConnected && self.isTransferring) {
        [Utility showBackgroundNotification:[self.dfuHelper getUploadStatusMessage]];
    }*/
}

- (void)appDidEnterForeground:(NSNotification *)_notification
{
    NSLog(@"appDidEnterForeground");
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)startScan
{
    NSLog(@"OTABootloaderViewController startScan");
    simbleeManager = [[SimbleeManager alloc] init];
    //simbleeManager = SimbleeManager.sharedSimbleeManager;
    simbleeManager.delegate = self;

    // scan service uuids
    simbleeManager.scanServices = @[
                                    [CBUUID UUIDWithString:simbleeServiceUUID],
                                    [CBUUID UUIDWithString:otaBootloaderServiceUUID]
                                    ];
    /*if ([OTABootloaderViewController hexFileURL]) {
        simbleeManager.scanServices = @[[CBUUID UUIDWithString:simbleeServiceUUID], [CBUUID UUIDWithString:otaBootloaderServiceUUID]];
    } else {
        simbleeManager.scanServices = @[[CBUUID UUIDWithString:simbleeServiceUUID]];
    }*/

    // scan defaults
    simbleeManager.scanUpdates = YES;
    simbleeManager.restartInterval = 60.0;
    [simbleeManager startScan];
}

- (void)stopScan
{
    NSLog(@"OTABootloaderViewController stopScan");
    if (_simblee != nil) {
        [_simblee disconnect];
        _simblee.delegate = nil;
        _simblee = nil;
    }
    [simbleeManager stopScan];
    simbleeManager.delegate = nil;
    simbleeManager = nil;
}

#pragma mark - SimbleeManagerDelegate methods

- (void)didDiscoverSimblee:(Simblee *)simblee
{
    _simblee = simblee;
    _simblee.delegate = self;
    [self startDFU];
}

- (void)didConnectSimblee:(Simblee *)simblee
{
}

- (void)didNotConnectSimblee:(Simblee *)simblee
{
}

- (void)didLooseConnectSimblee:(Simblee *)simblee
{
}

- (void)didDisconnectSimblee:(Simblee *)simblee
{
}

#pragma warn - misc

- (void)alert:(NSString *)message
        title:(NSString *)title
        block:(void (^)(NSInteger buttonIndex))block
{
    UIAlertViewBlock *alert = [[UIAlertViewBlock alloc] initWithTitle:title
                                                              message:message
                                                                block:block
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
    [alert show];
}

#pragma mark - general

- (void)bleUnsupported
{
    [self alert:@"BLE Unsupported" title:@"App" block:nil];
}

- (void)bleUnauthorized
{
    [self alert:@"BLE Unauthorized" title:@"App" block:nil];
}

- (void)blePoweredOff
{
    [self alert:@"BLE Powered Off.\n\nOpen Settings, and switch Bluetooth On." title:@"App" block:nil];
}

- (void)blePoweredOn
{
}

- (void)startDFU
{
    //NSLog(@"startDFU");
    previousPeripheralDelegate = _simblee.peripheral.delegate;
    
    CBCentralManager *central = _simblee.simbleeManager.central;
    previousCentralManagerDelegate = central.delegate;
    [_dfuOperations setCentralManager:_simblee.simbleeManager.central];
    
    [self clearUI];
    self.dfuHelper.applicationURL = _fileURL;
    //self.dfuHelper.applicationURL = [OTABootloaderViewController hexFileURL];
    [self performDFU];
}

- (void)clearUI
{
    progress.progress = 0.0f;
    // progress.hidden = YES;
    progressLabel.text = @"0%";
    // progressLabel.hidden = YES;
    uploadStatus.text = @"waiting ...";
    // uploadStatus.hidden = YES;
    activityIndicator.hidden = YES;
    [uploadButton setTitle:@"Close" forState:UIControlStateNormal];
    //[uploadButton setTitle:@"Upload" forState:UIControlStateNormal];
    uploadButton.enabled = YES;
    [self enableOtherButtons];
}

- (void)enableUploadButton
{
    uploadButton.enabled = YES;
}

- (void)enableOtherButtons
{
}

- (void)disableOtherButtons
{
}

- (IBAction)uploadPressed:(id)sender
{
    if (self.isTransferring) {
        [_dfuOperations cancelDFU];
    }
    else {
        [self dismissViewControllerAnimated:true completion:nil];
        //[self performDFU];
    }
}

- (void)performDFU
{
    //NSLog(@"performDFU");

    dispatch_async(dispatch_get_main_queue(), ^{
        [self disableOtherButtons];
        progress.hidden = NO;
        progressLabel.hidden = NO;
        uploadStatus.hidden = NO;
        activityIndicator.hidden = NO;
        uploadButton.enabled = NO;
    });

    // [self.dfuHelper checkAndPerformDFU];

    if (!self.isConnected) {
        uploadStatus.text = @"connecting...";
        [_dfuOperations connectDevice:_simblee.peripheral];
    } else {
        uploadStatus.text = @"starting...";
        [_dfuOperations performDFUOnFile:self.dfuHelper.applicationURL
                            firmwareType:APPLICATION];
    }
}

#pragma mark DFUOperations delegate methods

- (void)onDeviceConnected:(CBPeripheral *)peripheral
{
    NSLog(@"onDeviceConnected: %@",peripheral.name);

    self.isConnected = YES;
    self.dfuHelper.isDfuVersionExist = NO;
    // [self enableUploadButton];
    [self performDFU];
    //Following if condition display user permission alert for background notification
    /*
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil]];
    }
    */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)onDeviceConnectedWithVersion:(CBPeripheral *)peripheral
{
    NSLog(@"onDeviceConnectedWithVersion: %@",peripheral.name);

    self.isConnected = YES;
    self.dfuHelper.isDfuVersionExist = YES;
    // [self enableUploadButton];
    [self performDFU];
    //Following if condition display user permission alert for background notification
    /*
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil]];
    }
    */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)onDeviceDisconnected:(CBPeripheral *)peripheral
{
    NSLog(@"onDeviceDisconnected: %@",peripheral.name);

    self.isTransferring = NO;
    self.isConnected = NO;

    // Scanner uses other queue to send events. We must edit UI in the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.dfuHelper.dfuVersion != 1) {
            [self clearUI];

            if (!self.isTransfered && !self.isTransferCancelled && !self.isErrorKnown) {
                if ([Utility isApplicationStateInactiveORBackground]) {
                    [Utility showBackgroundNotification:[NSString stringWithFormat:@"%@ peripheral is disconnected.",peripheral.name]];
                }
                else {
                    [Utility showAlert:@"The connection has been lost"];
                }
                [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
            }

            self.isTransferCancelled = NO;
            self.isTransfered = NO;
            self.isErrorKnown = NO;
        }
        else {
            double delayInSeconds = 3.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [_dfuOperations connectDevice:peripheral];
            });
        }
    });
}

- (void)onReadDFUVersion:(int)version
{
    NSLog(@"onReadDFUVersion: %d",version);

    self.dfuHelper.dfuVersion = version;
    NSLog(@"DFU Version: %d",self.dfuHelper.dfuVersion);
    if (self.dfuHelper.dfuVersion == 1) {
        [_dfuOperations setAppToBootloaderMode];
    }
    // [self enableUploadButton];
}

- (void)onDFUStarted
{
    NSLog(@"onDFUStarted");

    self.isTransferring = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [uploadButton setTitle:@"Cancel" forState:UIControlStateNormal];
        uploadButton.enabled = YES;
        NSString *uploadStatusMessage = [self.dfuHelper getUploadStatusMessage];
        if ([Utility isApplicationStateInactiveORBackground]) {
            [Utility showBackgroundNotification:uploadStatusMessage];
        }
        else {
            uploadStatus.text = uploadStatusMessage;
        }
    });
}

- (void)onDFUCancelled
{
    NSLog(@"onDFUCancelled");

    self.isTransferring = NO;
    self.isTransferCancelled = YES;

    [self dismissViewControllerAnimated:true completion:nil];
    /*
    dispatch_async(dispatch_get_main_queue(), ^{
        [self enableOtherButtons];
    });

    [self stopScan];*/
}

- (void)onSoftDeviceUploadStarted
{
    NSLog(@"onSoftDeviceUploadStarted");
}

- (void)onSoftDeviceUploadCompleted
{
    NSLog(@"onSoftDeviceUploadCompleted");
}

- (void)onBootloaderUploadStarted
{
    NSLog(@"onBootloaderUploadStarted");

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([Utility isApplicationStateInactiveORBackground]) {
            [Utility showBackgroundNotification:@"uploading bootloader ..."];
        }
        else {
            uploadStatus.text = @"uploading bootloader ...";
        }
    });
}

- (void)onBootloaderUploadCompleted
{
    NSLog(@"onBootloaderUploadCompleted");
}

- (void)onTransferPercentage:(int)percentage
{
    NSLog(@"onTransferPercentage: %d",percentage);

    // Scanner uses other queue to send events. We must edit UI in the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        progressLabel.text = [NSString stringWithFormat:@"%d %%", percentage];
        [progress setProgress:((float)percentage/100.0) animated:YES];
    });
}

- (void)onSuccessfulFileTranferred
{
    NSLog(@"onSuccessfulFileTranferred");

    // once a DFU is started:
    // [_dfuOperations canceDFU] should be called to abort
    // [_dfuOperations.dfuRequests activateAndReset] should be called to complete (the dual mode swap)

    // this delegate is called by [DFUOperations processValidateFirmwareResponseStatus]
    // which does the [_dfuOperations.dfuRequests activeAndReset] for us
    
    // calling [central cancelPeripheralConnection:simblee] creates a race condition:
    // - if the cancel completes before the activateAndReset, then the old dual mode app will be restored!

    // Scanner uses other queue to send events. We must edit UI in the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isTransferring = NO;
        self.isTransfered = YES;
        NSString* message = [NSString stringWithFormat:@"%lu bytes transfered in %lu seconds", (unsigned long)_dfuOperations.binFileSize, (unsigned long)_dfuOperations.uploadTimeInSeconds];
        if ([Utility isApplicationStateInactiveORBackground]) {
            [Utility showBackgroundNotification:message];
        }
        else {
            [self alert:message
                  title:@"Update firmwear completed"
                  block:^(NSInteger buttonIndex) {
                      CBCentralManager *central = _simblee.simbleeManager.central;
                      central.delegate = previousCentralManagerDelegate;

                      _simblee.peripheral.delegate = previousPeripheralDelegate;

                      [self dismissViewControllerAnimated:true completion:nil];
                  }];
            /*
            // [Utility showAlert:message];
            UIAlertViewBlock *alert = [[UIAlertViewBlock alloc]
                                       initWithTitle:@"DFU"
                                       message:message
                                       block:^(NSInteger buttonIndex) {
                                           CBCentralManager *central = _simblee.simbleeManager.central;
                                           central.delegate = previousCentralManagerDelegate;

                                           _simblee.peripheral.delegate = previousPeripheralDelegate;
                                           
                                           AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                                           [appDelegate otaBootloaderViewController:self onSuccessfulFileTransferred:_simblee];
                                           
                                       }
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
            [alert show];
             */
        }
    });
}

- (void)onError:(NSString *)errorMessage
{
    NSLog(@"onError: %@",errorMessage);

    self.isErrorKnown = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [Utility showAlert:errorMessage];
        [self clearUI];
    });
}

@end
