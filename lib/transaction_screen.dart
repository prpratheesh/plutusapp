import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pl_integration_tester/terminal_functions.dart';
import 'dart:async';
import 'package:pl_integration_tester/terminal_routines.dart';

class Transaction extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<Transaction> with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _title() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 18,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
            text: 'Transaction',
            style: GoogleFonts.portLligatSans(
              textStyle: Theme.of(context).textTheme.bodyLarge,
              fontSize: 35,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(0)),
              gradient: LinearGradient(
                colors: [Color(0xff00bf8f), Color(0xff001510)],
                stops: [0, 1],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _title(),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
