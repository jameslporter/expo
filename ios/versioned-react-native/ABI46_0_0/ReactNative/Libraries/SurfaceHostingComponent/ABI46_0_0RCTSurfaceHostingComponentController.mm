/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI46_0_0RCTSurfaceHostingComponentController.h"

#import <ComponentKit/CKComponentSubclass.h>
#import <ABI46_0_0React/ABI46_0_0RCTAssert.h>
#import <ABI46_0_0React/ABI46_0_0RCTSurface.h>
#import <ABI46_0_0React/ABI46_0_0RCTSurfaceDelegate.h>
#import <ABI46_0_0React/ABI46_0_0RCTSurfaceView.h>

#import "ABI46_0_0RCTSurfaceHostingComponent+Internal.h"
#import "ABI46_0_0RCTSurfaceHostingComponent.h"
#import "ABI46_0_0RCTSurfaceHostingComponentState.h"

@interface ABI46_0_0RCTSurfaceHostingComponentController() <ABI46_0_0RCTSurfaceDelegate>
@end

@implementation ABI46_0_0RCTSurfaceHostingComponentController {
  id<ABI46_0_0RCTSurfaceProtocol> _surface;
}

- (instancetype)initWithComponent:(ABI46_0_0RCTSurfaceHostingComponent *)component
{
  if (self = [super initWithComponent:component]) {
    [self updateSurfaceWithComponent:component];
  }

  return self;
}

#pragma mark - Lifecycle

- (void)didMount
{
  [super didMount];
  [self mountSurfaceView];
}

- (void)didRemount
{
  [super didRemount];
  [self mountSurfaceView];
}

- (void)didUpdateComponent
{
  [super didUpdateComponent];
  [self updateSurfaceWithComponent:(ABI46_0_0RCTSurfaceHostingComponent *)self.component];
}

- (void)didUnmount
{
  [super didUnmount];
  [self unmountSurfaceView];
}

#pragma mark - Helpers

- (void)updateSurfaceWithComponent:(ABI46_0_0RCTSurfaceHostingComponent *)component
{
  // Updating `surface`
  id<ABI46_0_0RCTSurfaceProtocol> const surface = component.surface;
  if (surface != _surface) {
    if (_surface.delegate == self) {
      _surface.delegate = nil;
    }

    _surface = surface;
    _surface.delegate = self;
  }
}

- (void)setIntrinsicSize:(CGSize)intrinsicSize
{
  __weak __typeof(self) weakSelf = self;
  dispatch_async(dispatch_get_main_queue(), ^{
    __strong __typeof(self) strongSelf = weakSelf;
    if (!strongSelf) {
      return;
    }
    
    [strongSelf.component updateState:^(ABI46_0_0RCTSurfaceHostingComponentState *state) {
      return [ABI46_0_0RCTSurfaceHostingComponentState newWithStage:state.stage
                                             intrinsicSize:intrinsicSize];
    } mode:[strongSelf suitableStateUpdateMode]];
  });
}

- (void)setStage:(ABI46_0_0RCTSurfaceStage)stage
{
  __weak __typeof(self) weakSelf = self;
  dispatch_async(dispatch_get_main_queue(), ^{
    __strong __typeof(self) strongSelf = weakSelf;
    if (!strongSelf) {
      return;
    }
    
    [strongSelf.component updateState:^(ABI46_0_0RCTSurfaceHostingComponentState *state) {
      return [ABI46_0_0RCTSurfaceHostingComponentState newWithStage:stage
                                             intrinsicSize:state.intrinsicSize];
    } mode:[strongSelf suitableStateUpdateMode]];
  });
}

- (CKUpdateMode)suitableStateUpdateMode
{
  return ((ABI46_0_0RCTSurfaceHostingComponent *)self.component).options.synchronousStateUpdates && ABI46_0_0RCTIsMainQueue() ? CKUpdateModeSynchronous : CKUpdateModeAsynchronous;
}

- (void)mountSurfaceView
{
  UIView *const surfaceView = _surface.view;

  const CKComponentViewContext &context = [[self component] viewContext];

  UIView *const superview = context.view;
  superview.clipsToBounds = YES;

  ABI46_0_0RCTAssert([superview.subviews count] <= 1, @"Should never have more than a single stateful subview.");

  UIView *const existingSurfaceView = [superview.subviews lastObject];
  if (existingSurfaceView != surfaceView) {
    [existingSurfaceView removeFromSuperview];
    surfaceView.frame = superview.bounds;
    surfaceView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [superview addSubview:surfaceView];
  }
}

- (void)unmountSurfaceView
{
  const CKComponentViewContext &context = [[self component] viewContext];

  UIView *const superview = context.view;
  ABI46_0_0RCTAssert([superview.subviews count] <= 1, @"Should never have more than a single stateful subview.");
  UIView *const existingSurfaceView = [superview.subviews lastObject];
  [existingSurfaceView removeFromSuperview];
}

#pragma mark - ABI46_0_0RCTSurfaceDelegate

- (void)surface:(ABI46_0_0RCTSurface *)surface didChangeIntrinsicSize:(CGSize)intrinsicSize
{
  [self setIntrinsicSize:intrinsicSize];
}

- (void)surface:(ABI46_0_0RCTSurface *)surface didChangeStage:(ABI46_0_0RCTSurfaceStage)stage
{
  [self setStage:stage];
}

@end
