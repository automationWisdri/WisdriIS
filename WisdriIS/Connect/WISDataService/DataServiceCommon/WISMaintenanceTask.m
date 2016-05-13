//
//  WISMaintenanceTask.m
//  WISConnect
//
//  Created by Jingwei Wu on 2/21/16.
//  Copyright © 2016 Jingwei Wu. All rights reserved.
//

#import "WISMaintenanceTask.h"
#import "WISUser.h"
#import "WISMaintenancePlan.h"
#import "WISMaintenanceTaskRating.h"

NSString *const maintenanceTaskIDEncodingID = @"maintenanceTaskID";
NSString *const maintenanceTaskNameEncodingID = @"maintenanceTaskName";
NSString *const maintenanceTaskStateEncodingID = @"maintenanceTaskState";
NSString *const maintenanceTaskPassedStatesEncodingID = @"maintenanceTaskPassedStates";
NSString *const maintenanceTaskTypeEncodingID = @"maintenanceTaskType";
NSString *const maintenanceTaskProcessSegmentNameEncodingID = @"maintenanceTaskProcessSegmentName";
NSString *const maintenanceTaskCreatorEncodingID = @"maintenanceTaskCreator";
NSString *const maintenanceTaskPersonInChargeEncodingID = @"maintenanceTaskPersonInCharge";
NSString *const maintenanceTaskApplicationContentEncodingID = @"maintenanceTaskApplicationContent";
NSString *const maintenanceTaskDescriptionEncodingID = @"maintenanceTaskDescription";
NSString *const maintenanceTaskCreatedDateTimeEncodingID = @"maintenanceTaskCreatedDateTime";
NSString *const maintenancePlansEncodingID = @"maintenancePlans";
NSString *const maintenanceTaskRatingEncodingID = @"maintenanceTaskRating";
NSString *const maintenanceTaskValidOperationsEncodingID = @"maintenanceTaskValidOperations";
NSString *const maintenanceTaskImagesInfoEncodingID = @"maintenanceTaskImagesInfo";


@interface WISMaintenanceTask ()

@end

@implementation WISMaintenanceTask

-(instancetype)init {
    return [self initWithTaskID:@""
                       taskName:@""
                      taskState:@""
               taskPassedStates:[NSMutableArray array]
                       taskType:MaintenanceTaskUnclassified
             processSegmentName:@""
                        creator:[[WISUser alloc]init]
                 personInCharge:[[WISUser alloc]init]
         taskApplicationContent:@""
                taskDescription:@""
                createdDateTime:[NSDate date]
                maintenancePlans:[NSMutableArray array]
                     taskRating:[[WISMaintenanceTaskRating alloc]init]
                validOperations:[NSDictionary dictionary]
                  andImagesInfo:[NSMutableDictionary dictionary]];
}


- (instancetype)initWithTaskID:(NSString *) taskID
                      taskName:(NSString *) taskName
                     taskState:(NSString *) state
              taskPassedStates:(NSMutableArray<WISMaintenanceTaskState *> *)passedStates
                      taskType:(MaintenanceTaskType) taskType
            processSegmentName:(NSString *) processSegmentName
                       creator:(WISUser *) creator
                personInCharge:(WISUser *) personInCharge
        taskApplicationContent:(NSString *) taskApplicationContent
               taskDescription:(NSString *) description
               createdDateTime:(NSDate *) createdDateTime
              maintenancePlans:(NSMutableArray<WISMaintenancePlan *> *) maintenancePlans
                    taskRating:(WISMaintenanceTaskRating *) taskRating
               validOperations:(NSDictionary<NSString *, NSString *> *) validOperations
                 andImagesInfo:(NSMutableDictionary<NSString *, WISFileInfo *> *) imagesInfo {
    if (self = [super init]) {
        _taskID = taskID;
        _taskName = taskName;
        _state = state;
        _passedStates = passedStates;
        _taskType = taskType;
        _processSegmentName = processSegmentName;
        _creator = creator;
        _personInCharge = personInCharge;
        _taskApplicationContent = taskApplicationContent;
        _taskDescription = description;
        _createdDateTime = createdDateTime;
        _maintenancePlans = maintenancePlans;
        _taskRating = taskRating;
        _validOperations = [NSMutableDictionary dictionaryWithDictionary:validOperations];
        _imagesInfo = [NSMutableDictionary dictionaryWithDictionary:imagesInfo];
    }
    return self;
}


- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _taskID = (NSString *)[aDecoder decodeObjectForKey:maintenanceTaskIDEncodingID];
        _taskName = (NSString *)[aDecoder decodeObjectForKey:maintenanceTaskNameEncodingID];
        _state = (NSString *)[aDecoder decodeObjectForKey:maintenanceTaskStateEncodingID];
        _passedStates = [NSMutableArray arrayWithArray:(NSArray *)[aDecoder decodeObjectForKey:maintenanceTaskPassedStatesEncodingID]];
        _taskType = (MaintenanceTaskType)[aDecoder decodeIntegerForKey:maintenanceTaskTypeEncodingID];
        _processSegmentName = (NSString *)[aDecoder decodeObjectForKey:maintenanceTaskProcessSegmentNameEncodingID];
        _creator = (WISUser *)[aDecoder decodeObjectForKey:maintenanceTaskCreatorEncodingID];
        _personInCharge = (WISUser *)[aDecoder decodeObjectForKey:maintenanceTaskPersonInChargeEncodingID];
        _taskApplicationContent = (NSString *)[aDecoder decodeObjectForKey:maintenanceTaskApplicationContentEncodingID];
        _taskDescription = (NSString *)[aDecoder decodeObjectForKey:maintenanceTaskDescriptionEncodingID];
        _createdDateTime = (NSDate *)[aDecoder decodeObjectForKey:maintenanceTaskCreatedDateTimeEncodingID];
        _maintenancePlans = [NSMutableArray arrayWithArray:(NSArray *)[aDecoder decodeObjectForKey:maintenancePlansEncodingID]];
        _taskRating = (WISMaintenanceTaskRating *)[aDecoder decodeObjectForKey:maintenanceTaskRatingEncodingID];
        _validOperations = (NSDictionary<NSString *, NSString *> *)[aDecoder decodeObjectForKey:maintenanceTaskValidOperationsEncodingID];
        _imagesInfo = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)[aDecoder decodeObjectForKey:maintenanceTaskImagesInfoEncodingID]];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_taskID forKey:maintenanceTaskIDEncodingID];
    [aCoder encodeObject:_taskName forKey:maintenanceTaskNameEncodingID];
    [aCoder encodeObject:_state forKey:maintenanceTaskStateEncodingID];
    [aCoder encodeObject:_passedStates forKey:maintenanceTaskPassedStatesEncodingID];
    [aCoder encodeInteger:_taskType forKey:maintenanceTaskTypeEncodingID];
    [aCoder encodeObject:_processSegmentName forKey:maintenanceTaskProcessSegmentNameEncodingID];
    [aCoder encodeObject:_creator forKey:maintenanceTaskCreatorEncodingID];
    [aCoder encodeObject:_personInCharge forKey:maintenanceTaskPersonInChargeEncodingID];
    [aCoder encodeObject:_taskApplicationContent forKey:maintenanceTaskApplicationContentEncodingID];
    [aCoder encodeObject:_taskDescription forKey:maintenanceTaskDescriptionEncodingID];
    [aCoder encodeObject:_createdDateTime forKey:maintenanceTaskCreatedDateTimeEncodingID];
    [aCoder encodeObject:_maintenancePlans forKey:maintenancePlansEncodingID];
    [aCoder encodeObject:_taskRating forKey:maintenanceTaskRatingEncodingID];
    [aCoder encodeObject:_validOperations forKey:maintenanceTaskValidOperationsEncodingID];
    [aCoder encodeObject:_imagesInfo forKey:maintenanceTaskImagesInfoEncodingID];
}


- (id) copyWithZone:(NSZone *)zone {
    WISMaintenanceTask *task = [[[self class] allocWithZone:zone] initWithTaskID:[self.taskID copy]
                                                                        taskName:[self.taskName copy]
                                                                       taskState:[self.state copy]
                                                                taskPassedStates:[self.passedStates mutableCopy]
                                                                        taskType:_taskType
                                                              processSegmentName:[self.processSegmentName copy]
                                                                         creator:[self.creator copy]
                                                                  personInCharge:[self.personInCharge copy]
                                                          taskApplicationContent:[self.taskApplicationContent copy]
                                                                 taskDescription:[self.taskDescription copy]
                                                                 createdDateTime:[self.createdDateTime copy]
                                                                 maintenancePlans:[self.maintenancePlans mutableCopy]
                                                                      taskRating:[self.taskRating copy]
                                                                 validOperations:[self.validOperations copy]
                                                                   andImagesInfo:[self.imagesInfo copy]];
    
    return task;
}

- (void) appendImagsInfo:(NSMutableDictionary<NSString *, WISFileInfo *> *) imagesInfo {
    [self.imagesInfo addEntriesFromDictionary:imagesInfo];
    self.imagesInfo = self.imagesInfo;
}

@end
