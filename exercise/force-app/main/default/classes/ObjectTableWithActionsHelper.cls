public with sharing class ObjectTableWithActionsHelper {
    @AuraEnabled
    public static List<SObject> fetchData( String objectName,
                                            String selectFields,
                                            String whereCondition ){
        String queryString = 'SELECT Id,' + selectFields +' FROM '+ objectName ;
        if (String.isNotBlank(whereCondition)) {
            queryString = queryString +' WHERE '+ whereCondition;
        }
        List<sObject> sobjList = Database.query(queryString);
        return sobjList;
    }

    public static void sendCustomNotification (Id recordId, String title, String description) {
        Id userId = UserInfo.getUserId();
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        CustomNotificationType notificationType = [SELECT Id, DeveloperName 
                                                   FROM CustomNotificationType 
                                                   WHERE DeveloperName='Follow_Action'];  
        notification.setTitle(title);
        notification.setBody(description);
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(recordId);
        
        Set<String> recipientUserId = new Set<String>();
        recipientUserId.add(userId);
        try {
            notification.send(recipientUserId);
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean followRecord (Id recordId) {
        Id userId = UserInfo.getUserId();
        List<EntitySubscription> listEntitySub = new List<EntitySubscription>();
        listEntitySub = [SELECT Id 
                         FROM EntitySubscription 
                         WHERE ParentId =: recordId AND SubscriberId =:userId];
        Boolean isNotFollowingAlready = listEntitySub.size() == 0;
        if (isNotFollowingAlready) {
            EntitySubscription entitySub = new EntitySubscription(ParentId = recordId, 
                                                                  SubscriberId = userId);
            try {
                
                insert entitySub;
                
            } catch (Exception e) {
                
                System.debug('Problem following record ' + e.getMessage());
            } 
        } 
        return isNotFollowingAlready;
    }
    @AuraEnabled
    public static Boolean unfollowRecord (Id recordId) {
        Id userId = UserInfo.getUserId();
        List<EntitySubscription> listEntitySub = new List<EntitySubscription>();
        listEntitySub = [SELECT Id 
                         FROM EntitySubscription 
                         WHERE ParentId =: recordId AND SubscriberId =:userId];
        Boolean isFollowingAlready = listEntitySub.size() > 0;
        if (isFollowingAlready) {
            try {
                
                delete listEntitySub;
                
            } catch (Exception e) {
                
                System.debug('Problem unfollowing record ' + e.getMessage());
            } 
        } 
        return isFollowingAlready;
    }
}