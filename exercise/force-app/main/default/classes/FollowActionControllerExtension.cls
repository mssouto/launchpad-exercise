public with sharing class FollowActionControllerExtension {
    public Id recordId {get;set;}
    
    public FollowActionControllerExtension (ApexPages.StandardController controller) {
        recordId = ApexPages.currentPage().getParameters().get('recordId');
    }
    
    public PageReference followCase() {
        Id userId =UserInfo.getUserId();
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        Case caseRecord = [SELECT CaseNumber 
                           FROM Case 
                           WHERE Id = :recordId];
        
        // following case record
       	List<EntitySubscription> listEntitySub = new List<EntitySubscription>();
        listEntitySub = [SELECT Id 
                         FROM EntitySubscription 
                         WHERE ParentId =: recordId AND SubscriberId =:userId];
        if (listEntitySub.size() == 0) {
            EntitySubscription entitySub = new EntitySubscription(ParentId = recordId, 
                                                                  SubscriberId = userId);
            try {
                
                insert entitySub;
                
            } catch (Exception e) {
                
            	System.debug('Problem following case ' + e.getMessage());
        	}
            
            notification.setTitle('Following Case');
        	notification.setBody('You are now following case #'+caseRecord.CaseNumber);
            
        } else {
            
            notification.setTitle('You already follow this Case');
        	notification.setBody('You were already following case #'+caseRecord.CaseNumber);
            
        }
        
        // sending notification to user
        CustomNotificationType notificationType = [SELECT Id, DeveloperName 
                                                   FROM CustomNotificationType 
                                        		   WHERE DeveloperName='Follow_Case_Action'];  
        
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
       	return new PageReference('javascript:window.close()');
   }
 
}