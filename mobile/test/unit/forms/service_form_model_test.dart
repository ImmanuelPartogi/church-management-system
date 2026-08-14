import 'package:church_management_mobile/features/forms/data/models/service_form_application_model.dart';
import 'package:church_management_mobile/features/forms/data/models/service_form_document_model.dart';
import 'package:church_management_mobile/features/forms/data/models/service_form_type_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ServiceFormTypeModel Tests', () {
    test('should parse ServiceFormTypeModel from valid JSON', () {
      final json = {
        'id': 1,
        'name': 'Baptisan Kudus',
        'slug': 'baptisan-kudus',
        'description': 'Pendaftaran baptisan untuk anak dan dewasa',
        'fee_amount': 0,
        'active': true,
        'created_at': '2026-01-01T00:00:00.000000Z',
        'updated_at': '2026-01-01T00:00:00.000000Z',
      };

      final model = ServiceFormTypeModel.fromJson(json);

      expect(model.id, 1);
      expect(model.name, 'Baptisan Kudus');
      expect(model.slug, 'baptisan-kudus');
      expect(model.feeAmount, 0);
      expect(model.active, true);

      final entity = model.toEntity();
      expect(entity.id, 1);
      expect(entity.name, 'Baptisan Kudus');
    });
  });

  group('ServiceFormDocumentModel Tests', () {
    test('should parse ServiceFormDocumentModel from valid JSON', () {
      final json = {
        'id': 10,
        'service_form_application_id': 5,
        'document_name': 'KTP Orang Tua',
        'file_name': 'ktp_orangtua.pdf',
        'mime_type': 'application/pdf',
        'file_size': 1024500,
        'created_at': '2026-08-14T10:00:00.000000Z',
        'updated_at': '2026-08-14T10:00:00.000000Z',
      };

      final model = ServiceFormDocumentModel.fromJson(json);

      expect(model.id, 10);
      expect(model.serviceFormApplicationId, 5);
      expect(model.documentName, 'KTP Orang Tua');
      expect(model.fileName, 'ktp_orangtua.pdf');
      expect(model.mimeType, 'application/pdf');
      expect(model.fileSize, 1024500);

      final entity = model.toEntity();
      expect(entity.documentName, 'KTP Orang Tua');
      expect(entity.fileSize, 1024500);
    });
  });

  group('ServiceFormApplicationModel Tests', () {
    test(
        'should parse ServiceFormApplicationModel with nested types and documents',
        () {
      final json = {
        'id': 5,
        'application_number': 'APP-20260814-ABCDEF',
        'user_id': 2,
        'member_id': 10,
        'service_form_type': {
          'id': 1,
          'name': 'Baptisan Kudus',
          'slug': 'baptisan-kudus',
          'description': 'Deskripsi singkat',
          'fee_amount': 0,
          'active': true,
          'created_at': '2026-01-01T00:00:00.000000Z',
          'updated_at': '2026-01-01T00:00:00.000000Z',
        },
        'status': 'pending',
        'applicant_notes': 'Mohon diproses segera',
        'rejection_reason': null,
        'payment_status': 'unpaid',
        'payment_notes': null,
        'reviewed_at': null,
        'documents': [
          {
            'id': 10,
            'service_form_application_id': 5,
            'document_name': 'KTP Orang Tua',
            'file_name': 'ktp_orangtua.pdf',
            'mime_type': 'application/pdf',
            'file_size': 1024500,
            'created_at': '2026-08-14T10:00:00.000000Z',
            'updated_at': '2026-08-14T10:00:00.000000Z',
          }
        ],
        'created_at': '2026-08-14T10:00:00.000000Z',
        'updated_at': '2026-08-14T10:00:00.000000Z',
      };

      final model = ServiceFormApplicationModel.fromJson(json);

      expect(model.id, 5);
      expect(model.applicationNumber, 'APP-20260814-ABCDEF');
      expect(model.status, 'pending');
      expect(model.serviceFormType?.name, 'Baptisan Kudus');
      expect(model.documents.length, 1);
      expect(model.documents.first.documentName, 'KTP Orang Tua');

      final entity = model.toEntity();
      expect(entity.applicationNumber, 'APP-20260814-ABCDEF');
      expect(entity.documents.first.fileName, 'ktp_orangtua.pdf');
    });
  });
}
