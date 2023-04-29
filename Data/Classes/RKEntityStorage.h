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

#import <Foundation/Foundation.h>

@class RKEntity, RKEntityStorage, RKEntityStorageOptions, RKEntityRequest;

extern NSString* const RKEntityStorageInfoCollectionChangedKey;

@protocol RKEntityStorageDelegate <NSObject>

@optional
- (void)entityStorage:(RKEntityStorage*)storage willRegisterObject:(id)object;
- (void)entityStorage:(RKEntityStorage*)storage didRegisterObject:(id)object;
- (void)entityStorage:(RKEntityStorage*)storage willUnregisterObject:(id)object;
- (void)entityStorage:(RKEntityStorage*)storage didUnregisterObjectOfClass:(Class)objectClass withProperties:(NSDictionary*)properties;
- (void)entityStorage:(RKEntityStorage*)storage didReceiveChangeNotificationForObject:(id)object userInfo:(NSDictionary*)userInfo;

@end

typedef NS_ENUM(NSInteger, RKEntityStorageType) {
    RKEntityStorageTypeKeyedArchive = 0, // TODO: not implemented
    RKEntityStorageTypeCoreData = 1
};

@interface RKEntityStorage : NSObject

@property (nonatomic, weak) id<RKEntityStorageDelegate> delegate;
@property (nonatomic, readonly) RKEntityStorageType storageType;
@property (nonatomic, strong) NSArray* propertyNamesForNotifications;

- (id)initWithURL:(NSURL*)url type:(RKEntityStorageType)type options:(RKEntityStorageOptions*)options;
- (NSArray*)objectsWithRequest:(RKEntityRequest*)request;
- (NSArray*)objectsWithPredicate:(NSPredicate*)predicate class:(Class)klass;
- (NSInteger)numberOfObjectsWithRequest:(RKEntityRequest*)request;
- (NSInteger)numberOfObjectsWithPredicate:(NSPredicate*)predicate class:(Class)klass;
- (void)registerObject:(RKEntity*)object;
- (void)registerObjects:(NSArray*)objects;
- (void)unregisterObject:(RKEntity*)object;
- (void)unregisterObjects:(NSArray*)objects;
- (BOOL)save;

@end

@interface RKEntityStorage (StringPredicates)

- (NSArray*)objectsWithPredicateString:(NSString*)predicate class:(Class)klass;

@end
