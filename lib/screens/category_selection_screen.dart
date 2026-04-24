import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CategorySelectionScreen extends StatefulWidget {
  final bool isExpense;

  const CategorySelectionScreen({super.key, required this.isExpense});

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  late bool isExpense;
  String searchQuery = "";

  final List<Map<String, dynamic>> expenseCategories = [
    {"icon": Icons.shopping_bag,     "name": "Belanja",      "color": Colors.pinkAccent},
    {"icon": Icons.restaurant,       "name": "Makan & Minum","color": const Color(0xFFFF7043)},
    {"icon": Icons.directions_car,   "name": "Transport",    "color": AppTheme.primaryGreen},
    {"icon": Icons.movie,            "name": "Hiburan",      "color": AppTheme.accentPurple},
    {"icon": Icons.receipt,          "name": "Tagihan",      "color": AppTheme.expenseRed},
    {"icon": Icons.favorite,         "name": "Kesehatan",    "color": AppTheme.incomeGreen},
    {"icon": Icons.school,           "name": "Pendidikan",   "color": AppTheme.accentBlue},
    {"icon": Icons.home,             "name": "Perumahan",    "color": AppTheme.accentGreen},
    {"icon": Icons.checkroom,        "name": "Pakaian",      "color": Colors.purpleAccent},
    {"icon": Icons.pets,             "name": "Hewan",        "color": Colors.brown},
    {"icon": Icons.card_giftcard,    "name": "Hadiah",       "color": AppTheme.accentAmber},
    {"icon": Icons.more_horiz,       "name": "Lainnya",      "color": AppTheme.textSecondary},
  ];

  final List<Map<String, dynamic>> incomeCategories = [
    {"icon": Icons.work,              "name": "Gaji",         "color": AppTheme.incomeGreen},
    {"icon": Icons.laptop_mac,        "name": "Freelance",    "color": AppTheme.accentGreen},
    {"icon": Icons.trending_up,       "name": "Investasi",    "color": AppTheme.accentBlue},
    {"icon": Icons.business_center,   "name": "Bisnis",       "color": AppTheme.accentPurple},
    {"icon": Icons.card_giftcard,     "name": "Hadiah",       "color": Colors.pinkAccent},
    {"icon": Icons.account_balance,   "name": "Bunga",        "color": AppTheme.accentAmber},
    {"icon": Icons.storefront,        "name": "Penjualan",    "color": AppTheme.primaryGreenLight},
    {"icon": Icons.more_horiz,        "name": "Lainnya",      "color": AppTheme.textSecondary},
  ];

  @override
  void initState() {
    super.initState();
    isExpense = widget.isExpense;
  }

  @override
  Widget build(BuildContext context) {
    final activeCategories = isExpense ? expenseCategories : incomeCategories;
    final filteredCategories = activeCategories
        .where((cat) => (cat["name"] as String)
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.bgWhite,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pilih Kategori',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Toggle ──
          Container(
            color: AppTheme.bgWhite,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: Container(
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
          ),

          // ── Search Bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppTheme.bgWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: AppTheme.shadowSoft,
                      blurRadius: 10,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: TextField(
                style: TextStyle(color: AppTheme.textPrimary),
                onChanged: (v) => setState(() => searchQuery = v),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Cari kategori...',
                  hintStyle: TextStyle(color: AppTheme.textHint),
                  icon: Icon(Icons.search_rounded, color: AppTheme.textSecondary),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded,
                              color: AppTheme.textSecondary),
                          onPressed: () => setState(() => searchQuery = ""),
                        )
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Category Grid ──
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemCount: filteredCategories.length,
              itemBuilder: (context, index) {
                final cat = filteredCategories[index];
                final color = cat["color"] as Color;
                return GestureDetector(
                  onTap: () => Navigator.pop(context, cat),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.bgWhite,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.shadowSoft,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(cat["icon"] as IconData,
                              color: color, size: 24),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cat["name"] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Add Custom Category ──
          Padding(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppTheme.primaryGreen.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, color: AppTheme.primaryGreen),
                    const SizedBox(width: 8),
                    Text(
                      'Buat Kategori Baru',
                      style: TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
