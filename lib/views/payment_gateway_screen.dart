import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../controllers/auth_controller.dart';
import '../controllers/union_controller.dart';
import '../models/fee_type.dart';
import '../models/bike.dart';
import '../models/rider.dart';
import 'payment_receipt_screen.dart';

/// Screen 6: Direct Union Payment Gateway Screen
/// Select Daily Levy (Le 25,000), Safety Fine (Le 15,000), Annual Permit (Le 100,000),
/// or Custom Amount with instant input validation and fee breakdown.
class PaymentGatewayScreen extends StatefulWidget {
  final String? preselectedRiderId;
  final String? preselectedBikeId;
  final String? preselectedFeeCode;
  final double? preselectedAmount;

  const PaymentGatewayScreen({
    super.key,
    this.preselectedRiderId,
    this.preselectedBikeId,
    this.preselectedFeeCode,
    this.preselectedAmount,
  });

  @override
  State<PaymentGatewayScreen> createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  String? _selectedBikeId;
  String? _selectedRiderId;
  String? _selectedFeeTypeId;
  String _selectedPaymentMethod = 'CASH_OFFICIAL';

  final TextEditingController _customAmountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  double _resolvedAmount = 25000.00;
  bool _isCustomAmount = false;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSelections();
    });
  }

  void _initSelections() {
    final union = context.read<UnionController>();
    final auth = context.read<AuthController>();

    // 1. Resolve Rider
    String? riderId = widget.preselectedRiderId ?? auth.currentRider?.id;
    if (riderId == null && union.riders.isNotEmpty) {
      riderId = union.riders.first.id;
    }

    // 2. Resolve Bike
    String? bikeId = widget.preselectedBikeId ?? auth.currentBike?.id;
    if (bikeId == null && riderId != null) {
      final b = union.bikes.firstWhere(
        (bk) => bk.riderId == riderId,
        orElse: () => union.bikes.first,
      );
      bikeId = b.id;
    }

    // 3. Resolve Fee Type
    FeeType? fee;
    if (widget.preselectedFeeCode != null) {
      fee = union.feeTypes.firstWhere(
        (f) => f.code == widget.preselectedFeeCode,
        orElse: () => union.feeTypes.first,
      );
    } else {
      fee = union.feeTypes.firstWhere(
        (f) => f.code == 'DAILY_LEVY',
        orElse: () => union.feeTypes.first,
      );
    }

    setState(() {
      _selectedRiderId = riderId;
      _selectedBikeId = bikeId;
      _selectedFeeTypeId = fee?.id;
      _isCustomAmount = fee?.isCustomAllowed ?? false;

      if (widget.preselectedAmount != null && widget.preselectedAmount! > 0) {
        _resolvedAmount = widget.preselectedAmount!;
        _customAmountController.text = widget.preselectedAmount!.toStringAsFixed(2);
      } else {
        _resolvedAmount = fee?.defaultAmount ?? 25000.0;
        if (_isCustomAmount) {
          _customAmountController.text = '25000.00';
          _resolvedAmount = 25000.00;
        }
      }
    });
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onFeeTypeChanged(FeeType fee) {
    setState(() {
      _selectedFeeTypeId = fee.id;
      _isCustomAmount = fee.isCustomAllowed;
      _validationError = null;

      if (fee.isCustomAllowed) {
        _resolvedAmount = double.tryParse(_customAmountController.text) ?? 0.0;
      } else {
        _resolvedAmount = fee.defaultAmount;
      }
    });
  }

  void _validateAndSubmit() async {
    setState(() {
      _validationError = null;
    });

    if (_selectedBikeId == null) {
      setState(() => _validationError = 'Please select a motorcycle plate.');
      return;
    }
    if (_selectedRiderId == null) {
      setState(() => _validationError = 'Please select a registered rider.');
      return;
    }
    if (_selectedFeeTypeId == null) {
      setState(() => _validationError = 'Please select a union fee category.');
      return;
    }

    double finalAmount = _resolvedAmount;
    if (_isCustomAmount) {
      final parsed = double.tryParse(_customAmountController.text.trim());
      if (parsed == null || parsed <= 0) {
        setState(() => _validationError =
            'Invalid payment amount. Amount must be a positive number greater than 0.');
        return;
      }
      finalAmount = parsed;
    }

    if (finalAmount <= 0) {
      setState(() => _validationError =
          'Payment amount must be strictly greater than Le 0.00.');
      return;
    }

    final union = context.read<UnionController>();
    final auth = context.read<AuthController>();

    try {
      final result = await union.processPayment(
        bikeId: _selectedBikeId!,
        riderId: _selectedRiderId!,
        feeTypeId: _selectedFeeTypeId!,
        amount: finalAmount,
        paymentMethod: _selectedPaymentMethod,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        recorderProfileId: auth.currentProfile?.id,
      );

      if (!mounted) return;

      // Navigate to digital receipt screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentReceiptScreen(
            receipt: result['receipt'],
            dailyLog: result['daily_log'],
            isNewPayment: true,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _validationError = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final union = context.watch<UnionController>();

    final bikes = union.bikes;
    final feeTypes = union.feeTypes;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Direct Union Payment Gateway'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Gateway Trust Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_rounded, color: AppTheme.primaryGreen, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Zero Cash Leakage • Immutable Append-Only Ledger • Instant Digital Receipts',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreenDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 1. Select Motorcycle (Plate & Linked Rider)
            Card(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Target Motorcycle & Rider',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedBikeId,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.two_wheeler_rounded),
                        labelText: 'Select Commercial Motorcycle',
                      ),
                      items: bikes.map((b) {
                        return DropdownMenuItem<String>(
                          value: b.id,
                          child: Text('${b.plateNumber} (${b.riderName ?? "Rider"} - ${b.model})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          final selectedBike = bikes.firstWhere((b) => b.id == val);
                          setState(() {
                            _selectedBikeId = val;
                            _selectedRiderId = selectedBike.riderId;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 2. Select Union Tariff / Fee Type
            Card(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Union Tariff Category',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...feeTypes.map((fee) {
                      final isSelected = fee.id == _selectedFeeTypeId;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryGreen.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryGreen
                                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: RadioListTile<String>(
                          value: fee.id,
                          groupValue: _selectedFeeTypeId,
                          activeColor: AppTheme.primaryGreen,
                          title: Text(
                            fee.name,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            fee.description ?? '',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          secondary: Text(
                            fee.isCustomAllowed
                                ? 'Custom'
                                : AppTheme.formatLeones(fee.defaultAmount),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isSelected ? AppTheme.primaryGreen : null,
                            ),
                          ),
                          onChanged: (_) => _onFeeTypeChanged(fee),
                        ),
                      );
                    }),

                    if (_isCustomAmount) ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: _customAmountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Enter Custom Amount (Sierra Leonean Leones)',
                          prefixText: 'Le ',
                          prefixIcon: Icon(Icons.attach_money_rounded),
                          hintText: 'e.g. 50000.00',
                        ),
                        onChanged: (val) {
                          final parsed = double.tryParse(val.trim());
                          setState(() {
                            _resolvedAmount = parsed ?? 0.0;
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 3. Payment Method & Notes
            Card(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Channel & Dispatch',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedPaymentMethod,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.account_balance_wallet_rounded),
                        labelText: 'Payment Method',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'CASH_OFFICIAL',
                          child: Text('Cash at Station (Official Marshal)'),
                        ),
                        DropdownMenuItem(
                          value: 'ORANGE_MONEY',
                          child: Text('Orange Money Sierra Leone'),
                        ),
                        DropdownMenuItem(
                          value: 'AFRICEL_MONEY',
                          child: Text('Africell Money (Afrimoney)'),
                        ),
                        DropdownMenuItem(
                          value: 'CARD',
                          child: Text('Debit / ATM Card'),
                        ),
                        DropdownMenuItem(
                          value: 'ONLINE',
                          child: Text('Online Union Banking Portal'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedPaymentMethod = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Optional Memo / Station Notes',
                        hintText: 'e.g. Lumley Junction morning terminal dues',
                        prefixIcon: Icon(Icons.note_alt_outlined),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 4. Financial Summary Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Base Union Tariff', style: TextStyle(color: Colors.grey)),
                      Text(AppTheme.formatLeones(_resolvedAmount)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Platform / Gateway Fee', style: TextStyle(color: Colors.grey)),
                      Text('Le 0.00 (Zero Commission)', style: TextStyle(color: AppTheme.primaryGreen)),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Payable Amount',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        AppTheme.formatLeones(_resolvedAmount),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (_validationError != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.statusFlagged.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.statusFlagged),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppTheme.statusFlagged, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _validationError!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.statusFlagged,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Pay Action Button
            ElevatedButton(
              onPressed: union.isLoading ? null : _validateAndSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
              child: union.isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text(
                      'Confirm & Pay ${AppTheme.formatLeones(_resolvedAmount)}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
