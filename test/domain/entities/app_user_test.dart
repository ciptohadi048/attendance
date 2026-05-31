import 'package:flutter_test/flutter_test.dart';
import 'package:tugasgila/domain/entities/app_user.dart';

void main() {
  // -------------------------------------------------------------------------
  // UserRole.fromString
  // -------------------------------------------------------------------------
  group('UserRole.fromString', () {
    test('parses "admin" to UserRole.admin', () {
      expect(UserRole.fromString('admin'), UserRole.admin);
    });

    test('parses "employee" to UserRole.employee', () {
      expect(UserRole.fromString('employee'), UserRole.employee);
    });

    test('defaults to employee for null', () {
      expect(UserRole.fromString(null), UserRole.employee);
    });

    test('defaults to employee for unknown string', () {
      expect(UserRole.fromString('superadmin'), UserRole.employee);
    });

    test('defaults to employee for empty string', () {
      expect(UserRole.fromString(''), UserRole.employee);
    });
  });

  // -------------------------------------------------------------------------
  // AppUser.isAdmin
  // -------------------------------------------------------------------------
  group('AppUser.isAdmin', () {
    test('returns true for admin role', () {
      final user = _makeUser(role: UserRole.admin);
      expect(user.isAdmin, isTrue);
    });

    test('returns false for employee role', () {
      final user = _makeUser(role: UserRole.employee);
      expect(user.isAdmin, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // AppUser.initials
  // -------------------------------------------------------------------------
  group('AppUser.initials', () {
    test('returns two initials for two-word name', () {
      final user = _makeUser(name: 'Budi Santoso');
      expect(user.initials, 'BS');
    });

    test('returns one initial for single-word name', () {
      final user = _makeUser(name: 'Budi');
      expect(user.initials, 'B');
    });

    test('returns ? for empty name', () {
      final user = _makeUser(name: '');
      expect(user.initials, '?');
    });

    test('returns ? for whitespace-only name', () {
      final user = _makeUser(name: '   ');
      expect(user.initials, '?');
    });

    test('handles multi-word name (takes first and last)', () {
      final user = _makeUser(name: 'Muhammad Rizky Pratama');
      expect(user.initials, 'MP');
    });

    test('uppercases lowercase initials', () {
      final user = _makeUser(name: 'budi santoso');
      expect(user.initials, 'BS');
    });
  });

  // -------------------------------------------------------------------------
  // AppUser.copyWith
  // -------------------------------------------------------------------------
  group('AppUser.copyWith', () {
    test('copies with new name', () {
      final user = _makeUser(name: 'Budi');
      final copy = user.copyWith(name: 'Andi');
      expect(copy.name, 'Andi');
      expect(copy.uid, user.uid);
    });

    test('copies with new role', () {
      final user = _makeUser(role: UserRole.employee);
      final copy = user.copyWith(role: UserRole.admin);
      expect(copy.isAdmin, isTrue);
    });

    test('retains original values when no args given', () {
      final user = _makeUser(name: 'Budi', role: UserRole.admin);
      final copy = user.copyWith();
      expect(copy.name, 'Budi');
      expect(copy.role, UserRole.admin);
    });
  });

  // -------------------------------------------------------------------------
  // AppUser equality
  // -------------------------------------------------------------------------
  group('AppUser equality', () {
    test('equal when uid, role, name match', () {
      final a = _makeUser(uid: '1', name: 'Budi', role: UserRole.admin);
      final b = _makeUser(uid: '1', name: 'Budi', role: UserRole.admin);
      expect(a, equals(b));
    });

    test('not equal when uid differs', () {
      final a = _makeUser(uid: '1', name: 'Budi');
      final b = _makeUser(uid: '2', name: 'Budi');
      expect(a, isNot(equals(b)));
    });

    test('not equal when name differs', () {
      final a = _makeUser(uid: '1', name: 'Budi');
      final b = _makeUser(uid: '1', name: 'Andi');
      expect(a, isNot(equals(b)));
    });

    test('not equal when role differs', () {
      final a = _makeUser(uid: '1', role: UserRole.admin);
      final b = _makeUser(uid: '1', role: UserRole.employee);
      expect(a, isNot(equals(b)));
    });

    test('hashCode consistent with equality', () {
      final a = _makeUser(uid: '1', name: 'Budi', role: UserRole.admin);
      final b = _makeUser(uid: '1', name: 'Budi', role: UserRole.admin);
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}

AppUser _makeUser({
  String uid = 'uid-1',
  String nik = '12345678',
  String name = 'Test User',
  String email = 'test@example.com',
  UserRole role = UserRole.employee,
}) {
  return AppUser(uid: uid, nik: nik, name: name, email: email, role: role);
}
