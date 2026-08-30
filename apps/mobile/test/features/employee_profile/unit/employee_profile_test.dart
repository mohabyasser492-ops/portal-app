import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/features/profile/domain/employee_profile.dart';

void main() {
  group('EmployeeProfile', () {
    test('supports value equality', () {
      const profile1 = EmployeeProfile(
        id: 'user-1',
        displayName: 'Test User',
        jobTitle: 'Developer',
        department: 'Engineering',
        email: 'test@portal.local',
        mobilePhone: '1234567890',
        employeeId: 'EMP-1',
        managerName: 'Manager',
      );

      const profile2 = EmployeeProfile(
        id: 'user-1',
        displayName: 'Test User',
        jobTitle: 'Developer',
        department: 'Engineering',
        email: 'test@portal.local',
        mobilePhone: '1234567890',
        employeeId: 'EMP-1',
        managerName: 'Manager',
      );

      expect(profile1, equals(profile2));
    });

    test('supports copyWith', () {
      const profile = EmployeeProfile(
        id: 'user-1',
        displayName: 'Test User',
        jobTitle: 'Developer',
        department: 'Engineering',
        email: 'test@portal.local',
        mobilePhone: '1234567890',
        employeeId: 'EMP-1',
        managerName: 'Manager',
      );

      final updated = profile.copyWith(displayName: 'Updated Name');

      expect(updated.displayName, 'Updated Name');
      expect(updated.id, 'user-1');
    });
  });
}
