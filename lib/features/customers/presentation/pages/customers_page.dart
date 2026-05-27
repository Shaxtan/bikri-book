import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../providers/customer_provider.dart';
import '../../data/models/customer_model.dart';
import 'customer_detail_page.dart';

class CustomersPage extends ConsumerWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerState = ref.watch(customerProvider);
    final txns = ref.watch(transactionProvider).transactions;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Customers (Khata)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () => _showAddCustomer(context, ref),
          ),
        ],
      ),
      body: customerState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : customerState.customers.isEmpty
              ? _EmptyState(onAdd: () => _showAddCustomer(context, ref))
              : ListView.separated(
                  itemCount: customerState.customers.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 0.5, indent: 70),
                  itemBuilder: (context, i) {
                    final customer = customerState.customers[i];
                    final balance = _computeBalance(customer.name, txns);
                    return _CustomerTile(
                      customer: customer,
                      balance: balance,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CustomerDetailPage(
                            customer: customer,
                            balance: balance,
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCustomer(context, ref),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Add Customer',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }

  double _computeBalance(String name, List<TransactionModel> txns) {
    return txns
        .where((t) =>
            t.customerName?.toLowerCase() == name.toLowerCase() &&
            t.type == TxnType.credit)
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  void _showAddCustomer(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text('New Customer',
                  style: GoogleFonts.notoSans(
                      fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Customer name *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone number (optional)',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.trim().isNotEmpty) {
                      await ref
                          .read(customerProvider.notifier)
                          .addCustomer(
                            name: nameCtrl.text.trim(),
                            phone: phoneCtrl.text.trim(),
                          );
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text('Add Customer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerTile extends StatelessWidget {
  const _CustomerTile({
    required this.customer,
    required this.balance,
    required this.onTap,
  });
  final CustomerModel customer;
  final double balance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: AppColors.surface,
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryPale,
        child: Text(
          customer.name[0].toUpperCase(),
          style: const TextStyle(
              color: AppColors.primary, fontWeight: FontWeight.w700),
        ),
      ),
      title: Text(customer.name,
          style: const TextStyle(
              fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
      subtitle: customer.phone != null
          ? Text(customer.phone!,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textTertiary))
          : null,
      trailing: balance > 0
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(CurrencyFormatter.format(balance),
                    style: const TextStyle(
                        color: AppColors.credit,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
                const Text('pending',
                    style: TextStyle(
                        fontSize: 10, color: AppColors.textTertiary)),
              ],
            )
          : const Icon(Icons.chevron_right, color: AppColors.border),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline,
              size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          const Text(
            'No customers yet.\nAdd your first customer!',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.6),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.person_add),
            label: const Text('Add Customer'),
          ),
        ],
      ),
    );
  }
}