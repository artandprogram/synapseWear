//
//  OTABootloaderController.m
//  synapseWearCentral
//
//  Copyright © 2018年 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

#import "SimbleeManager.h"
#import "DFUHelper.h"
#import "UnzipFirmware.h"

#import "OTABootloaderController.h"

NSString *simbleeServiceUUID = @"fe84";
NSString *otaBootloaderServiceUUID = @"00001530-1212-efde-1523-785feabcd123";

@interface OTABootloaderController ()
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

@implementation OTABootloaderController

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

- (id)init
{
    self = [super init];
    if (self) {
        _dfuOperations = [[DFUOperations alloc] initWithDelegate:self];
        _dfuHelper = [[DFUHelper alloc] initWithData:_dfuOperations];
    }
    return self;
}

- (void)start
{
    [self startScan];
}

- (void)stop
{
    if (self.isConnected) {
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

- (void)startScan
{
    NSLog(@"OTABootloaderViewController startScan");
    simbleeManager = [[SimbleeManager alloc] init];
    simbleeManager.delegate = self;
    // scan service uuids
    simbleeManager.scanServices = @[
                                    [CBUUID UUIDWithString:simbleeServiceUUID],
                                    [CBUUID UUIDWithString:otaBootloaderServiceUUID]
                                    ];
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
    NSLog(@"OTABootloaderViewController didDiscoverSimblee: %@", simblee.peripheral.identifier.UUIDString);
    _simblee = simblee;
    _simblee.delegate = self;

    [self startDFU];
}

- (void)didConnectSimblee:(Simblee *)simblee
{
    NSLog(@"OTABootloaderViewController didConnectSimblee: %@", simblee.peripheral.identifier.UUIDString);
}

- (void)didNotConnectSimblee:(Simblee *)simblee
{
    NSLog(@"OTABootloaderViewController didNotConnectSimblee: %@", simblee.peripheral.identifier.UUIDString);
}

- (void)didLooseConnectSimblee:(Simblee *)simblee
{
    NSLog(@"OTABootloaderViewController didLooseConnectSimblee: %@", simblee.peripheral.identifier.UUIDString);
}

- (void)didDisconnectSimblee:(Simblee *)simblee
{
    NSLog(@"OTABootloaderViewController didDisconnectSimblee: %@", simblee.peripheral.identifier.UUIDString);
}

#pragma mark - general

- (void)bleUnsupported
{
    NSLog(@"OTABootloaderViewController BLE Unsupported");
}

- (void)bleUnauthorized
{
    NSLog(@"OTABootloaderViewController BLE Unauthorized");
}

- (void)blePoweredOff
{
    NSLog(@"OTABootloaderViewController BLE Powered Off");
    //NSLog(@"BLE Powered Off.\n\nOpen Settings, and switch Bluetooth On.");
}

- (void)blePoweredOn
{
    NSLog(@"OTABootloaderViewController BLE Powered On");
}

- (void)startDFU
{
    NSLog(@"OTABootloaderViewController startDFU");
    previousPeripheralDelegate = _simblee.peripheral.delegate;

    CBCentralManager *central = _simblee.simbleeManager.central;
    previousCentralManagerDelegate = central.delegate;
    [_dfuOperations setCentralManager:_simblee.simbleeManager.central];

    self.dfuHelper.applicationURL = _fileURL;
    //self.dfuHelper.applicationURL = [OTABootloaderViewController hexFileURL];
    [self performDFU];
}

- (void)performDFU
{
    NSLog(@"OTABootloaderViewController performDFU");
    // [self.dfuHelper checkAndPerformDFU];

    if (!self.isConnected) {
        [_dfuOperations connectDevice:_simblee.peripheral];

        if ([self->_delegate respondsToSelector:@selector(onConnectDevice)]) {
            [self->_delegate onConnectDevice];
        }
    }
    else {
        [_dfuOperations performDFUOnFile:self.dfuHelper.applicationURL
                            firmwareType:APPLICATION];

        if ([self->_delegate respondsToSelector:@selector(onPerformDFUOnFile)]) {
            [self->_delegate onPerformDFUOnFile];
        }
    }
}

#pragma mark DFUOperations delegate methods

- (void)onDeviceConnected:(CBPeripheral *)peripheral
{
    NSLog(@"OTABootloaderViewController onDeviceConnected: %@", peripheral.identifier.UUIDString);
    self.isConnected = YES;
    self.dfuHelper.isDfuVersionExist = NO;
    [self performDFU];

    if ([self->_delegate respondsToSelector:@selector(onDeviceConnected)]) {
        [self->_delegate onDeviceConnected];
    }
}

- (void)onDeviceConnectedWithVersion:(CBPeripheral *)peripheral
{
    NSLog(@"OTABootloaderViewController onDeviceConnectedWithVersion: %@", peripheral.identifier.UUIDString);
    self.isConnected = YES;
    self.dfuHelper.isDfuVersionExist = YES;
    [self performDFU];

    if ([self->_delegate respondsToSelector:@selector(onDeviceConnectedWithVersion)]) {
        [self->_delegate onDeviceConnectedWithVersion];
    }
}

- (void)onDeviceDisconnected:(CBPeripheral *)peripheral
{
    NSLog(@"OTABootloaderViewController onDeviceDisconnected: %@", peripheral.identifier.UUIDString);
    self.isTransferring = NO;
    self.isConnected = NO;

    if (self.dfuHelper.dfuVersion != 1) {
        if (!self.isTransfered && !self.isTransferCancelled && !self.isErrorKnown) {
            if ([self->_delegate respondsToSelector:@selector(onDeviceDisconnected)]) {
                [self->_delegate onDeviceDisconnected];
            }
        }
        self.isTransferCancelled = NO;
        self.isTransfered = NO;
        self.isErrorKnown = NO;
    }
    else {
        double delayInSeconds = 3.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self->_dfuOperations connectDevice:peripheral];
        });
    }
}

- (void)onReadDFUVersion:(int)version
{
    NSLog(@"OTABootloaderViewController onReadDFUVersion: %d", version);
    self.dfuHelper.dfuVersion = version;
    if (self.dfuHelper.dfuVersion == 1) {
        [_dfuOperations setAppToBootloaderMode];
    }

    if ([_delegate respondsToSelector:@selector(onReadDFUVersion)]) {
        [_delegate onReadDFUVersion];
    }
}

- (void)onDFUStarted
{
    NSLog(@"OTABootloaderViewController onDFUStarted");
    self.isTransferring = YES;

    if ([_delegate respondsToSelector:@selector(onDFUStarted:)]) {
        [_delegate onDFUStarted:[self.dfuHelper getUploadStatusMessage]];
    }
}

- (void)onDFUCancelled
{
    NSLog(@"OTABootloaderViewController onDFUCancelled");
    self.isTransferring = NO;
    self.isTransferCancelled = YES;
    [self stopScan];

    if ([_delegate respondsToSelector:@selector(onDFUCancelled)]) {
        [_delegate onDFUCancelled];
    }
}

- (void)onSoftDeviceUploadStarted
{
    NSLog(@"OTABootloaderViewController onSoftDeviceUploadStarted");
    if ([_delegate respondsToSelector:@selector(onSoftDeviceUploadStarted)]) {
        [_delegate onSoftDeviceUploadStarted];
    }
}

- (void)onSoftDeviceUploadCompleted
{
    NSLog(@"OTABootloaderViewController onSoftDeviceUploadCompleted");
    if ([_delegate respondsToSelector:@selector(onSoftDeviceUploadCompleted)]) {
        [_delegate onSoftDeviceUploadCompleted];
    }
}

- (void)onBootloaderUploadStarted
{
    NSLog(@"OTABootloaderViewController onBootloaderUploadStarted");
    if ([_delegate respondsToSelector:@selector(onBootloaderUploadStarted)]) {
        [_delegate onBootloaderUploadStarted];
    }
}

- (void)onBootloaderUploadCompleted
{
    NSLog(@"OTABootloaderViewController onBootloaderUploadCompleted");
    if ([_delegate respondsToSelector:@selector(onBootloaderUploadCompleted)]) {
        [_delegate onBootloaderUploadCompleted];
    }
}

- (void)onTransferPercentage:(int)percentage
{
    NSLog(@"OTABootloaderViewController onTransferPercentage: %d", percentage);
    if ([_delegate respondsToSelector:@selector(onTransferPercentage:)]) {
        [_delegate onTransferPercentage:percentage];
    }
}

- (void)onSuccessfulFileTranferred
{
    NSLog(@"OTABootloaderViewController onSuccessfulFileTranferred");
    // once a DFU is started:
    // [_dfuOperations canceDFU] should be called to abort
    // [_dfuOperations.dfuRequests activateAndReset] should be called to complete (the dual mode swap)

    // this delegate is called by [DFUOperations processValidateFirmwareResponseStatus]
    // which does the [_dfuOperations.dfuRequests activeAndReset] for us

    // calling [central cancelPeripheralConnection:simblee] creates a race condition:
    // - if the cancel completes before the activateAndReset, then the old dual mode app will be restored!

    self.isTransferring = NO;
    self.isTransfered = YES;

    if ([_delegate respondsToSelector:@selector(onSuccessfulFileTranferred)]) {
        [_delegate onSuccessfulFileTranferred];
    }
}

- (void)onError:(NSString *)errorMessage
{
    NSLog(@"OTABootloaderViewController onError: %@", errorMessage);
    self.isErrorKnown = YES;

    if ([_delegate respondsToSelector:@selector(onError:)]) {
        [_delegate onError:errorMessage];
    }
}

@end
