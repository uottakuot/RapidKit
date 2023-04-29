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

#import "RKCoreDataStorageObjectArray.h"
#import "RKCoreDataStorageObject.h"
#import "RKDataPrivate.h"

@interface RKCoreDataStorageObjectArray ()

@property (nonatomic, weak) RKCoreDataStorageObject* object;
@property (nonatomic, strong) NSString* keyPath;
@property (nonatomic, strong) NSMutableArray* buffer;

@end

@implementation RKCoreDataStorageObjectArray

- (id)initWithManagedObject:(RKCoreDataStorageObject*)object collectionKeyPath:(NSString*)keyPath {
    self = [super init];
    if (self != nil) {
        [self setObject:object];
        [self setKeyPath:keyPath];
        
        [object addObserver:self forKeyPath:keyPath options:0 context:NULL];
    }
    
    return self;
}

- (void)dealloc {
    [[self object] removeObserver:self forKeyPath:[self keyPath]];
}

- (NSArray*)filteredArrayUsingPredicate:(NSPredicate*)predicate {
    NSArray* filteredObjects = [[[[self object] mutableSetValueForKey:[self keyPath]] filteredSetUsingPredicate:predicate] allObjects];
    NSMutableArray* entities = [NSMutableArray arrayWithCapacity:[filteredObjects count]];
    
    for (RKCoreDataStorageObject* managedObject in filteredObjects) {
        [managedObject setEntityStorageInternal:[[self object] entityStorageInternal]];
        RKEntity* object = [managedObject createEntityInternal];
        [entities addObject:object];
    }
    
    return entities;
}

#pragma mark - NSArray

- (NSUInteger)count {
	return [[[self object] mutableSetValueForKeyPath:[self keyPath]] count];
}

- (id)objectAtIndex:(NSUInteger)index {
    return [[[self buffer] objectAtIndex:index] createEntityInternal];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
    [self setBuffer:nil];
}

#pragma mark - Private

- (NSMutableArray*)buffer {
    if (_buffer == nil) {
        NSSet* set = [[self object] mutableSetValueForKeyPath:[self keyPath]];
        NSMutableArray* array = [NSMutableArray arrayWithCapacity:[set count]];
        [set enumerateObjectsUsingBlock:^(id managedObject, BOOL* stop) {
            [managedObject setEntityStorageInternal:[[self object] entityStorageInternal]];
            [array addObject:managedObject];
        }];
        [self setBuffer:array];
    }
    
    return _buffer;
}

@end
