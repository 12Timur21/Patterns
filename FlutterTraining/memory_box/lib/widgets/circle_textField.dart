import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum TypeValidation {
  phoneValidation,
  smsValidation,
}

class CircleTextField extends StatefulWidget {
  const CircleTextField({
    required this.controller,
    this.inputFormatters,
    this.editable = true,
    this.labelText,
    this.validator,
    this.errorText,
    this.maxLength,
    Key? key,
  }) : super(key: key);

  final TextEditingController controller;
  final List<TextInputFormatter>? inputFormatters;
  final bool editable;
  final String? Function(String?)? validator;
  final String? labelText;
  final String? errorText;
  final int? maxLength;

  @override
  State<CircleTextField> createState() => _CircleTextFieldState();
}

class _CircleTextFieldState extends State<CircleTextField> {
  @override
  Widget build(BuildContext context) {
    String? _errorText = widget.errorText;

    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(41),
            ),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.17),
                blurRadius: 11,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            enabled: widget.editable,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.phone,
            inputFormatters: widget.inputFormatters,
            maxLength: widget.maxLength,
            onChanged: (_) => setState(() {
              _errorText = null;
            }),
            validator: widget.validator,
            style: const TextStyle(
              fontFamily: 'TTNorms',
              fontWeight: FontWeight.w400,
              fontSize: 20,
            ),
            decoration: InputDecoration(
              labelText: widget.labelText,
              counterText: '',
              errorText: null,
              errorStyle: const TextStyle(
                height: 0,
                fontSize: 0,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 0,
                vertical: 23,
              ),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(41.0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(41),
                borderSide: BorderSide(
                  color: _errorText != null ? Colors.red : Colors.blue,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(41),
                borderSide: BorderSide(
                  color: _errorText != null ? Colors.red : Colors.blue,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(41),
                borderSide: const BorderSide(
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            _errorText ?? '',
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
