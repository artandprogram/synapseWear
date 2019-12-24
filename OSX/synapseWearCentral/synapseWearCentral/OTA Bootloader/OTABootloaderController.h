//
//  OTABootloaderController.h
//  synapseWearCentral
//
//  Copyright © 2018 art and program, Inc. For license and other information refer to https://github.com/artandprogram/synapseWear. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Simblee.h"
#import "SimbleeDelegate.h"
// #import "SimbleeManagerDelegate.h"

#import "DFUOperations.h"

@protocol OTABootloaderControllerDelegate <NSObject>

@optional

- (void)onConnectDevice;
- (void)onPerformDFUOnFile;
- (void)onDeviceConnected;
- (void)onDeviceConnectedWithVersion;
- (void)onDeviceDisconnected;
- (void)onReadDFUVersion;
- (void)onDFUStarted:(NSString *)uploadStatusMessage;
- (void)onDFUCancelled;
- (void)onSoftDeviceUploadStarted;
- (void)onSoftDeviceUploadCompleted;
- (void)onBootloaderUploadStarted;
- (void)onBootloaderUploadCompleted;
- (void)onTransferPercentage:(int)percentage;
- (void)onSuccessfulFileTransferred:(NSString *)message;
- (void)onDFUEnded;
- (void)onDFUCancelFinish;
- (void)onError:(NSString *)errorMessage;

@end

@interface OTABootloaderController : NSObject<SimbleeDelegate, DFUOperationsDelegate>

@property(assign, nonatomic) id<OTABootloaderControllerDelegate> delegate;

@property(strong, nonatomic) Simblee *simblee;
@property(strong, nonatomic) NSURL *fileURL;

+ (NSURL *)hexFileURL;

- (void)start;
- (void)stop;
- (void)cancel;

@end
