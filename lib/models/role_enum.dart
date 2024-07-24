enum Role { USER, ADMIN }

// Convert Role to and from JSON
Role roleFromJson(String role) {
  switch (role) {
    case 'USER':
      return Role.USER;
    case 'ADMIN':
      return Role.ADMIN;
    default:
      throw Exception('Unknown role: $role');
  }
}

String roleToJson(Role role) {
  return role.toString().split('.').last;
}
