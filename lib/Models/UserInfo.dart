class userInfo {
  String Uid;
  String Name;
  String Email;
  String ProfileImageUrl;
  String PhoneNumber;
  String Password;
  bool isAdmin;
  userInfo({
    required this.Uid,
    required this.Name,
    required this.Email,
    required this.ProfileImageUrl,
    required this.PhoneNumber,
    required this.Password,
    required this.isAdmin,
  });

  factory userInfo.fromMap(Map map) {
    return userInfo(
      Uid: map['Uid'] ?? '',
      Name: map['Name'] ?? '',
      Email: map['Email'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
      ProfileImageUrl: map['ProfileImageUrl'] ?? '',
      PhoneNumber: map['PhoneNumber'] ?? '',
      Password: map['Password'] ?? '',
    );
  }
}
