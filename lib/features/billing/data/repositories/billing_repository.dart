import '../services/billing_service.dart';

class BillingRepository {
  final BillingService _billingService;

  BillingRepository(this._billingService);

  Future<List<Map<String, dynamic>>> getAllInvoices() async {
    return _billingService.getInvoices();
  }

  Future<void> createInvoice(Map<String, dynamic> invoice) async {
    await _billingService.createInvoice(invoice);
  }

  Future<void> updateInvoice(Map<String, dynamic> invoice) async {
    await _billingService.updateInvoice(invoice);
  }

  Future<void> deleteInvoice(String id) async {
    await _billingService.deleteInvoice(id);
  }
}
