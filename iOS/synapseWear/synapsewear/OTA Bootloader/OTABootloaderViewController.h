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

#import <UIKit/UIKit.h>

#import "Simblee.h"
#import "SimbleeDelegate.h"
// #import "SimbleeManagerDelegate.h"

#import "DFUOperations.h"

@interface OTABootloaderViewController : UIViewController<SimbleeDelegate, DFUOperationsDelegate>
//@interface OTABootloaderViewController : UIViewController<SimbleeDelegate, SimbleeManagerDelegate>
{
    __weak IBOutlet UILabel *uploadStatus;
    __weak IBOutlet UIProgressView *progress;
    __weak IBOutlet UILabel *progressLabel;
    __weak IBOutlet UIActivityIndicatorView *activityIndicator;
    __weak IBOutlet UIButton *uploadButton;
}

@property(strong, nonatomic) Simblee *simblee;
@property(strong, nonatomic) NSURL *fileURL;

+ (NSURL *)hexFileURL;

- (IBAction)uploadPressed:(id)sender;

@end
