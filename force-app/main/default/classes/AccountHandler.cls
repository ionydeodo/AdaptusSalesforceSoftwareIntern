public class AccountHandler extends TriggerHandler {
  public override void beforeInsert() {
    List<Account> newAccounts = (List<Account>) Trigger.new;
    for (Account account : newAccounts) {
      if (account.Name.length() > 80) {
        account.Name = account.Name.substring(0, 80);
      }
      account.Name += ' - Adaptus';
    }
  }

  public override void afterInsert() {
    List<Account> newAccounts = (List<Account>) Trigger.new;
    List<Contact> newContacts = new List<Contact>();
    for (Account account : newAccounts) {
      string firstName = account.Name.substring(
        0,
        account.Name.length() - ' - Adaptus'.length()
      );
      string contactFirstName = firstName;
      if (contactFirstName.length() > 40) {
        contactFirstName = firstName.substring(0, 40);
      }
      Contact contact = new Contact(
        FirstName = contactFirstName,
        LastName = account.LastName__c,
        AccountId = account.Id,
        Email = EmailString(
          contactFirstName,
          account.LastName__c,
          '@adaptus.com'
        )
      );
      newContacts.add(contact);
    }
    Database.insert(newContacts);
  }

  public override void afterDelete() {
    List<Account> deletedAccounts = (List<Account>) Trigger.old;
    List<Task> tasks = new List<Task>();
    for (Account account : deletedAccounts) {
      Task newTask = new Task(
        Subject = 'Deleted account ' + account.Name,
        ActivityDate = Date.today()
      );
      tasks.add(newTask);
    }

    if (!tasks.isEmpty()) {
      Database.insert(tasks);
    }
  }

  public String EmailString(
    String firstName,
    String lastName,
    String emailDomain
  ) {
    string input = firstName + lastName;
    input = input.replace('á', 'a')
      .replace('é', 'e')
      .replace('í', 'i')
      .replace('ó', 'o')
      .replace('ú', 'u')
      .replace('Á', 'A')
      .replace('É', 'E')
      .replace('Í', 'I')
      .replace('Ó', 'O')
      .replace('Ú', 'U')
      .replace('ñ', 'n')
      .replace('Ñ', 'N')
      .replace(' ', '');
    input = input.replaceAll('[^a-zA-Z0-9._-]', '');
    return input + emailDomain;
  }
}
