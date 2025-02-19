import 'package:flutter/material.dart';
import 'package:yunji/main/global.dart';

void dialogTwoButton({
  required BuildContext context,
  required String title,
  required String message,
  required String buttonLeft,
  required String buttonRight,
  required VoidCallback onConfirmLifeMode,
  required VoidCallback onConfirmRightMode,
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
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          '取消',
                          style: AppTextStyle.textStyle,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: onConfirmLifeMode,
                          child: Text(
                            buttonLeft,
                            style: AppTextStyle.textStyle,
                          ),
                        ),
                        TextButton(
                          onPressed: onConfirmRightMode,
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

void buildDialog({
  required BuildContext context,
  required String title,
  required String content,
  required VoidCallback onConfirm,
  required String buttonRight,
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
                  content,
                  style: AppTextStyle.textStyle,
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
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
                    TextButton(
                      onPressed: onConfirm,
                      child: Text(
                        buttonRight,
                        style: AppTextStyle.textStyle,
                      ),
                    ),
                    const SizedBox(width: 10),
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
