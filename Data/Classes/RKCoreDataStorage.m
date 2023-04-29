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

#import <CoreData/CoreData.h>
#import <objc/runtime.h>
#import "RKCoreDataStorage.h"
#import "RKCoreDataStorageObject.h"
#import "RKDataPrivate.h"

@interface RKCoreDataStorage ()

@property (nonatomic, strong) NSURL* storeURL;
@property (nonatomic, strong) NSPersistentStoreCoordinator* coordinator;
@property (nonatomic, strong) NSManagedObjectModel* model;
@property (nonatomic, strong) NSManagedObjectContext* mainContext;
@property (nonatomic, strong) NSDictionary* classesByEntityName;
@property (nonatomic, strong) NSDictionary* entityNamesByClass;

@end

@implementation RKCoreDataStorage

- (id)initWithURL:(NSURL*)url options:(RKEntityStorageOptions*)options {
    self = [super init];
    if (self != nil) {
        // create or update model
        NSString* filePath = [url path];
        NSString* modelPath = [[filePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"mom"];
        BOOL modelExists = [[NSFileManager defaultManager] fileExistsAtPath:modelPath];
        NSManagedObjectModel* model = nil;
        if (modelExists) {
            model = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]];
        } else if (!options.shouldRecreateModelOnFailure) {
            model = [[NSManagedObjectModel alloc] init];
        }
        
        if (model == nil && options.shouldRecreateModelOnFailure) {
            model = [[NSManagedObjectModel alloc] init];
            
            if (modelExists) {
                modelExists = NO;
                [[NSFileManager defaultManager] removeItemAtPath:modelPath error:nil];
            }
        }
        
        // TODO:
        if (model == nil) {
            return nil;
        }
        
        // update and migrate if needed
        BOOL saveModel = YES;
        BOOL modelChanged = [self updateManagedModel:model withOptions:options];
        if (modelChanged && modelExists) {
            NSManagedObjectModel* oldModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]];
            NSString* newFilePath = [filePath stringByAppendingString:@"_new"];
            BOOL migrated = [[self class] migrateStorageFromSourceModel:oldModel filePath:filePath toDestinationModel:model filePath:newFilePath];
            saveModel = migrated;
            if (migrated) {
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                [[NSFileManager defaultManager] moveItemAtPath:newFilePath toPath:filePath error:nil];
            }
            [[NSFileManager defaultManager] removeItemAtPath:newFilePath error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:[newFilePath stringByAppendingString:@"-shm"] error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:[newFilePath stringByAppendingString:@"-wal"] error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:[filePath stringByAppendingString:@"-shm"] error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:[filePath stringByAppendingString:@"-wal"] error:nil];
        }
        
        if (saveModel) {
            [NSKeyedArchiver archiveRootObject:model toFile:modelPath];
        }
        
        [self setStoreURL:url];
        [self setModel:model];
        [self setCoordinator:[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model]];
        
        NSError* error = nil;
        [[self coordinator] addPersistentStoreWithType:NSSQLiteStoreType
                                         configuration:nil
                                                   URL:url
                                               options:[[self class] localStoreOptions]
                                                 error:&error];
        
#if DEBUG
        if (error != nil) {
            NSLog(@"An error occurred while opening Core Data store: %@", error);
        }
#endif
        
        NSManagedObjectContext* context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        [context setPersistentStoreCoordinator:[self coordinator]];
        [context setRetainsRegisteredObjects:NO];
        [self setMainContext:context];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coreDataObjectDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
}

- (NSArray*)objectsWithRequest:(RKEntityRequest*)request {
    NSString* entityName = [self entityNameForClass:[request entityClass]];
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self mainContext]];
    
    NSFetchRequest* coreDataRequest = [[NSFetchRequest alloc] init];
    [coreDataRequest setEntity:entityDescription];
    [coreDataRequest setPredicate:[request predicate]];
    [coreDataRequest setFetchLimit:[request limit]];
    [coreDataRequest setFetchOffset:[request offset]];
    [coreDataRequest setFetchBatchSize:[request batchSize]];
    [coreDataRequest setReturnsObjectsAsFaults:NO];
    
    NSArray* managedObjects = [[self mainContext] executeFetchRequest:coreDataRequest error:nil];
    NSMutableArray* objects = [NSMutableArray arrayWithCapacity:[managedObjects count]];
    for (RKCoreDataStorageObject* managedObject in managedObjects) {
        RKEntity* object = [managedObject entityInternal];
        if (object == nil) {
            [managedObject setEntityStorageInternal:self];
            object = [managedObject createEntityInternal];
        }
        [objects addObject:object];
    }
    
    return objects;
}

- (NSInteger)numberOfObjectsWithRequest:(RKEntityRequest*)request {
    NSString* entityName = [self entityNameForClass:[request entityClass]];
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self mainContext]];
    
    NSFetchRequest* coreDataRequest = [[NSFetchRequest alloc] init];
    [coreDataRequest setEntity:entityDescription];
    [coreDataRequest setPredicate:[request predicate]];
    [coreDataRequest setFetchLimit:[request limit]];
    [coreDataRequest setFetchOffset:[request offset]];
    [coreDataRequest setFetchBatchSize:[request batchSize]];
    
    NSInteger count = [[self mainContext] countForFetchRequest:coreDataRequest error:nil];
    if (count == NSNotFound) {
        count = 0;
    }
    
    return count;
}

- (void)registerObject:(RKEntity*)object {
    if (object != nil && [object dataSourceInternal] == nil) {
        [object willRegister];
        
        if ([object isChangeObservationEnabled] && [[self delegate] respondsToSelector:@selector(entityStorage:willRegisterObject:)]) {
            [[self delegate] entityStorage:self willRegisterObject:object];
        }
        
        NSString* entityName = [self entityNameForClass:[object class]];
        RKCoreDataStorageObject* managedObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:[self mainContext]];
        [managedObject setEntityInternal:object];
        [managedObject setEntityStorageInternal:self];
        
        [self copyDataFromObject:object toManagedObject:managedObject];
        [object setDataSourceInternal:managedObject];
        [object didRegister];
        
        if ([object isChangeObservationEnabled] && [[self delegate] respondsToSelector:@selector(entityStorage:didRegisterObject:)]) {
            [[self delegate] entityStorage:self didRegisterObject:object];
        }
    }
}

- (void)unregisterObject:(RKEntity*)object {
    if ([object dataSourceInternal] != nil) {
        [object willUnregister];
        
        if ([object isChangeObservationEnabled] && [[self delegate] respondsToSelector:@selector(entityStorage:willUnregisterObject:)]) {
            [[self delegate] entityStorage:self willUnregisterObject:object];
        }
        
        RKCoreDataStorageObject* managedObject = (RKCoreDataStorageObject*)[object dataSourceInternal];
        if (managedObject != nil) {
            [[self mainContext] deleteObject:managedObject];
            [object setDataSourceInternal:nil];
            [self copyDataFromManagedObject:managedObject toObject:object];
            [object didUnregister];
            
            // Notify delegate about deleted objects (didUnregister...) in context notifications
        }
    }
}

- (BOOL)save {
    NSError* error = nil;
    [[self mainContext] save:&error];
    
    if (error != nil) {
#if DEBUG
        NSLog(@"An error occurred while saving the storage: %@", error);
#endif
    }
    
    return error == nil;
}

#pragma mark - Private

// Not used
+ (BOOL)migrateStorageFromSourceModel:(NSManagedObjectModel*)sourceModel filePath:(NSString*)sourceFilePath
                   toDestinationModel:(NSManagedObjectModel*)destModel filePath:(NSString*)destFilePath {
    NSMappingModel* mappingModel = [NSMappingModel inferredMappingModelForSourceModel:sourceModel destinationModel:destModel error:nil];
    if (mappingModel == nil) {
        return NO;
    }
    
    NSMigrationManager* migrationManager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel destinationModel:destModel];
    NSError* error = nil;
    BOOL migrated = [migrationManager migrateStoreFromURL:[NSURL fileURLWithPath:sourceFilePath]
                                                     type:NSSQLiteStoreType
                                                  options:nil
                                         withMappingModel:mappingModel
                                         toDestinationURL:[NSURL fileURLWithPath:destFilePath]
                                          destinationType:NSSQLiteStoreType
                                       destinationOptions:nil
                                                    error:&error];
    
#if DEBUG
    if (error != nil) {
        NSLog(@"Migration error: %@.", error);
    } else {
        NSLog(@"Storage migrated.");
    }
#endif
    
    return migrated;
}

+ (NSInteger)countWithRelationshipModifier:(RKEntityModifier)modifier inverse:(BOOL)inverse {
    switch (modifier) {
        case RKEntityModifierOneToOne:
            return 1;
        
        case RKEntityModifierOneToMany:
            return (inverse ? 1 : 0);
        
        case RKEntityModifierManyToOne:
            return (inverse ? 0 : 1);
        
        case RKEntityModifierManyToMany:
            return 0;
        
        default:
            return 0;
    }
}

+ (NSDeleteRule)deleteRuleWithValue:(RKEntityDeleteRule)value {
    switch (value) {
        case RKEntityDeleteRuleCascade:
            return NSCascadeDeleteRule;
        
        case RKEntityDeleteRuleDeny:
            return NSDenyDeleteRule;
        
        case RKEntityDeleteRuleNullify:
            return NSNullifyDeleteRule;
        
        default:
            return NSNoActionDeleteRule;
    }
}

+ (NSDictionary*)localStoreOptions {
    NSMutableDictionary* options = [NSMutableDictionary dictionary];
    [options setObject:@{@"synchronous": @"NORMAL"} forKey:NSSQLitePragmasOption];
    [options setObject:@YES forKey:NSMigratePersistentStoresAutomaticallyOption];
    [options setObject:@YES forKey:NSInferMappingModelAutomaticallyOption];
    return options;
}

/// Returns YES if the model has been changed.
- (BOOL)updateManagedModel:(NSManagedObjectModel*)model withOptions:(RKEntityStorageOptions*)options {
    __block BOOL modelChanged = NO;
    
    NSMutableDictionary* entityDescriptionsByClassName = [NSMutableDictionary dictionary];
    [self setClassesByEntityName:[NSMutableDictionary dictionary]];
    [self setEntityNamesByClass:[NSMutableDictionary dictionary]];
    
    // create entity descriptions if needed
    for (Class class in [options entityClasses]) {
        NSString* classOriginalName = NSStringFromClass(class);
        NSString* modifiedClassName = NSStringFromClass([class actualClass]);
        NSString* entityName = [[options entityNames] objectForKey:classOriginalName];
        
        NSEntityDescription* entityDescription = [[model entitiesByName] objectForKey:entityName];
        if (entityDescription == nil) {
            entityDescription = [[NSEntityDescription alloc] init];
            [entityDescription setName:entityName];
            [entityDescription setManagedObjectClassName:@"RKCoreDataStorageObject"];
            
            modelChanged = YES;
        }
        
        [entityDescriptionsByClassName setObject:entityDescription forKey:classOriginalName];
        
        [(NSMutableDictionary*)[self classesByEntityName] setObject:NSClassFromString(modifiedClassName) forKey:entityName];
        [(NSMutableDictionary*)[self entityNamesByClass] setObject:entityName forKey:[NSValue valueWithPointer:(__bridge const void *)(class)]];
        [(NSMutableDictionary*)[self entityNamesByClass] setObject:entityName forKey:[NSValue valueWithPointer:(__bridge const void *)([class actualClass])]];
    }
    
    if (!modelChanged) {
        // check if any entity is removed
        NSArray* newEntities = [entityDescriptionsByClassName allValues];
        for (NSEntityDescription* entityDescription in [[model entitiesByName] allValues]) {
            if (![newEntities containsObject:entityDescription]) {
                modelChanged = YES;
                break;
            }
        }
    }
    
    NSMutableDictionary* entityPropertiesByClassName = [NSMutableDictionary dictionary];
    
    // add or update entity attributes
    for (Class class in [options entityClasses]) {
        NSString* className = NSStringFromClass(class);
        NSEntityDescription* entityDescription = [entityDescriptionsByClassName objectForKey:className];
        NSMutableArray* entityProperties = [NSMutableArray array];
        
        [entityPropertiesByClassName setObject:entityProperties forKey:className];
        
        [class enumeratePropertiesHierarchically:YES withBlock:^(RKPropertyInfo info) {
            if (info.ownerClass == [RKEntity class] || info.isReadonly) {
                return;
            }
            
            NSAttributeType attributeType = NSUndefinedAttributeType;
            switch (info.encodedTypeCharacter) {
                case 'c':
                case 'B':
                    attributeType = NSInteger16AttributeType;
                    break;
                
                case 's':
                    attributeType = NSInteger16AttributeType;
                    break;
                
                case 'i':
                    attributeType = NSInteger32AttributeType;
                    break;
                
                case 'l':
                case 'q':
                    attributeType = NSInteger64AttributeType;
                    break;
                
                case 'f':
                    attributeType = NSFloatAttributeType;
                    break;
                
                case 'd':
                    attributeType = NSDoubleAttributeType;
                    break;
                
                    // TODO:
                default:
                    break;
            }
            
            if ([info.typeClass isSubclassOfClass:[NSDecimalNumber class]]) {
                attributeType = NSDecimalAttributeType;
            } else if ([info.typeClass isSubclassOfClass:[NSNumber class]]) {
                attributeType = NSDoubleAttributeType;
            } else if ([info.typeClass isSubclassOfClass:[NSString class]]) {
                attributeType = NSStringAttributeType;
            } else if ([info.typeClass isSubclassOfClass:[NSDate class]]) {
                attributeType = NSDateAttributeType;
            } else if ([info.typeClass isSubclassOfClass:[NSData class]]) {
                attributeType = NSBinaryDataAttributeType;
            }
            
            if (attributeType != NSUndefinedAttributeType) {
                NSAttributeDescription* attributeDescription = [[entityDescription attributesByName] objectForKey:info.name];
                if (attributeDescription == nil) {
                    attributeDescription = [[NSAttributeDescription alloc] init];
                    [attributeDescription setName:info.name];
                    [attributeDescription setAttributeType:attributeType];
                    
                    modelChanged = YES;
                }
                
                BOOL isTransient = [[[options transientPropertyNames] objectForKey:className] containsObject:info.name];
                [attributeDescription setTransient:isTransient];
                [attributeDescription setOptional:YES]; // TODO:
                [entityProperties addObject:attributeDescription];
            }
        }];
    }
    
    // process relationships
    for (RKEntityRelationship* relationship in [RKEntity relationships]) {
        NSString* firstClassName = NSStringFromClass([relationship firstClass]);
        NSString* secondClassName = NSStringFromClass([relationship secondClass]);
        
        NSEntityDescription* firstEntityDescription = [entityDescriptionsByClassName objectForKey:firstClassName];
        NSEntityDescription* secondEntityDescription = [entityDescriptionsByClassName objectForKey:secondClassName];
        
        NSRelationshipDescription* firstRelationshipDescription = [[firstEntityDescription relationshipsByName] objectForKey:[relationship firstPropertyName]];
        if (firstRelationshipDescription == nil) {
            firstRelationshipDescription = [[NSRelationshipDescription alloc] init];
            [firstRelationshipDescription setName:[relationship firstPropertyName]];
            [firstRelationshipDescription setDestinationEntity:secondEntityDescription];
            
            modelChanged = YES;
        }
        [firstRelationshipDescription setMaxCount:[[self class] countWithRelationshipModifier:[relationship modifier] inverse:NO]];
        [firstRelationshipDescription setDeleteRule:[[self class] deleteRuleWithValue:[relationship secondDeleteRule]]];
        
        [[entityPropertiesByClassName objectForKey:firstClassName] addObject:firstRelationshipDescription];
        
        NSRelationshipDescription* secondRelationshipDescription = [[secondEntityDescription relationshipsByName] objectForKey:[relationship secondPropertyName]];
        if (secondRelationshipDescription == nil) {
            secondRelationshipDescription = [[NSRelationshipDescription alloc] init];
            [secondRelationshipDescription setName:[relationship secondPropertyName]];
            [secondRelationshipDescription setDestinationEntity:firstEntityDescription];
            
            modelChanged = YES;
        }
        [secondRelationshipDescription setMaxCount:[[self class] countWithRelationshipModifier:[relationship modifier] inverse:YES]];
        [secondRelationshipDescription setDeleteRule:[[self class] deleteRuleWithValue:[relationship firstDeleteRule]]];
        
        [[entityPropertiesByClassName objectForKey:secondClassName] addObject:secondRelationshipDescription];
        
        [secondRelationshipDescription setInverseRelationship:firstRelationshipDescription];
        [firstRelationshipDescription setInverseRelationship:secondRelationshipDescription];
    }
    
    for (NSString* className in [entityPropertiesByClassName allKeys]) {
        NSEntityDescription* entityDescription = [entityDescriptionsByClassName objectForKey:className];
        NSArray* entityProperties = [entityPropertiesByClassName objectForKey:className];
        
        if (!modelChanged) {
            // check if any property is removed
            for (NSPropertyDescription* property in [entityDescription properties]) {
                if (![entityProperties containsObject:property]) {
                    modelChanged = YES;
                    break;
                }
            }
        }
        
        [entityDescription setProperties:entityProperties];
    }
    
    [model setEntities:[entityDescriptionsByClassName allValues]];
    
    return modelChanged;
}

- (NSString*)entityNameForClass:(Class)class {
    return [[self entityNamesByClass] objectForKey:[NSValue valueWithPointer:(__bridge const void*)(class)]];
}

- (void)copyDataFromObject:(id)object toManagedObject:(RKCoreDataStorageObject*)managedObject {
    [[object class] enumeratePropertiesHierarchically:YES withBlock:^(RKPropertyInfo info) {
        if (info.ownerClass == [RKEntity class] || info.isReadonly) {
            return;
        }
        
        id value = [object valueForKey:info.name];
        if ([info.typeClass isSubclassOfClass:[NSArray class]]) {
            for (id item in value) {
                [managedObject addObject:item toCollectionNamed:info.name];
            }
        } else if ([info.typeClass isSubclassOfClass:[RKEntity class]]) {
            [managedObject setValueInternal:value forKey:info.name];
        } else {
            [managedObject setValue:value forKey:info.name];
        }
    }];
}

- (void)copyDataFromManagedObject:(RKCoreDataStorageObject*)managedObject toObject:(id)object {
    // TODO:
}

#pragma mark - Callbacks

- (void)coreDataObjectDidChange:(NSNotification*)notification {
    NSArray* deletedManagedObjects = [[notification userInfo] objectForKey:NSDeletedObjectsKey];
    for (RKCoreDataStorageObject* managedObject in deletedManagedObjects) {
        if (([managedObject entityInternal] == nil || [[managedObject entityInternal] isChangeObservationEnabled]) && [[self delegate] respondsToSelector:@selector(entityStorage:didUnregisterObjectOfClass:withProperties:)]) {
            NSMutableDictionary* properties = [NSMutableDictionary dictionary];
            for (NSString* name in [self propertyNamesForNotifications]) {
                id value = nil;
                id entity = [managedObject entityInternal];
                SEL selector = NSSelectorFromString(name);
                
                if (entity != nil && [entity respondsToSelector:selector]) {
                    value = [entity valueForKey:name];
                } else if ([managedObject respondsToSelector:selector]) {
                    value = [managedObject valueForKey:name];
                }
                
                if (value != nil) {
                    [properties setObject:value forKey:name];
                }
            }
            
            [[managedObject entityInternal] setDataSourceInternal:nil];
            [managedObject setEntityInternal:nil];
            [managedObject setEntityStorageInternal:nil];
            
            for (NSString* name in [self propertyNamesForNotifications]) {
                SEL selector = NSSelectorFromString(name);
                if ([managedObject respondsToSelector:selector]) {
                    id value = [managedObject valueForKey:name];
                    if (value != nil) {
                        [properties setObject:value forKey:name];
                    }
                }
            }
            
            Class objectClass = [[self classesByEntityName] objectForKey:[[managedObject entity] name]];
            [[self delegate] entityStorage:self didUnregisterObjectOfClass:objectClass withProperties:properties];
        }
    }
}

@end
