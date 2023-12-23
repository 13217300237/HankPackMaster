import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

class ToastUtil {
  static void showPrettyToast(String msg) {
    showToastWidget(
      AnimatedContainer(
        duration: const Duration(milliseconds: 1500),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          gradient: const LinearGradient(
            colors: [Colors.green, Colors.yellow],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        width: 200,
        height: 50,
        child: Center(
          child: Text(
            msg,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      position: ToastPosition.center,
      duration: const Duration(seconds: 2),
    );
  }
}
