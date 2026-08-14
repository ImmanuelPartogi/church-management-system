import 'package:church_management_mobile/features/donations/data/models/chart_of_account_model.dart';
import 'package:church_management_mobile/features/donations/data/models/church_bank_account_model.dart';
import 'package:church_management_mobile/features/donations/data/models/donation_confirmation_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChurchBankAccountModel Tests', () {
    test('should parse ChurchBankAccountModel from JSON correctly', () {
      final json = {
        'id': 1,
        'bank_name': 'Bank Central Asia (BCA)',
        'account_number': '1234567890',
        'account_holder_name': 'Gereja HKBP',
        'is_active': true,
        'display_order': 1,
      };

      final model = ChurchBankAccountModel.fromJson(json);

      expect(model.id, 1);
      expect(model.bankName, 'Bank Central Asia (BCA)');
      expect(model.accountNumber, '1234567890');
      expect(model.accountHolderName, 'Gereja HKBP');
      expect(model.isActive, true);

      final entity = model.toEntity();
      expect(entity.bankName, 'Bank Central Asia (BCA)');
    });
  });

  group('ChartOfAccountModel Tests', () {
    test('should parse ChartOfAccountModel from JSON correctly', () {
      final json = {
        'id': 1,
        'code': '4000',
        'name': 'Persembahan Minggu',
        'type': 'income',
        'description': 'Penerimaan persembahan ibadah minggu',
        'is_active': true,
      };

      final model = ChartOfAccountModel.fromJson(json);

      expect(model.id, 1);
      expect(model.code, '4000');
      expect(model.name, 'Persembahan Minggu');
      expect(model.type, 'income');

      final entity = model.toEntity();
      expect(entity.name, 'Persembahan Minggu');
    });
  });

  group('DonationConfirmationModel Tests', () {
    test('should parse DonationConfirmationModel with category and proof URL',
        () {
      final json = {
        'id': 10,
        'donation_number': 'DON-20260814-ABCDEF',
        'user_id': 2,
        'member_id': 5,
        'category': {
          'id': 1,
          'code': '4000',
          'name': 'Persembahan Minggu',
          'type': 'income',
          'description': 'Deskripsi',
          'is_active': true,
        },
        'amount': 150000,
        'transfer_date': '2026-08-14',
        'sender_bank': 'BCA',
        'depositor_phone': '081234567890',
        'proof_file_url': 'http://localhost/storage/donation_proofs/proof.jpg',
        'status': 'pending',
        'notes': 'Persembahan ibadah minggu 1',
        'rejection_reason': null,
        'reviewed_at': null,
        'created_at': '2026-08-14T12:00:00.000000Z',
        'updated_at': '2026-08-14T12:00:00.000000Z',
      };

      final model = DonationConfirmationModel.fromJson(json);

      expect(model.id, 10);
      expect(model.donationNumber, 'DON-20260814-ABCDEF');
      expect(model.amount, 150000);
      expect(model.status, 'pending');
      expect(model.category?.name, 'Persembahan Minggu');
      expect(
        model.proofFileUrl,
        'http://localhost/storage/donation_proofs/proof.jpg',
      );

      final entity = model.toEntity();
      expect(entity.donationNumber, 'DON-20260814-ABCDEF');
      expect(entity.amount, 150000);
    });
  });
}
