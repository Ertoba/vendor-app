import 'package:sixam_mart_store/features/forgot_password/controllers/forgot_password_controller.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:sixam_mart_store/util/styles.dart';
import 'package:sixam_mart_store/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
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
    final Color primaryColor = Theme.of(context).primaryColor;

    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 230,
            height: 170,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(90),
            ),
          ),
          Positioned(
            bottom: 26,
            child: Container(
              width: 178,
              height: 104,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor.withValues(alpha: 0.16),
                    primaryColor.withValues(alpha: 0.32),
                  ],
                ),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(color: primaryColor.withValues(alpha: 0.18)),
              ),
              child: Icon(
                Icons.mark_email_read_outlined,
                color: primaryColor,
                size: 58,
              ),
            ),
          ),
          Positioned(
            top: 42,
            child: Container(
              width: 118,
              height: 112,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Icon(Icons.lock_rounded, color: primaryColor, size: 58),
            ),
          ),
          Positioned(
            right: 60,
            bottom: 36,
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.sync_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
          ),
        ],
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
          : Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  'next'.tr,
                  style: robotoBold.copyWith(
                    color: Colors.white,
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
                const Positioned(
                  right: 18,
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
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
              'თქვენი მეილი  დაცულია',
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
