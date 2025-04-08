import 'package:flutter/material.dart';
import 'package:getFit/util/colors.dart';
import 'package:getFit/util/textstyles.dart';
import 'package:getFit/util/dimensions.dart';
import 'package:getFit/util/buttons.dart';

class Register1 extends StatefulWidget {
  @override
  _Register1State createState() => _Register1State();
}

class _Register1State extends State<Register1> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register', style: AppTextStyles.header),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Padding(
        padding: Dimensions.mediumPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Name", style: AppTextStyles.regular),
              const SizedBox(height: Dimensions.regular),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(),
                  contentPadding: Dimensions.mediumPadding,
                ),
              ),
              const SizedBox(height: Dimensions.medium),

              Text("Email", style: AppTextStyles.regular),
              const SizedBox(height: Dimensions.regular),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(),
                  contentPadding: Dimensions.mediumPadding,
                ),
              ),
              const SizedBox(height: Dimensions.medium),

              Text("Password", style: AppTextStyles.regular),
              const SizedBox(height: Dimensions.regular),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(),
                  contentPadding: Dimensions.mediumPadding,
                ),
              ),

              const SizedBox(height: Dimensions.extraLarge),
              SizedBox(
                width: double.infinity,
                height: ButtonDimensions.height,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: ButtonDimensions.borderRadiusGeometry,
                    ),
                    padding: ButtonDimensions.padding,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      print("Form is valid");
                      // register2 ye navigate
                    }
                  },
                  child: Text('Next', style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

