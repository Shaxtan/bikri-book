import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../customers/presentation/providers/customer_provider.dart';
import '../providers/calculator_provider.dart';

class SaveBottomSheet extends ConsumerStatefulWidget {
  const SaveBottomSheet({super.key, required this.amount});
  final double amount;

  static Future<bool> show(BuildContext context, double amount) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SaveBottomSheet(amount: amount),
    );
    return result ?? false;
  }

  @override
  ConsumerState<SaveBottomSheet> createState() => _SaveBottomSheetState();
}

class _SaveBottomSheetState extends ConsumerState<SaveBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _itemCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  TxnType _type = TxnType.sale;
  bool _isSaving = false;
  String _customerName = '';

  @override
  void dispose() {
    _itemCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final calcNotifier = ref.read(calculatorProvider.notifier);

    if (_customerName.trim().isNotEmpty) {
      await ref
          .read(customerProvider.notifier)
          .ensureCustomerExists(_customerName.trim());
    }

    await ref.read(transactionProvider.notifier).save(
          amount: widget.amount,
          expression: calcNotifier.exportExpression,
          type: _type,
          itemName: _itemCtrl.text,
          customerName:
              _customerName.trim().isEmpty ? null : _customerName.trim(),
          notes: _notesCtrl.text,
        );

    calcNotifier.clearAfterSave();
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final customerNames = ref
        .watch(customerProvider)
        .customers
        .map((c) => c.name)
        .toList();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Record Save Karo',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Total: ${CurrencyFormatter.format(widget.amount)}',
              style: GoogleFonts.robotoMono(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            _TypeToggle(
              selected: _type,
              onChanged: (t) => setState(() => _type = t),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _itemCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Cheez ka naam (Item name) *',
                hintText: 'e.g. Chawal 5kg, Soap, Biscuit...',
                prefixIcon: Icon(Icons.shopping_bag_outlined),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Please enter item name'
                  : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),

            // Customer autocomplete
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                _customerName = textEditingValue.text;
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return customerNames.where((name) => name
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (String selection) {
                _customerName = selection;
              },
              fieldViewBuilder: (context, textEditingController, focusNode,
                  onFieldSubmitted) {
                return TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Customer (optional)',
                    hintText: 'Ramesh, Geeta, Suresh...',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textInputAction: TextInputAction.next,
                  onChanged: (val) => _customerName = val,
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 40,
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (context, i) {
                          final name = options.elementAt(i);
                          return ListTile(
                            leading: const Icon(Icons.person_outline,
                                color: AppColors.primary),
                            title: Text(name),
                            onTap: () => onSelected(name),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Home delivery, paid by card...',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check, size: 20),
                    label: Text(_isSaving ? 'Saving...' : 'SAVE KARO ✓'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({required this.selected, required this.onChanged});
  final TxnType selected;
  final ValueChanged<TxnType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _chip(TxnType.sale, 'Bikri', Icons.trending_up, AppColors.sale,
            AppColors.saleChipBg),
        const SizedBox(width: 8),
        _chip(TxnType.expense, 'Kharcha', Icons.trending_down,
            AppColors.expense, AppColors.expenseChipBg),
        const SizedBox(width: 8),
        _chip(TxnType.credit, 'Udhaari', Icons.access_time,
            AppColors.credit, AppColors.creditChipBg),
      ],
    );
  }

  Widget _chip(TxnType type, String label, IconData icon, Color activeColor,
      Color activeBg) {
    final isSelected = selected == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? activeColor : AppColors.border,
              width: isSelected ? 1.5 : 0.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 18,
                  color:
                      isSelected ? activeColor : AppColors.textTertiary),
              const SizedBox(height: 3),
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? activeColor
                          : AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}