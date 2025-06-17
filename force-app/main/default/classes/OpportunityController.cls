public with sharing class OpportunityController {
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getRelatedOpportunities(Id accountId) {
        return [
            SELECT Id, Name, CloseDate, StageName, Amount
            FROM Opportunity
            WHERE AccountId = :accountId
            ORDER BY CloseDate DESC
        ];
    }

    @AuraEnabled
    public static List<Opportunity> insertOpportunities(List<Map<String, Object>> opportunitiesData, String AccountId) {
        List<Opportunity> newOpps = new List<Opportunity>();
        System.debug('opportunitiesData' + opportunitiesData);
        for (Map<String, Object> oppData : opportunitiesData) {
            Opportunity newOpp = new Opportunity();
            newOpp.Name = (String)oppData.get('Name');
            newOpp.CloseDate = Date.valueOf((String)oppData.get('CloseDate'));
            newOpp.StageName = (String)oppData.get('StageName');
            newOpp.Amount = Decimal.valueOf((String)oppData.get('Amount'));
            // Assuming AccountId is also passed and is required for the relationship
            newOpp.AccountId = AccountId;
            System.debug('new Opp:' + newOpp);
            newOpps.add(newOpp);
        }
        
        try {
            insert newOpps;
        } catch (DmlException e) {
            // Handle exceptions and possibly throw an AuraHandledException to send a message back to the LWC
            throw new AuraHandledException(e.getMessage());
        }
        
        return newOpps;
    }
    
}