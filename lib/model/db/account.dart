
// Represent user-account
class Account {
  int id; // Primary Key
  int index; // Index on the seed
  String name; // Account nickname
  int lastAccess; // Last Accessed incrementor
  bool selected; // Whether this is the currently selected account

  Account({this.id, this.index, this.name, this.lastAccess, this.selected = false});
}