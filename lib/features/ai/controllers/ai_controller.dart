import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/features/ai/domain/models/attribute_data_model.dart';
import 'package:sixam_mart_store/features/ai/domain/services/ai_service_interface.dart';
import 'package:sixam_mart_store/features/ai/domain/models/other_data_model.dart';
import 'package:sixam_mart_store/features/ai/domain/models/title_des_model.dart';
import 'package:sixam_mart_store/features/ai/domain/models/title_suggestion_model.dart';
import 'package:sixam_mart_store/features/ai/domain/models/variation_data_model.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:sixam_mart_store/features/profile/controllers/profile_controller.dart';

class AiController extends GetxController implements GetxService {
  final AiServiceInterface aiServiceInterface;
  AiController({required this.aiServiceInterface});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _titleLoading = false;
  bool get titleLoading => _titleLoading;

  bool _otherDataLoading = false;
  bool get otherDataLoading => _otherDataLoading;

  bool _variationDataLoading = false;
  bool get variationDataLoading => _variationDataLoading;

  bool _imageLoading = false;
  bool get imageLoading => _imageLoading;

  TitleDesModel? _titleDesModel;
  TitleDesModel? get titleDesModel => _titleDesModel;

  OtherDataModel? _otherDataModel;
  OtherDataModel? get otherDataModel => _otherDataModel;

  VariationDataModel? _variationDataModel;
  VariationDataModel? get variationDataModel => _variationDataModel;

  AttributeDataModel? _attributeDataModel;
  AttributeDataModel? get attributeDataModel => _attributeDataModel;

  TitleSuggestionModel? _titleSuggestionModel;
  TitleSuggestionModel? get titleSuggestionModel => _titleSuggestionModel;

  List<String?> _keyWordList = [];
  List<String?> get keyWordList => _keyWordList;

  String _requestType = '';
  String get requestType => _requestType;

  void setRequestType(String type, {bool willUpdate = true}) {
    _requestType = type;
    if (willUpdate) {
      update();
    }
  }

  void setKeyWord(String? name, {bool willUpdate = true}) {
    _keyWordList.add(name);
    if (willUpdate) {
      update();
    }
  }

  void initializeKeyWords() {
    _keyWordList = [];
  }

  void removeKeyWord(int index) {
    _keyWordList.removeAt(index);
    update();
  }

  ({String storeId, String moduleType, int moduleId}) _requestContext() {
    final profile = Get.find<ProfileController>().profileModel;
    final store = profile?.stores?.isNotEmpty == true
        ? profile!.stores!.first
        : null;
    final module = store?.module;
    if (profile?.id == null ||
        module?.moduleType == null ||
        module?.id == null) {
      throw StateError('AI request context is not ready');
    }
    return (
      storeId: profile!.id.toString(),
      moduleType: module!.moduleType!,
      moduleId: module.id!,
    );
  }

  Future<void> generateTitleAndDes({
    required String title,
    required String langCode,
  }) async {
    if (_titleLoading) return;
    _titleLoading = true;
    _titleDesModel = null;
    update();

    try {
      final context = _requestContext();
      _titleDesModel = await aiServiceInterface.generateTitleAndDes(
        title: title,
        langCode: langCode,
        storeId: context.storeId,
        moduleType: context.moduleType,
        generateFrom: _requestType,
      );
    } catch (error) {
      debugPrint('AI title and description generation failed: $error');
    } finally {
      _titleLoading = false;
      update();
    }
  }

  Future<void> generateOtherData({
    required String title,
    required String description,
  }) async {
    if (_otherDataLoading) return;
    _otherDataLoading = true;
    _otherDataModel = null;
    update();

    try {
      final context = _requestContext();
      _otherDataModel = await aiServiceInterface.generateOtherData(
        title: title,
        description: description,
        storeId: context.storeId,
        moduleType: context.moduleType,
        generateFrom: _requestType,
        moduleId: context.moduleId,
      );
    } catch (error) {
      debugPrint('AI other data generation failed: $error');
    } finally {
      _otherDataLoading = false;
      update();
    }
  }

  Future<void> generateVariationData({
    required String title,
    required String description,
  }) async {
    if (_variationDataLoading) return;
    _variationDataLoading = true;
    _variationDataModel = null;
    update();

    try {
      final context = _requestContext();
      _variationDataModel = await aiServiceInterface.generateVariationData(
        title: title,
        description: description,
        storeId: context.storeId,
        moduleType: context.moduleType,
        generateFrom: _requestType,
      );
    } catch (error) {
      debugPrint('AI variation generation failed: $error');
    } finally {
      _variationDataLoading = false;
      update();
    }
  }

  Future<void> generateAttributeData({
    required String title,
    required String description,
  }) async {
    if (_variationDataLoading) return;
    _variationDataLoading = true;
    _attributeDataModel = null;
    update();

    try {
      final context = _requestContext();
      _attributeDataModel = await aiServiceInterface.generateAttributeData(
        title: title,
        description: description,
        storeId: context.storeId,
        moduleType: context.moduleType,
        generateFrom: _requestType,
      );
    } catch (error) {
      debugPrint('AI attribute generation failed: $error');
    } finally {
      _variationDataLoading = false;
      update();
    }
  }

  Future<void> generateTitleSuggestions() async {
    if (_isLoading) return;
    _isLoading = true;
    _titleSuggestionModel = null;
    update();

    try {
      final context = _requestContext();
      final keyWord = _keyWordList
          .whereType<String>()
          .map((element) => element.replaceAll(' ', ''))
          .where((element) => element.isNotEmpty)
          .join(',');

      _titleSuggestionModel = await aiServiceInterface.generateTitleSuggestions(
        keywords: keyWord,
        storeId: context.storeId,
        moduleType: context.moduleType,
      );
    } catch (error) {
      debugPrint('AI title suggestion generation failed: $error');
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<Response> generateFromImage({required XFile image}) async {
    if (_imageLoading) {
      return const Response(
        statusCode: 409,
        statusText: 'AI image analysis is already running',
      );
    }
    _imageLoading = true;
    update();

    try {
      final compressedImage = await compressImageFile(
        imageFile: File(image.path),
        quality: 10,
        format: CompressFormat.jpeg,
      );
      return await aiServiceInterface.generateFromImage(image: compressedImage);
    } catch (error) {
      debugPrint('AI image analysis failed: $error');
      return Response(statusCode: 1, statusText: error.toString());
    } finally {
      _imageLoading = false;
      update();
    }
  }

  Future<XFile> compressImageFile({
    required File imageFile,
    int quality = 80,
    CompressFormat format = CompressFormat.jpeg,
  }) async {
    final time = DateTime.now().microsecondsSinceEpoch;
    final targetPath = path.join(
      Directory.systemTemp.path,
      'imagetemp-${format.name}-$quality-$time.${format.name}',
    );

    final compressedImageFile = await FlutterImageCompress.compressAndGetFile(
      imageFile.path,
      targetPath,
      quality: quality,
      format: format,
      minHeight: 800,
      minWidth: 800,
    );

    if (compressedImageFile == null) {
      throw StateError('Image compression failed');
    }
    debugPrint('Compressed image saved to: ${compressedImageFile.path}');
    return compressedImageFile;
  }
}
