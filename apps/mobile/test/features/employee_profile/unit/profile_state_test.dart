import 'package:flutter_test/flutter_test.dart';
import 'package:portal_app/features/profile/application/profile_state.dart';
import 'package:portal_app/features/profile/application/profile_status.dart';
import 'package:portal_app/features/profile/domain/employee_profile.dart';

void main() {
  group('ProfileState', () {
    test('initial state has correct properties', () {
      const state = ProfileState.initial();

      expect(state.status, ProfileStatus.initial);
      expect(state.isLoading, isFalse);
      expect(state.hasData, isFalse);
      expect(state.hasFailure, isFalse);
    });

    test('loading state has correct properties', () {
      const state = ProfileState.loading();

      expect(state.status, ProfileStatus.loading);
      expect(state.isLoading, isTrue);
      expect(state.hasData, isFalse);
      expect(state.hasFailure, isFalse);
    });

    test('success state has correct properties', () {
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

      const state = ProfileState.success(profile);

      expect(state.status, ProfileStatus.success);
      expect(state.isLoading, isFalse);
      expect(state.hasData, isTrue);
      expect(state.hasFailure, isFalse);
      expect(state.profile, profile);
    });

    test('failure state has correct properties', () {
      const state = ProfileState.failure('Error occurred');

      expect(state.status, ProfileStatus.failure);
      expect(state.isLoading, isFalse);
      expect(state.hasData, isFalse);
      expect(state.hasFailure, isTrue);
      expect(state.errorMessage, 'Error occurred');
    });
  });
}
