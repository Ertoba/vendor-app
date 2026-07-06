import 'package:sixam_mart_store/features/forgot_password/controllers/forgot_password_controller.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:sixam_mart_store/util/styles.dart';
import 'package:sixam_mart_store/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class ForgetPassScreen extends StatefulWidget {
  const ForgetPassScreen({super.key});

  @override
  State<ForgetPassScreen> createState() => _ForgetPassScreenState();
}

class _ForgetPassScreenState extends State<ForgetPassScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'forgot_password'.tr),
      backgroundColor: Theme.of(context).cardColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                Dimensions.paddingSizeDefault,
                Dimensions.paddingSizeDefault,
                Dimensions.paddingSizeDefault,
                MediaQuery.of(context).viewInsets.bottom +
                    Dimensions.paddingSizeDefault,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: SizedBox(
                    width: 500,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _ForgotPasswordIllustration(),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        Text(
                          'შეიყვანე შენი ელ-ფოსტა\nპაროლის აღდგენისთვის',
                          textAlign: TextAlign.center,
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeExtraLarge,
                            height: 1.25,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Text(
                          'ჩვენ გამოგიგზავნით ბმულს, რომლის საშუალებითაც შეძლებთ პაროლის აღდგენას.',
                          textAlign: TextAlign.center,
                          style: robotoRegular.copyWith(
                            color: Theme.of(context).hintColor,
                            fontSize: Dimensions.fontSizeSmall,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(
                          height: Dimensions.paddingSizeExtraLarge,
                        ),

                        CustomTextFieldWidget(
                          controller: _emailController,
                          inputType: TextInputType.emailAddress,
                          inputAction: TextInputAction.done,
                          hintText: 'enter_email'.tr,
                          labelText: 'email'.tr,
                          prefixImage: Images.mail,
                          onSubmit: (text) =>
                              GetPlatform.isWeb ? _forgetPass() : null,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        GetBuilder<ForgotPasswordController>(
                          builder: (forgotPasswordController) {
                            return _RecoverButton(
                              isLoading: forgotPasswordController.isLoading,
                              onPressed: _forgetPass,
                            );
                          },
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        const _SecureMailCard(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _forgetPass() {
    String email = _emailController.text.trim();
    if (email.isEmpty) {
      showCustomSnackBar('enter_email_address'.tr);
    } else if (!GetUtils.isEmail(email)) {
      showCustomSnackBar('enter_a_valid_email_address'.tr);
    } else {
      Get.find<ForgotPasswordController>().forgetPassword(email).then((
        status,
      ) async {
        if (status.isSuccess) {
          Get.toNamed(RouteHelper.getVerificationRoute(email));
        } else {
          showCustomSnackBar(status.message);
        }
      });
    }
  }
}

class _ForgotPasswordIllustration extends StatelessWidget {
  const _ForgotPasswordIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: SvgPicture.asset(
        Images.vendorForgotPasswordIllustration,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _RecoverButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _RecoverButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        backgroundColor: isLoading
            ? Theme.of(context).disabledColor
            : primaryColor,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              'next'.tr,
              style: robotoBold.copyWith(
                color: Colors.white,
                fontSize: Dimensions.fontSizeLarge,
              ),
            ),
    );
  }
}

class _SecureMailCard extends StatelessWidget {
  const _SecureMailCard();

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_user_outlined, color: primaryColor, size: 28),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Text(
              'თქვენი მონაცემები უსაფრთხოდ ინახება',
              style: robotoBold.copyWith(
                color: primaryColor,
                fontSize: Dimensions.fontSizeDefault,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
