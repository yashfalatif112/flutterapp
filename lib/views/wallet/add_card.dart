import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homease/widgets/dialog.dart';
import 'package:flutter/services.dart';

class AddNewCardScreen extends StatefulWidget {
  final String? currentUserId;
  final VoidCallback onCardAdded;

  const AddNewCardScreen({
    super.key,
    required this.currentUserId,
    required this.onCardAdded,
  });

  @override
  State<AddNewCardScreen> createState() => _AddNewCardScreenState();
}

class _AddNewCardScreenState extends State<AddNewCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _cardNameController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  String _formatCardNumber(String input) {
    // Remove all non-digit characters
    input = input.replaceAll(RegExp(r'\D'), '');

    // Split into groups of 4
    List<String> groups = [];
    for (int i = 0; i < input.length; i += 4) {
      if (i + 4 <= input.length) {
        groups.add(input.substring(i, i + 4));
      } else {
        groups.add(input.substring(i));
      }
    }

    // Join with spaces
    return groups.join(' ');
  }

  bool _isValidExpiryDate(String month, String year) {
    try {
      final currentDate = DateTime.now();
      final expMonth = int.parse(month);
      final expYear = 2000 + int.parse(year);

      if (expMonth < 1 || expMonth > 12) return false;

      if (expYear < currentDate.year) return false;
      if (expYear == currentDate.year && expMonth < currentDate.month)
        return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  void _handleExpiryDateInput(String value) {
    String numbers = value.replaceAll(RegExp(r'\D'), '');

    if (numbers.length >= 1) {
      int month = int.tryParse(numbers.substring(0, 1)) ?? 0;
      // First digit of month can only be 0 or 1
      if (month > 1) {
        numbers = '0$month${numbers.substring(1)}';
      }
    }

    if (numbers.length >= 2) {
      int month = int.tryParse(numbers.substring(0, 2)) ?? 0;
      // Month cannot be greater than 12
      if (month > 12) {
        numbers = '12${numbers.substring(2)}';
      }
    }

    String formatted = '';
    if (numbers.length >= 2) {
      formatted = '${numbers.substring(0, 2)}/${numbers.substring(2)}';
    } else {
      formatted = numbers;
    }

    _expiryDateController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _handleCvvInput(String value) {
    // Remove all non-digit characters
    String numbers = value.replaceAll(RegExp(r'\D'), '');

    // Limit to 3 digits
    if (numbers.length > 3) {
      numbers = numbers.substring(0, 3);
    }

    _cvvController.value = TextEditingValue(
      text: numbers,
      selection: TextSelection.collapsed(offset: numbers.length),
    );
  }

  Future<void> _saveCardToFirebase() async {
    if (_formKey.currentState?.validate() != true ||
        widget.currentUserId == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId);

      final newCard = {
        'cardName': _cardNameController.text.trim(),
        'cardNumber': _cardNumberController.text.replaceAll(' ', '').trim(),
        'expiryDate': _expiryDateController.text.trim(),
        'cvv': _cvvController.text.trim(),
        'addedAt': Timestamp.now(),
      };

      final userDoc = await userRef.get();

      if (userDoc.exists) {
        if (userDoc.data()!.containsKey('cards')) {
          await userRef.update({
            'cards': FieldValue.arrayUnion([newCard])
          });
        } else {
          await userRef.update({
            'cards': [newCard]
          });
        }
      } else {
        await userRef.set({
          'cards': [newCard]
        });
      }

      setState(() {
        _isLoading = false;
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ThankYouDialog(
          titleText: 'Card Added',
          subtitleText: 'Your card has been added successfully',
          buttonText: 'Continue',
          onPressed: () {
            widget.onCardAdded();
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add card: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFFDFCF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFCF7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title:
            const Text('Add New Card', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xff48B1DB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.credit_card,
                          color: Colors.white, size: 28),
                      const SizedBox(height: 16),
                      Text(
                        _cardNumberController.text.isEmpty
                            ? '1234 5678 8765 0876'
                            : _cardNumberController.text,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            letterSpacing: 2),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'VALID THRU    ${_expiryDateController.text.isEmpty ? '12/28' : _expiryDateController.text}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _cardNameController.text.isEmpty
                            ? 'CARD HOLDER'
                            : _cardNameController.text.toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _cardNameController,
                  decoration: InputDecoration(
                    labelText: 'Card Name',
                    hintText: 'Card Holder Name',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xff48B1DB)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter card holder name';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cardNumberController,
                  decoration: InputDecoration(
                    labelText: 'Card Number',
                    hintText: '1234 5678 9012 3456',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xff48B1DB)),
        ),
                    counterText: '', // This removes the character counter
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 19, // 16 digits + 3 spaces
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter card number';
                    }
                    final numbers = value.replaceAll(' ', '');
                    if (numbers.length != 16) {
                      return 'Card number must be 16 digits';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    final formatted = _formatCardNumber(value);
                    if (formatted != value) {
                      _cardNumberController.value = TextEditingValue(
                        text: formatted,
                        selection:
                            TextSelection.collapsed(offset: formatted.length),
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expiryDateController,
                        decoration: InputDecoration(
                          labelText: 'Expiry Date',
                          hintText: 'MM/YY',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xff48B1DB)),
        ),
                          counterText: '', // This removes the character counter
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter expiry date';
                          }
                          if (!value.contains('/')) {
                            return 'Invalid format';
                          }
                          final parts = value.split('/');
                          if (parts.length != 2) {
                            return 'Invalid format';
                          }
                          if (!_isValidExpiryDate(parts[0], parts[1])) {
                            return 'Invalid expiry date';
                          }
                          return null;
                        },
                        onChanged: _handleExpiryDateInput,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _cvvController,
                        decoration: InputDecoration(
                          labelText: 'CVV',
                          hintText: '123',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xff48B1DB)),
        ),
                          counterText: '', // This removes the character counter
                        ),
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        maxLength: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          if (value.length != 3) {
                            return 'CVV must be 3 digits';
                          }
                          return null;
                        },
                        onChanged: _handleCvvInput,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveCardToFirebase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff48B1DB),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Add',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
