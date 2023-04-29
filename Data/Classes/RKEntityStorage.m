// MIT License
//
// Copyright (c) Uottakuot Software
// https://github.com/uottakuot/RapidKit
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import <objc/runtime.h>
#import "RKEntityStorage.h"
#import "RKCoreDataStorage.h"
#import "RKDataPrivate.h"
#import "RKKeyedArchiveStorage.h"

NSString* const RKEntityStorageInfoCollectionChangedKey = @"RKEntityStorageInfoCollectionChanged";
static NSString* const RKObjectStorageInternalExceptionReason = @"Storage not initialized properly.";

@implementation RKEntityStorage

- (id)initWithURL:(NSURL*)url type:(RKEntityStorageType)type options:(RKEntityStorageOptions*)options {
    if (type == RKEntityStorageTypeCoreData) {
        self = [[RKCoreDataStorage alloc] initWithURL:url options:options];
    } else if (type == RKEntityStorageTypeKeyedArchive) {
        self = [[RKKeyedArchiveStorage alloc] initWithURL:url options:options];
    }
    
    return self;
}

- (NSArray*)objectsWithRequest:(RKEntityRequest*)request {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:RKObjectStorageInternalExceptionReason userInfo:nil];
}

- (NSArray*)objectsWithPredicate:(NSPredicate*)predicate class:(Class)class {
    RKEntityRequest* request = [[RKEntityRequest alloc] init];
    [request setEntityClass:class];
    [request setPredicate:predicate];
    return [self objectsWithRequest:request];
}

- (NSInteger)numberOfObjectsWithRequest:(RKEntityRequest*)request {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:RKObjectStorageInternalExceptionReason userInfo:nil];
}

- (NSInteger)numberOfObjectsWithPredicate:(NSPredicate*)predicate class:(Class)class {
    RKEntityRequest* request = [[RKEntityRequest alloc] init];
    [request setEntityClass:class];
    [request setPredicate:predicate];
    return [self numberOfObjectsWithRequest:request];
}

- (void)registerObject:(RKEntity*)object {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:RKObjectStorageInternalExceptionReason userInfo:nil];
}

- (void)registerObjects:(NSArray*)objects {
    for (id object in objects)
        [self registerObject:object];
}

- (void)unregisterObject:(RKEntity*)object {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:RKObjectStorageInternalExceptionReason userInfo:nil];
}

- (void)unregisterObjects:(NSArray*)objects {
    for (id object in objects) {
        [self unregisterObject:object];
    }
}

- (BOOL)save {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:RKObjectStorageInternalExceptionReason userInfo:nil];
}

#pragma mark - Private

- (void)objectDidChange:(RKEntity*)object {
    if ([object isChangeObservationEnabled]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(objectDidChangeInternal:) object:object];
        [self performSelector:@selector(objectDidChangeInternal:) withObject:object afterDelay:0];
    }
}

- (void)objectDidChangeInternal:(RKEntity*)object {
    if ([[self delegate] respondsToSelector:@selector(entityStorage:didReceiveChangeNotificationForObject:userInfo:)] && [object isPersistent]) {
        [[self delegate] entityStorage:self didReceiveChangeNotificationForObject:object userInfo:nil];
    }
}

@end

@implementation RKEntityStorage (StringPredicates)

- (NSArray*)objectsWithPredicateString:(NSString*)predicateString class:(Class)class {
    NSPredicate* predicate = [NSPredicate predicateWithFormat:predicateString];
    return [self objectsWithPredicate:predicate class:class];
}

@end
