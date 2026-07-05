import 'package:sixam_mart_store/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_store/features/auth/widgets/store_registartion_success_bottom_sheet.dart';
import 'package:sixam_mart_store/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_store/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_store/features/rental_module/profile/controllers/taxi_profile_controller.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';
import 'package:sixam_mart_store/helper/validate_check.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:sixam_mart_store/util/styles.dart';
import 'package:sixam_mart_store/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  GlobalKey<FormState>? _formKeyLogin;

  @override
  void initState() {
    super.initState();
    _formKeyLogin = GlobalKey<FormState>();
    _emailController.text = Get.find<AuthController>().getUserNumber();
    _passwordController.text = Get.find<AuthController>().getUserPassword();
    if (Get.find<AuthController>().getUserType() == 'employee') {
      Get.find<AuthController>().changeVendorType(1, isUpdate: false);
    } else {
      Get.find<AuthController>().changeVendorType(0, isUpdate: false);
    }

    _showRegistrationSuccessBottomSheet();
  }

  void _showRegistrationSuccessBottomSheet() {
    bool canShowBottomSheet = Get.find<AuthController>()
        .getIsStoreRegistrationSharedPref();
    if (canShowBottomSheet) {
      Future.delayed(const Duration(seconds: 1), () {
        showModalBottomSheet(
          context: Get.context!,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (con) => const StoreRegistrationSuccessBottomSheet(),
        ).then((value) {
          Get.find<AuthController>().saveIsStoreRegistrationSharedPref(false);
          setState(() {});
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GetBuilder<AuthController>(
          builder: (authController) {
            final SplashController splashController =
                Get.find<SplashController>();
            final bool storeRegistrationEnabled =
                splashController.configModel?.toggleStoreRegistration ?? false;

            return Stack(
              children: [
                const _LoginBackground(),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Dimensions.paddingSizeLarge,
                        Dimensions.paddingSizeDefault,
                        Dimensions.paddingSizeLarge,
                        Dimensions.paddingSizeDefault,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _ThemedAuthLogo(),
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                          Text(
                            'sign_in'.tr,
                            textAlign: TextAlign.center,
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeOverLarge,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge!.color,
                            ),
                          ),
                          const SizedBox(
                            height: Dimensions.paddingSizeExtraSmall,
                          ),
                          Text(
                            'vendor_login_subtitle'.tr,
                            textAlign: TextAlign.center,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              height: 1.25,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                          _RoleSelector(authController: authController),
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                          Form(
                            key: _formKeyLogin,
                            child: Column(
                              children: [
                                CustomTextFieldWidget(
                                  labelText: 'email'.tr,
                                  hintText: 'example@email.com',
                                  controller: _emailController,
                                  focusNode: _emailFocus,
                                  nextFocus: _passwordFocus,
                                  inputType: TextInputType.emailAddress,
                                  prefixImage: Images.mail,
                                  required: true,
                                  validator: (value) =>
                                      ValidateCheck.validateEmail(value),
                                ),
                                const SizedBox(
                                  height: Dimensions.paddingSizeDefault,
                                ),
                                CustomTextFieldWidget(
                                  labelText: 'password'.tr,
                                  hintText: 'enter_password'.tr,
                                  controller: _passwordController,
                                  focusNode: _passwordFocus,
                                  inputAction: TextInputAction.done,
                                  inputType: TextInputType.visiblePassword,
                                  prefixIcon: Icons.lock_outline_rounded,
                                  iconSize: 22,
                                  isPassword: true,
                                  required: true,
                                  onSubmit: (text) => GetPlatform.isWeb
                                      ? _login(authController)
                                      : null,
                                  validator: (value) =>
                                      ValidateCheck.validatePassword(
                                        value,
                                        null,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          _LoginOptionsRow(authController: authController),
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                          _PrimaryLoginButton(
                            isLoading: authController.isLoading,
                            onPressed: () => _login(authController),
                          ),
                          if (storeRegistrationEnabled) ...[
                            const SizedBox(height: Dimensions.paddingSizeLarge),
                            const _OrDivider(),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            const _RegistrationEntry(),
                          ],
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                          const _TrustFooter(),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _login(AuthController authController) async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String type = authController.vendorTypeIndex == 0 ? 'owner' : 'employee';

    if (_formKeyLogin!.currentState!.validate()) {
      if (email.isEmpty) {
        showCustomSnackBar('enter_email_address'.tr);
      } else if (!GetUtils.isEmail(email)) {
        showCustomSnackBar('enter_a_valid_email_address'.tr);
      } else if (password.isEmpty) {
        showCustomSnackBar('enter_password'.tr);
      } else if (password.length < 6) {
        showCustomSnackBar('password_should_be'.tr);
      } else {
        authController.login(email, password, type).then((status) async {
          if (status != null) {
            if (status.isSuccess) {
              if (authController.isActiveRememberMe) {
                authController.saveUserNumberAndPassword(email, password, type);
              } else {
                authController.clearUserNumberAndPassword();
              }
              authController.getModuleType() == 'rental'
                  ? await Get.find<TaxiProfileController>().getProfile()
                  : await Get.find<ProfileController>().getProfile();
              Get.find<ProfileController>().initTrialWidgetNotShow();
              Get.offAllNamed(RouteHelper.getInitialRoute());
            } else {
              showCustomSnackBar(status.message);
            }
          }
        });
      }
    }
  }
}

class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -130,
              left: -110,
              child: Container(
                width: 290,
                height: 290,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              top: 145,
              right: 58,
              child: Icon(
                Icons.cloud_rounded,
                size: 52,
                color: primaryColor.withValues(alpha: 0.06),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemedAuthLogo extends StatelessWidget {
  const _ThemedAuthLogo();

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return SizedBox(
      height: 104,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 2,
            child: Container(
              width: 136,
              height: 92,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              ),
            ),
          ),
          Positioned(
            left: 86,
            bottom: 10,
            child: Icon(
              Icons.inventory_2_outlined,
              size: 34,
              color: primaryColor.withValues(alpha: 0.10),
            ),
          ),
          Positioned(
            right: 86,
            top: 12,
            child: Icon(
              Icons.storefront_rounded,
              size: 42,
              color: primaryColor.withValues(alpha: 0.12),
            ),
          ),
          Container(
            width: 160,
            height: 84,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: Image.asset(
              Images.authLogo,
              width: 146,
              height: 78,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleSelector extends StatelessWidget {
  final AuthController authController;

  const _RoleSelector({required this.authController});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _RoleSegment(
              label: 'vendor_owner_short'.tr,
              icon: Icons.person_outline_rounded,
              selected: authController.vendorTypeIndex == 0,
              onTap: () => authController.changeVendorType(0),
            ),
          ),
          Expanded(
            child: _RoleSegment(
              label: 'vendor_employee_short'.tr,
              icon: Icons.badge_outlined,
              selected: authController.vendorTypeIndex == 1,
              onTap: () => authController.changeVendorType(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleSegment extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoleSegment({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color contentColor = selected
        ? primaryColor
        : Theme.of(context).hintColor;
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? primaryColor.withValues(alpha: 0.12) : null,
          borderRadius: BorderRadius.circular(28),
          border: selected
              ? Border.all(color: primaryColor.withValues(alpha: 0.22))
              : null,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: contentColor),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(
                label,
                maxLines: 1,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: contentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginOptionsRow extends StatelessWidget {
  final AuthController authController;

  const _LoginOptionsRow({required this.authController});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            onTap: authController.toggleRememberMe,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Checkbox(
                    activeColor: Theme.of(context).primaryColor,
                    value: authController.isActiveRememberMe,
                    onChanged: (bool? isChecked) =>
                        authController.toggleRememberMe(),
                  ),
                  Expanded(
                    child: Text(
                      'remember_me'.tr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (authController.vendorTypeIndex != 1)
          TextButton(
            onPressed: () => Get.toNamed(RouteHelper.getForgotPassRoute()),
            child: Text(
              '${'forgot_password'.tr}?',
              textAlign: TextAlign.end,
              style: robotoBold.copyWith(
                color: Theme.of(context).primaryColor,
                fontSize: Dimensions.fontSizeDefault,
              ),
            ),
          ),
      ],
    );
  }
}

class _PrimaryLoginButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _PrimaryLoginButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        backgroundColor: isLoading
            ? Theme.of(context).disabledColor
            : primaryColor,
        minimumSize: const Size.fromHeight(50),
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeLarge,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
      ),
      child: isLoading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Text(
                  'loading'.tr,
                  style: robotoBold.copyWith(
                    color: Colors.white,
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                const SizedBox(width: 32),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Flexible(
                        child: Text(
                          'sign_in'.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: robotoBold.copyWith(
                            color: Colors.white,
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Theme.of(context).dividerColor)),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
          ),
          child: Text(
            'or'.tr,
            style: robotoMedium.copyWith(
              color: Theme.of(context).hintColor,
              fontSize: Dimensions.fontSizeDefault,
            ),
          ),
        ),
        Expanded(child: Divider(color: Theme.of(context).dividerColor)),
      ],
    );
  }
}

class _RegistrationEntry extends StatelessWidget {
  const _RegistrationEntry();

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    return InkWell(
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      onTap: () => Get.toNamed(RouteHelper.getRestaurantRegistrationRoute()),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: primaryColor.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: 0.12),
              ),
              child: Icon(
                Icons.storefront_rounded,
                color: primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'vendor_registration_cta_title'.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault * 0.5,
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Text(
                    'vendor_registration_cta_subtitle'.tr,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(
                      color: Theme.of(context).hintColor,
                      fontSize: Dimensions.fontSizeSmall * 0.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                children: [
                  Text(
                    'vendor_registration_cta_action'.tr,
                    style: robotoBold.copyWith(
                      color: primaryColor,
                      fontSize: Dimensions.fontSizeDefault * 0.5,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Icon(Icons.chevron_right_rounded, color: primaryColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrustFooter extends StatelessWidget {
  const _TrustFooter();

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_user_outlined, size: 18, color: primaryColor),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Flexible(
              child: Text(
                'vendor_data_security_note'.tr,
                textAlign: TextAlign.center,
                style: robotoMedium.copyWith(
                  color: Theme.of(context).hintColor,
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
