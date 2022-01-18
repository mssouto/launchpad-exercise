public with sharing class FollowActionControllerExtension {
    public Id recordId {get;set;}
    
    public FollowActionControllerExtension (ApexPages.StandardController controller) {
        recordId = ApexPages.currentPage().getParameters().get('recordId');
    }
    
    public PageReference followCase() {
        String title;
        String body;
        Case caseRecord = [SELECT CaseNumber 
                           FROM Case 
                           WHERE Id = :recordId];

        if (ObjectTableWithActionsHelper.followRecord(recordId)) {
            title ='Following Case';
            body = 'You are now following case #'+caseRecord.CaseNumber;
        } else {
            title ='Already following Case';
            body = 'You were already following case #'+caseRecord.CaseNumber; 
        }
        ObjectTableWithActionsHelper.sendCustomNotification(recordId, title, body);
       	return new PageReference('javascript:window.close()');
   	}
}
