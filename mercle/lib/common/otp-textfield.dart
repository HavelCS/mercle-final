import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class OtpTextField extends StatefulWidget {
  final Function(String)? onCompleted;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final bool hasError;
  
  const OtpTextField({
    super.key,
    this.onCompleted,
    this.onChanged,
    this.controller,
    this.hasError = false,
  });
  
  // Method to clear the text field
  static void clearController(TextEditingController controller) {
    controller.clear();
  }

  @override
  State<OtpTextField> createState() => _OtpTextFieldState();
}

class _OtpTextFieldState extends State<OtpTextField> {
  late TextEditingController pinController;
  final formKey = GlobalKey<FormState>();
  
  @override
  void initState() {
    super.initState();
    pinController = widget.controller ?? TextEditingController();
  }

  final focusedBorderColor = Colors.black;

  final fillColor = const Color.fromRGBO(243, 246, 249, 0);
  final borderColor = Colors.grey[800]!;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Determine border color based on error state
    final borderColor = widget.hasError 
        ? Colors.red 
        : Colors.grey;
    
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 22,
        color: Colors.white,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
    );

    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Directionality(
            // Specify direction if desired
            textDirection: TextDirection.ltr,
            child: Pinput(
              length: 6,
              controller: pinController,
              defaultPinTheme: defaultPinTheme,
              hapticFeedbackType: HapticFeedbackType.lightImpact,
              onCompleted: (pin) {
                debugPrint('onCompleted: $pin');
                widget.onCompleted?.call(pin);
              },
              onChanged: (value) {
                debugPrint('onChanged: $value');
                widget.onChanged?.call(value);
              },
              cursor: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 9),
                    width: 24,
                    height: 2,
                    color: theme.textTheme.bodyLarge?.color ?? Colors.black,
                  ),
                ],
              ),
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.hasError ? Colors.red : theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              submittedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  color: widget.hasError 
                      ? Colors.red.withOpacity(0.1) 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: widget.hasError ? Colors.red : theme.colorScheme.primary,
                  ),
                ),
              ),
              errorPinTheme: defaultPinTheme.copyBorderWith(
                border: Border.all(color: theme.colorScheme.error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Only dispose if we created the controller
    if (widget.controller == null) {
      pinController.dispose();
    }
    super.dispose();
  }
}
