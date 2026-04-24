import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/transaction_item.dart';
import '../widgets/bouncy_button.dart';
import 'category_selection_screen.dart';

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransactionSheet(),
    );
  }

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  bool isExpense = true;
  Map<String, dynamic>? selectedCategory;
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // Numpad hanya gunakan digit dan titik (titik sebagai desimal sementara)
  // Tampilan di layar menggunakan format ribuan
  final List<List<String>> numpadKeys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    [',', '0', '<'],
  ];

  /// Angka rawAmount dalam format string angka bersih (tanpa titik ribuan)
  String rawAmount = '0';

  /// Tampilan amount dengan pemisah ribuan
  String get _displayAmount {
    final val = double.tryParse(rawAmount.replaceAll(',', '.')) ?? 0;
    if (rawAmount.endsWith(',') || rawAmount.endsWith('.')) {
      return NumberFormat('#,##0', 'id_ID').format(val) + ',';
    }
    return NumberFormat('#,##0', 'id_ID').format(val);
  }

  void _onKeyPress(String key) {
    setState(() {
      if (key == '<') {
        if (rawAmount.length > 1) {
          rawAmount = rawAmount.substring(0, rawAmount.length - 1);
        } else {
          rawAmount = '0';
        }
      } else if (key == ',') {
        // Satu desimal saja
        if (!rawAmount.contains(',')) {
          rawAmount += ',';
        }
      } else {
        if (rawAmount == '0') {
          rawAmount = key;
        } else if (rawAmount.replaceAll(',', '').length < 12) {
          rawAmount += key;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan padding bottom dari viewInsets untuk menangani keyboard
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: const BoxDecoration(
        color: AppTheme.bgWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 14, bottom: 10),
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: AppTheme.textHint,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Title
                  Text(
                    'Tambah Transaksi',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 20,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Expense / Income Toggle
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.bgLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => isExpense = true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isExpense ? AppTheme.expenseRed : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  'Pengeluaran',
                                  style: TextStyle(
                                    color: isExpense ? Colors.white : AppTheme.textSecondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => isExpense = false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !isExpense ? AppTheme.incomeGreen : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  'Pemasukan',
                                  style: TextStyle(
                                    color: !isExpense ? Colors.white : AppTheme.textSecondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Amount Display
                  Text(
                    'Jumlah',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Rp ',
                          style: TextStyle(fontSize: 18, color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
                        ),
                        Flexible(
                          child: Text(
                            _displayAmount,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: isExpense ? AppTheme.expenseRed : AppTheme.incomeGreen,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category Selector
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CategorySelectionScreen(isExpense: isExpense),
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            selectedCategory = result as Map<String, dynamic>;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.bgLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: selectedCategory != null
                                    ? (selectedCategory!["color"] as Color).withOpacity(0.12)
                                    : AppTheme.textSecondary.withOpacity(0.10),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                selectedCategory != null ? selectedCategory!["icon"] as IconData : Icons.category_outlined,
                                color: selectedCategory != null ? selectedCategory!["color"] as Color : AppTheme.textSecondary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                selectedCategory != null ? selectedCategory!["name"] as String : 'Pilih Kategori',
                                style: TextStyle(
                                  color: selectedCategory != null ? AppTheme.textPrimary : AppTheme.textSecondary,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Input Note
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.bgLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _noteController,
                        style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Keterangan transaksi...',
                          hintStyle: TextStyle(color: AppTheme.textHint),
                          icon: Icon(Icons.edit_outlined, color: AppTheme.textSecondary, size: 20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Numpad Area
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    child: Column(
                      children: [
                        ...numpadKeys.map((row) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: row.map((key) {
                              return _buildNumpadButton(key);
                            }).toList(),
                          );
                        }).toList(),
                        
                        const SizedBox(height: 16),
                        
                        // Submit Button
                        BouncyButton(
                          onTap: () {
                            if (rawAmount != '0' && selectedCategory != null) {
                              final clean = rawAmount.replaceAll(',', '.');
                              final numVal = double.tryParse(clean) ?? 0.0;
                              if (numVal > 0) {
                                AppState().addTransaction(
                                  TransactionData(
                                    icon:        selectedCategory!['icon'] as IconData,
                                    title:       selectedCategory!['name'] as String,
                                    subtitle:    _noteController.text.isEmpty
                                        ? 'Transaksi manual'
                                        : _noteController.text,
                                    amountValue: numVal,
                                    date:        DateTime.now(),
                                    isExpense:   isExpense,
                                    color:       selectedCategory!['color'] as Color,
                                  ),
                                );
                              }
                            }
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryGreen.withOpacity(0.3),
                                  blurRadius: 10, offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'Simpan Transaksi',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumpadButton(String label) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onKeyPress(label),
          borderRadius: BorderRadius.circular(30),
          child: Container(
            height: 60,
            alignment: Alignment.center,
            child: label == '<'
                ? Icon(Icons.backspace_outlined, color: AppTheme.textPrimary)
                : Text(
                    label,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
