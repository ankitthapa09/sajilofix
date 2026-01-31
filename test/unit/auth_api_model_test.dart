import 'package:flutter_test/flutter_test.dart';
import 'package:sajilofix/features/auth/data/models/auth_api_model.dart';

void main() {
  group('AuthApiModel.fromJSON', () {
    test('parses id from _id or id', () {
      final model1 = AuthApiModel.fromJSON({
        '_id': 'mongoId',
        'fullName': 'User',
        'email': 'user@example.com',
        'roleIndex': 0,
      });
      expect(model1.id, 'mongoId');

      final model2 = AuthApiModel.fromJSON({
        'id': 'plainId',
        'fullName': 'User',
        'email': 'user@example.com',
        'roleIndex': 0,
      });
      expect(model2.id, 'plainId');
    });

    test('derives roleIndex from role string when roleIndex missing', () {
      final citizen = AuthApiModel.fromJSON({
        'fullName': 'Citizen',
        'email': 'c@example.com',
        'role': 'citizen',
      });
      expect(citizen.roleIndex, 0);

      final admin = AuthApiModel.fromJSON({
        'fullName': 'Admin',
        'email': 'a@example.com',
        'role': 'admin',
      });
      expect(admin.roleIndex, 1);

      final authority = AuthApiModel.fromJSON({
        'fullName': 'Authority',
        'email': 'x@example.com',
        'role': 'authority',
      });
      expect(authority.roleIndex, 2);
    });

    test('falls back to deriving roleIndex from email', () {
      final admin = AuthApiModel.fromJSON({
        'fullName': 'Admin',
        'email': 'admin@sajilofix.com',
      });
      expect(admin.roleIndex, 1);

      final authority = AuthApiModel.fromJSON({
        'fullName': 'Gov',
        'email': 'someone@sajilofix.gov.np',
      });
      expect(authority.roleIndex, 2);

      final citizen = AuthApiModel.fromJSON({
        'fullName': 'Normal',
        'email': 'normal@example.com',
      });
      expect(citizen.roleIndex, 0);
    });
  });

  group('AuthApiModel.toEntity', () {
    test('converts blank optional fields to null', () {
      final model = AuthApiModel.fromJSON({
        'fullName': 'User',
        'email': 'user@example.com',
        'roleIndex': 0,
        'phone': '  ',
        'dob': '   ',
        'citizenshipNumber': '',
        'district': 'Kathmandu',
        'municipality': '  ',
        'ward': '1',
        'tole': null,
        'profilePhoto': '',
      });

      final entity = model.toEntity();
      expect(entity.dob, isNull);
      expect(entity.citizenshipNumber, isNull);
      expect(entity.municipality, isNull);
      expect(entity.profilePhoto, isNull);
      expect(entity.district, 'Kathmandu');
      expect(entity.ward, '1');
    });
  });
}
