import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/models/service_ai_model.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/models/service_model.dart';

abstract class ServiceServiceInterface {
  Future<Response> addService(ServiceModel service, XFile? image, XFile? metaImage, List<XFile> images, List<String> savedImages, Map<String, String> fields, bool isAdd);

  Future<ServiceTitleDesModel?> getAiTitle({required String name, required String langCode});
  Future<ServiceTitleDesModel?> getAiDescription({required String name, required String langCode});
  Future<ServiceSeoModel?> getAiSeo({required String name, String? description});
  Future<ServiceGeneralSetupModel?> getAiGeneralSetup({required String name, String? description, int? moduleId});
  Future<ServicePriceVariationModel?> getAiPriceVariation({required String name, String? description});
  Future<ServiceTagsModel?> getAiTags({required String name, String? description});
  Future<ServiceTitleSuggestionModel?> getAiTitleSuggestions({required String keywords});
  Future<Response> analyzeImage({required XFile image});

  Future<XFile?> pickImageFromGallery();
}
