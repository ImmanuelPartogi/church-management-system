import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Production form text field component with label, error text, helper,
/// prefix/suffix icon, validator, keyboard actions, inputFormatters, readOnly, and onTap.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.controller,
    super.key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLines: maxLines,
          maxLength: maxLength,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          validator: validator,
          enabled: enabled,
          readOnly: readOnly,
          onTap: onTap,
          inputFormatters: inputFormatters,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hintText,
            helperText: helperText,
            errorText: errorText,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

/// Search text field component with built-in clear button.
class SearchField extends StatelessWidget {
  const SearchField({
    required this.controller,
    required this.onChanged,
    super.key,
    this.hintText = 'Cari...',
    this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                  if (onClear != null) onClear!();
                },
              )
            : null,
      ),
    );
  }
}
