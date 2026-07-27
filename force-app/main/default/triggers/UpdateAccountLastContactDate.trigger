trigger UpdateAccountLastContactDate on Contact (after insert) {
    List<Account> accountsToUpdate = new List<Account>();
    
    for (Contact newContact : Trigger.new) {
        if (newContact.AccountId != null) {
            accountsToUpdate.add(new Account(
                Id = newContact.AccountId,
                Last_Contact_Date__c = Date.today()
            ));
        }
    }
    
    update accountsToUpdate;
}