import 'package:flutter/material.dart';
import 'package:yunji/main/global.dart';

void showDialogTwoButton({
  required BuildContext context,
  required String title,
  required String message,
  required String buttonLeft,
  required String buttonRight,
  required VoidCallback onConfirmDayMode,
  required VoidCallback onConfirmNightMode,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        backgroundColor: AppColors.background,
        child: SizedBox(
          height: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 25, top: 20),
                child: Text(
                  title,
                  style: AppTextStyle.titleStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25, top: 10, bottom: 10),
                child: Text(
                  message,
                  style: AppTextStyle.textStyle,
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        '取消',
                        style: AppTextStyle.textStyle,
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: onConfirmDayMode,
                          child: Text(
                            buttonLeft,
                            style: AppTextStyle.textStyle,
                          ),
                        ),
                        TextButton(
                          onPressed: onConfirmNightMode,
                          child: Text(
                            buttonRight,
                            style: AppTextStyle.textStyle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
