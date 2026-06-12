import 'package:pscommunitymobileapp/features/samaj/domain/entities/samaj.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/entities/samaj_bank_details_model.dart';

abstract class SamajRepository {
  Future<Samaj?> getSamajDetail();
  Future<List<SamajBankDetais>> getBankAccountDetails();
}
