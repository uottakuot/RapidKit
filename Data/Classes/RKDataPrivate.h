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

#import "Foundation+RKDataAdditions.h"
#import "RKEntity.h"
#import "RKEntityStorageOptions.h"
#import "RKEntityRelationship.h"
#import "RKEntityStorage.h"
#import "RKEntityRequest.h"

@interface RKEntityStorage ()

- (void)objectDidChange:(RKEntity*)object;

@end

@protocol RKEntityDataSource <NSObject>

@property (nonatomic, weak) RKEntity* entityInternal;
@property (nonatomic, weak) RKEntityStorage* entityStorageInternal;

- (id)valueForKeyInternal:(NSString*)key;
- (void)setValueInternal:(id)value forKey:(NSString*)key;
- (void)addObject:(RKEntity*)object toCollectionNamed:(NSString*)name;
- (void)removeObject:(RKEntity*)object fromCollectionNamed:(NSString*)name;

@end

@interface RKEntity ()

@property (nonatomic, strong) id<RKEntityDataSource> dataSourceInternal;
@property (nonatomic, getter = isRegistered, readonly) BOOL registered;
@property (nonatomic, strong) NSMutableArray* referencedObjects;

+ (Class)actualClass;
+ (void)prepareEntity;
+ (NSMutableArray*)relationships;
+ (RKEntityRelationship*)relationshipForClass:(Class)klass propertyName:(NSString*)name counterpartClass:(Class*)counterpartClass counterpartPropertyName:(NSString**)counterpartName;
+ (NSMutableDictionary*)propertyNamesBySelectors;
+ (NSString*)propertyNameForSelector:(SEL)selector;
- (id)initInternal;

@end

@interface RKEntityRelationship ()

@end

@interface RKEntityStorageOptions ()

@property (nonatomic, strong) NSArray* entityClasses;
@property (nonatomic, strong) NSMutableDictionary* entityNames;
@property (nonatomic, strong) NSMutableDictionary* transientPropertyNames;
@property (nonatomic, strong) NSMutableDictionary* indexedPropertyNames;
@property (nonatomic, strong) NSMutableDictionary* fullTextSearchPropertyNames;

@end
