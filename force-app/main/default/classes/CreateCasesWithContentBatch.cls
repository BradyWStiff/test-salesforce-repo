global class CreateCasesWithContentBatch implements Database.Batchable<sObject> {
    private Id originalCaseId;
    private Integer totalCases;

    public CreateCasesWithContentBatch(Id originalCaseId, Integer totalCases) {
        this.originalCaseId = originalCaseId;
        this.totalCases = totalCases;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
         System.debug('Starting batch job');
        // We're not using the original case in the start method, but it's required for logic consistency
        return Database.getQueryLocator([SELECT Id FROM Case WHERE Id = :originalCaseId LIMIT 1]);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        System.debug('Executing batch with scope size: ' + scope.size());
        if (scope.isEmpty()) {
            System.debug('Scope is empty, exiting execute method.');
            return;
        }
        List<Case> newCases = new List<Case>();
        for (Integer i = 0; i < totalCases; i++) {
            newCases.add(new Case(Subject = 'Test Case For Test # ' + i, Description = 'This is a test case.'));
        }
        insert newCases;

        List<ContentVersion> newContentVersions = new List<ContentVersion>();
        Blob dummyContent = Blob.valueOf('Test file content');

        for (Case c : newCases) {
            ContentVersion newContentVersion = new ContentVersion();
            newContentVersion.Title = 'Test File for ' + c.Subject;
            newContentVersion.PathOnClient = 'TestFileForCase' + c.Id + '.txt';
            newContentVersion.VersionData = dummyContent;
            newContentVersion.Origin = 'H'; // 'H' for internal users
            newContentVersions.add(newContentVersion);
        }

        insert newContentVersions;

        List<ContentDocumentLink> newContentDocumentLinks = new List<ContentDocumentLink>();
        for (Integer i = 0; i < newContentVersions.size(); i++) {
            Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :newContentVersions[i].Id].ContentDocumentId;

            ContentDocumentLink newCdl = new ContentDocumentLink(
                LinkedEntityId = newCases[i].Id,
                ContentDocumentId = contentDocumentId,
                ShareType = 'V'
            );
            newContentDocumentLinks.add(newCdl);
        }

        insert newContentDocumentLinks;
    }

    global void finish(Database.BatchableContext BC) {
        // Post-processing if necessary
    }
}