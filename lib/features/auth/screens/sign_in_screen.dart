import 'package:sixam_mart_store/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_store/features/auth/widgets/store_registartion_success_bottom_sheet.dart';
import 'package:sixam_mart_store/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_store/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart_store/features/rental_module/profile/controllers/taxi_profile_controller.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';
import 'package:sixam_mart_store/helper/validate_check.dart';
import 'package:sixam_mart_store/util/images.dart';
import 'package:sixam_mart_store/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_store/features/auth/widgets/mili_auth_ui.dart';
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
        if (!mounted) return;
        showModalBottomSheet(
          context: Get.context!,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (con) => const StoreRegistrationSuccessBottomSheet(),
        ).then((value) {
          Get.find<AuthController>().saveIsStoreRegistrationSharedPref(false);
          if (mounted) setState(() {});
        });
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    resizeToAvoidBottomInset: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    body: SafeArea(
      child: GetBuilder<AuthController>(
        builder: (authController) {
          final registrationEnabled =
              Get.find<SplashController>()
                  .configModel
                  ?.toggleStoreRegistration ??
              false;
          void submit() {
            if (!authController.isLoading) _login(authController);
          }

          return MiliAuthLayout(
            logoAsset: Images.brandMark,
            children: [
              MiliAuthIntro(
                title: 'auth_ui_title'.tr,
                subtitle: 'auth_ui_vendor_subtitle'.tr,
              ),
              Text(
                'auth_ui_account_type'.tr,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              SegmentedButton<int>(
                segments: [
                  ButtonSegment(
                    value: 0,
                    label: Text('vendor_owner_short'.tr),
                    icon: const Icon(Icons.person_outline_rounded, size: 18),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: Text('vendor_employee_short'.tr),
                    icon: const Icon(Icons.badge_outlined, size: 18),
                  ),
                ],
                selected: {authController.vendorTypeIndex},
                showSelectedIcon: false,
                onSelectionChanged: authController.isLoading
                    ? null
                    : (selection) =>
                          authController.changeVendorType(selection.first),
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: Theme.of(
                    context,
                  ).primaryColor.withValues(alpha: .1),
                  selectedForegroundColor: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.color,
                  foregroundColor: authMuted(context),
                  textStyle: TextStyle(
                    fontFamily: Get.locale?.languageCode == 'ka'
                        ? 'MiliAuthGeorgian'
                        : null,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  minimumSize: const Size(0, 50),
                  side: BorderSide(color: authBorder(context)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Form(
                key: _formKeyLogin,
                child: Column(
                  children: [
                    MiliAuthField(
                      label: 'email'.tr,
                      hint: 'example@email.com',
                      controller: _emailController,
                      focusNode: _emailFocus,
                      nextFocus: _passwordFocus,
                      inputType: TextInputType.emailAddress,
                      autofillHints: const [
                        AutofillHints.username,
                        AutofillHints.email,
                      ],
                      validator: (value) => ValidateCheck.validateEmail(value),
                    ),
                    const SizedBox(height: 18),
                    MiliAuthField(
                      label: 'password'.tr,
                      hint: 'enter_password'.tr,
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      inputAction: TextInputAction.done,
                      inputType: TextInputType.visiblePassword,
                      isPassword: true,
                      onSubmit: (_) => submit(),
                      validator: (value) =>
                          ValidateCheck.validatePassword(value, null),
                    ),
                  ],
                ),
              ),
              MiliAuthOptions(
                remember: authController.isActiveRememberMe,
                onRemember: authController.toggleRememberMe,
                onForgot: authController.vendorTypeIndex == 1
                    ? null
                    : () => Get.toNamed(RouteHelper.getForgotPassRoute()),
              ),
              MiliAuthSubmit(
                loading: authController.isLoading,
                label: 'sign_in'.tr,
                onPressed: submit,
              ),
              if (registrationEnabled)
                MiliAuthSecondary(
                  label: 'vendor_registration_cta_action'.tr,
                  description: 'vendor_registration_cta_title'.tr,
                  icon: Icons.storefront_outlined,
                  onPressed: () =>
                      Get.toNamed(RouteHelper.getRestaurantRegistrationRoute()),
                ),
            ],
          );
        },
      ),
    ),
  );

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
