import 'package:flutter/foundation.dart';
import '../widgets/transaction_item.dart';

class AppState {
  // Singleton
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  // Nama user (diisi setelah login)
  final ValueNotifier<String> userName = ValueNotifier('');
  final ValueNotifier<String> userEmail = ValueNotifier('');

  // Keuangan
  final ValueNotifier<double> balance      = ValueNotifier(0.0);
  final ValueNotifier<double> income       = ValueNotifier(0.0);
  final ValueNotifier<double> expense      = ValueNotifier(0.0);
  final ValueNotifier<List<TransactionData>> transactions = ValueNotifier([]);

  // Ringkasan per kategori (nama → total pengeluaran)
  final ValueNotifier<Map<String, double>> categoryTotals =
      ValueNotifier({});

  void addTransaction(TransactionData tx) {
    transactions.value = [tx, ...transactions.value];

    if (tx.isExpense) {
      expense.value  += tx.amountValue;
      balance.value  -= tx.amountValue;

      // Update category totals
      final updated = Map<String, double>.from(categoryTotals.value);
      updated[tx.title] = (updated[tx.title] ?? 0.0) + tx.amountValue;
      categoryTotals.value = updated;
    } else {
      income.value  += tx.amountValue;
      balance.value += tx.amountValue;
    }
  }

  void reset() {
    userName.value       = '';
    userEmail.value      = '';
    balance.value        = 0.0;
    income.value         = 0.0;
    expense.value        = 0.0;
    transactions.value   = [];
    categoryTotals.value = {};
  }
}
