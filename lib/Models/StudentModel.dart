class StudentDetails {
  final String department;
  final String email;
  final String firstName;
  final String gender;
  final String lastName;
  final String phone;
  final int year;

  StudentDetails({
    required this.department,
    required this.email,
    required this.firstName,
    required this.gender,
    required this.lastName,
    required this.phone,
    required this.year,
  });

  factory StudentDetails.fromMap(Map<String, dynamic> map) {
    return StudentDetails(
      department: map['Department'] ?? '',
      email: map['Email'] ?? '',
      firstName: map['FirstName'] ?? '',
      gender: map['Gender'] ?? '',
      lastName: map['LastName'] ?? '',
      phone: map['Phone'] ?? '',
      year: map['Year'] ?? 0,
    );
  }
}

class StudentEntry {
  final String studentId;
  final StudentDetails studentDetails;

  StudentEntry({
    required this.studentId,
    required this.studentDetails,
  });

  factory StudentEntry.fromMap(Map<String, dynamic> map) {
    return StudentEntry(
      studentId: map['StudentId'] ?? '',
      studentDetails: StudentDetails.fromMap(map['StudentDetails'] ?? {}),
    );
  }
}
