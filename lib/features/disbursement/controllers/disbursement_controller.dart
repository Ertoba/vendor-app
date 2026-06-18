import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/features/disbursement/domain/models/disbursement_method_model.dart'
    as disburse;
import 'package:sixam_mart_store/features/disbursement/domain/models/disbursement_report_model.dart'
    as report;
import 'package:sixam_mart_store/common/widgets/custom_dropdown_widget.dart';
import 'package:sixam_mart_store/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_store/features/disbursement/domain/services/disbursement_service_interface.dart';
import 'package:sixam_mart_store/features/payment/controllers/payment_controller.dart';
import 'package:sixam_mart_store/features/payment/domain/models/widthdrow_method_model.dart';

class DisbursementController extends GetxController implements GetxService {
  final DisbursementServiceInterface disbursementServiceInterface;
  DisbursementController({required this.disbursementServiceInterface});

  static const String keepzSplitMethodName = 'Keepz Split Receiver';
  static const String keepzReceiverTypeField = 'keepz_receiver_type';
  static const String keepzReceiverIdentifierField =
      'keepz_receiver_identifier';
  static const List<String> keepzReceiverTypes = ['BRANCH', 'IBAN'];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isDeleteLoading = false;
  bool get isDeleteLoading => _isDeleteLoading;

  int? _selectedMethodIndex = 0;
  int? get selectedMethodIndex => _selectedMethodIndex;

  List<DropdownItem<int>> _methodList = [];
  List<DropdownItem<int>> get methodList => _methodList;

  List<TextEditingController> _textControllerList = [];
  List<TextEditingController> get textControllerList => _textControllerList;

  List<MethodFields> _methodFields = [];
  List<MethodFields> get methodFields => _methodFields;

  List<FocusNode> _focusList = [];
  List<FocusNode> get focusList => _focusList;

  List<WidthDrawMethodModel>? _widthDrawMethods;
  List<WidthDrawMethodModel>? get widthDrawMethods => _widthDrawMethods;

  disburse.DisbursementMethodBody? _disbursementMethodBody;
  disburse.DisbursementMethodBody? get disbursementMethodBody =>
      _disbursementMethodBody;

  report.DisbursementReportModel? _disbursementReportModel;
  report.DisbursementReportModel? get disbursementReportModel =>
      _disbursementReportModel;

  int? get index => _index;
  int? _index = -1;

  String _selectedKeepzReceiverType = keepzReceiverTypes.first;
  String get selectedKeepzReceiverType => _selectedKeepzReceiverType;
  bool get isKeepzSplitSelected {
    if (_widthDrawMethods == null ||
        _widthDrawMethods!.isEmpty ||
        _selectedMethodIndex == null) {
      return false;
    }

    final WidthDrawMethodModel selectedMethod =
        _widthDrawMethods![_selectedMethodIndex!];
    return selectedMethod.methodName == keepzSplitMethodName ||
        (selectedMethod.methodFields ?? []).any(
          (field) => field.inputName == keepzReceiverIdentifierField,
        );
  }

  Future<void> addWithdrawMethod(Map<String?, String> data) async {
    _isLoading = true;
    update();
    bool isSuccess = await disbursementServiceInterface.addWithdraw(data);
    if (isSuccess) {
      Get.back();
      getDisbursementMethodList();
      showCustomSnackBar('add_successfully'.tr, isError: false);
    }
    _isLoading = false;
    update();
  }

  Future<bool> getDisbursementMethodList() async {
    bool success = false;
    try {
      disburse.DisbursementMethodBody? disbursementMethodBody =
          await disbursementServiceInterface.getDisbursementMethodList();
      if (disbursementMethodBody != null) {
        success = true;
        _disbursementMethodBody = disbursementMethodBody;
      } else {
        _disbursementMethodBody = disburse.DisbursementMethodBody(
          totalSize: 0,
          limit: '10',
          offset: '1',
          methods: [],
        );
      }
    } catch (_) {
      _disbursementMethodBody = disburse.DisbursementMethodBody(
        totalSize: 0,
        limit: '10',
        offset: '1',
        methods: [],
      );
    }
    update();
    return success;
  }

  Future<void> makeDefaultMethod(Map<String, String> data, int index) async {
    _index = index;
    _isLoading = true;
    update();
    bool isSuccess = await disbursementServiceInterface.makeDefaultMethod(data);
    if (isSuccess) {
      _index = -1;
      getDisbursementMethodList();
      showCustomSnackBar('set_default_method_successful'.tr, isError: false);
    }
    _isLoading = false;
    update();
  }

  Future<void> deleteMethod(int id) async {
    _isDeleteLoading = true;
    update();
    bool isSuccess = await disbursementServiceInterface.deleteMethod(id);
    if (isSuccess) {
      getDisbursementMethodList();
      Get.back();
      showCustomSnackBar('method_delete_successfully'.tr, isError: false);
    }
    _isDeleteLoading = false;
    update();
  }

  Future<void> getDisbursementReport(int offset) async {
    report.DisbursementReportModel? disbursementReportModel =
        await disbursementServiceInterface.getDisbursementReport(offset);
    if (disbursementReportModel != null) {
      _disbursementReportModel = disbursementReportModel;
    }
    update();
  }

  void setMethodId(int? id, {bool canUpdate = true}) {
    _selectedMethodIndex = id;
    if (canUpdate) {
      update();
    }
  }

  Future<void> setMethod({bool isUpdate = true, bool initCall = false}) async {
    _methodList = [];
    _textControllerList = [];
    _methodFields = [];
    _focusList = [];

    if (Get.find<PaymentController>().widthDrawMethods == null) {
      _widthDrawMethods = await Get.find<PaymentController>()
          .getWithdrawMethodList();
    } else {
      _widthDrawMethods = Get.find<PaymentController>().widthDrawMethods;
    }
    if (_widthDrawMethods != null && _widthDrawMethods!.isNotEmpty) {
      if (_selectedMethodIndex == null ||
          _selectedMethodIndex! >= _widthDrawMethods!.length) {
        _selectedMethodIndex = 0;
      }
      for (int i = 0; i < _widthDrawMethods!.length; i++) {
        _methodList.add(
          DropdownItem<int>(
            value: i,
            child: SizedBox(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('${_widthDrawMethods![i].methodName}'),
              ),
            ),
          ),
        );
      }
      if (initCall) {
        _selectedMethodIndex = 0;
      }
      _textControllerList = [];
      _methodFields = [];
      for (var field
          in _widthDrawMethods![_selectedMethodIndex!].methodFields ??
              <MethodFields>[]) {
        _methodFields.add(field);
        _textControllerList.add(TextEditingController());
        _focusList.add(FocusNode());
      }
      if (isKeepzSplitSelected) {
        _selectedKeepzReceiverType = keepzReceiverTypes.first;
        _setKeepzReceiverTypeController(_selectedKeepzReceiverType);
      }
    }
    if (isUpdate) {
      update();
    }
  }

  void setKeepzReceiverType(String type) {
    if (!keepzReceiverTypes.contains(type)) {
      return;
    }

    _selectedKeepzReceiverType = type;
    _setKeepzReceiverTypeController(type);

    final int identifierIndex = _fieldIndex(keepzReceiverIdentifierField);
    if (identifierIndex != -1) {
      _textControllerList[identifierIndex].clear();
    }

    update();
  }

  String? validateSelectedMethod() {
    bool fieldEmpty = false;
    for (var element in _methodFields) {
      if (element.isRequired == 1) {
        if (_textControllerList[_methodFields.indexOf(element)].text
            .trim()
            .isEmpty) {
          fieldEmpty = true;
        }
      }
    }

    if (fieldEmpty) {
      return 'required_fields_can_not_be_empty';
    }

    if (!isKeepzSplitSelected) {
      return null;
    }

    final int typeIndex = _fieldIndex(keepzReceiverTypeField);
    final int identifierIndex = _fieldIndex(keepzReceiverIdentifierField);

    if (typeIndex == -1 || identifierIndex == -1) {
      return 'required_fields_can_not_be_empty';
    }

    final String type = _textControllerList[typeIndex].text
        .trim()
        .toUpperCase();
    final String identifier = normalizeKeepzReceiverIdentifier(
      type,
      _textControllerList[identifierIndex].text,
    );

    if (!keepzReceiverTypes.contains(type)) {
      return 'please_select_keepz_receiver_type';
    }

    if (type == 'IBAN' &&
        !RegExp(r'^GE\d{2}[A-Z]{2}\d{16}$').hasMatch(identifier)) {
      return 'enter_valid_keepz_iban';
    }

    if (type == 'BRANCH' &&
        !RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
          caseSensitive: false,
        ).hasMatch(identifier)) {
      return 'enter_valid_keepz_branch_receiver';
    }

    return null;
  }

  Map<String?, String> buildWithdrawMethodPayload() {
    Map<String?, String> data = {};
    data['withdraw_method_id'] = _widthDrawMethods![_selectedMethodIndex!].id
        .toString();

    for (var result in _methodFields) {
      final int index = _methodFields.indexOf(result);
      final String inputName = result.inputName ?? '';
      String value = _textControllerList[index].text.trim();

      if (isKeepzSplitSelected && inputName == keepzReceiverTypeField) {
        value = value.toUpperCase();
      }

      if (isKeepzSplitSelected && inputName == keepzReceiverIdentifierField) {
        value = normalizeKeepzReceiverIdentifier(
          _selectedKeepzReceiverType,
          value,
        );
      }

      data[inputName] = value;
    }

    return data;
  }

  String normalizeKeepzReceiverIdentifier(String type, String value) {
    if (type == 'IBAN') {
      return value.replaceAll(RegExp(r'\s+'), '').toUpperCase();
    }

    return value.trim().toLowerCase();
  }

  int _fieldIndex(String inputName) {
    return _methodFields.indexWhere((field) => field.inputName == inputName);
  }

  void _setKeepzReceiverTypeController(String type) {
    final int typeIndex = _fieldIndex(keepzReceiverTypeField);
    if (typeIndex != -1) {
      _textControllerList[typeIndex].text = type;
    }
  }
}
