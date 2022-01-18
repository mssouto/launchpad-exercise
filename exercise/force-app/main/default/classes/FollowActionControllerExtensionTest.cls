@isTest
public class FollowActionControllerExtensionTest {
    private static final String test1 = 'Test 1';
    private static final String test2 = 'Test 2';
	@testSetup
    static void setup() {
        List<Case> casesToInsert = new List<Case>(); 
        casesToInsert.add(new Case(Priority='High', Origin='Phone',Status='New',Subject=test1));
        casesToInsert.add(new Case(Priority='Medium', Origin='Email',Status='New', Subject =test2));
    	insert casesToInsert;
    }
    
    @isTest
    static void itShouldFollowCase () {
        Id userId = UserInfo.getUserId();
        Case caseToFollow = [SELECT Id FROM Case WHERE Subject =:test1];
        PageReference page = Page.FollowAction;
        page.getParameters().put('recordId',caseToFollow.Id);
        Test.setCurrentPage(page);
        Test.startTest();
        	ApexPages.StandardController controller = new ApexPages.StandardController(caseToFollow);
       		FollowActionControllerExtension extension = new FollowActionControllerExtension(controller);
        	extension.followCase();
        	extension.followCase();
        Test.stopTest();
        System.assertEquals(1,[SELECT Id FROM EntitySubscription WHERE ParentId =:caseToFollow.Id AND SubscriberId =:userId].size(),'The case is not being followed');
    }
    @isTest
    static void itShouldNotFollowCase() {
        Boolean errorMessage = false;
        Id userId = UserInfo.getUserId();
        Case caseToFollow = [SELECT Id FROM Case WHERE Subject =:test2];
        PageReference page = Page.FollowAction;
        Test.setCurrentPage(page);
        Test.startTest();
        	ApexPages.StandardController controller = new ApexPages.StandardController(caseToFollow);
       		FollowActionControllerExtension extension = new FollowActionControllerExtension(controller);
            try {
               extension.followCase(); 
            } catch (Exception e) {
                errorMessage = true;
            }
        Test.stopTest();
        System.assert(errorMessage, 'It did not cause an error.');
        System.assertEquals(0,[SELECT Id FROM EntitySubscription WHERE ParentId =:caseToFollow.Id AND SubscriberId =:userId].size(),'The case is being followed');
    }
}