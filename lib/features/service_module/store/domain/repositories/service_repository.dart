import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart_store/api/api_client.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/models/service_ai_model.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/models/service_model.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/repositories/service_repository_interface.dart';
import 'package:sixam_mart_store/util/app_constants.dart';

class ServiceRepository implements ServiceRepositoryInterface {
  final ApiClient apiClient;
  ServiceRepository({required this.apiClient});

  @override
  Future<Response> addService(ServiceModel service, XFile? image, XFile? metaImage, List<XFile> images, List<String> savedImages, Map<String, String> fields, bool isAdd) async {
    final List<MultipartBody> multipartBody = [];
    if (image != null) {
      multipartBody.add(MultipartBody('image', image));
    }
    if (metaImage != null) {
      multipartBody.add(MultipartBody('meta_image', metaImage));
    }
    for (int index = 0; index < images.length; index++) {
      multipartBody.add(MultipartBody('item_images[]', images[index]));
    }

    Response response = await apiClient.postMultipartData(
      isAdd ? AppConstants.addServiceUri : '${AppConstants.updateServiceUri}/${service.id}',
      fields,
      multipartBody,
    );
    return response;
  }

  @override
  Future<ServiceTitleDesModel?> getAiTitle({required String name, required String langCode}) async {
    Response response = await apiClient.getData('${AppConstants.serviceAiTitleUri}?name=${Uri.encodeComponent(name)}&langCode=$langCode');
    if (response.statusCode == 200) {
      return ServiceTitleDesModel.fromJson(response.body);
    }
    return null;
  }

  @override
  Future<ServiceTitleDesModel?> getAiDescription({required String name, required String langCode}) async {
    Response response = await apiClient.getData('${AppConstants.serviceAiDescriptionUri}?name=${Uri.encodeComponent(name)}&langCode=$langCode');
    if (response.statusCode == 200) {
      return ServiceTitleDesModel.fromJson(response.body);
    }
    return null;
  }

  @override
  Future<ServiceSeoModel?> getAiSeo({required String name, String? description}) async {
    Response response = await apiClient.getData('${AppConstants.serviceAiSeoUri}?name=${Uri.encodeComponent(name)}&description=${Uri.encodeComponent(description ?? '')}');
    if (response.statusCode == 200) {
      return ServiceSeoModel.fromJson(response.body);
    }
    return null;
  }

  @override
  Future<ServiceGeneralSetupModel?> getAiGeneralSetup({required String name, String? description, int? moduleId}) async {
    return null;
  }

  @override
  Future<ServicePriceVariationModel?> getAiPriceVariation({required String name, String? description}) async {
    Response response = await apiClient.getData('${AppConstants.serviceAiPriceVariationUri}?name=${Uri.encodeComponent(name)}&description=${Uri.encodeComponent(description ?? '')}');
    if (response.statusCode == 200) {
      return ServicePriceVariationModel.fromJson(response.body);
    }
    return null;
  }

  @override
  Future<ServiceTagsModel?> getAiTags({required String name, String? description}) async {
    Response response = await apiClient.getData('${AppConstants.serviceAiTagsUri}?name=${Uri.encodeComponent(name)}&description=${Uri.encodeComponent(description ?? '')}');
    if (response.statusCode == 200) {
      return ServiceTagsModel.fromJson(response.body);
    }
    return null;
  }

  @override
  Future<ServiceTitleSuggestionModel?> getAiTitleSuggestions({required String keywords}) async {
    Response response = await apiClient.postMultipartData(AppConstants.serviceAiTitleSuggestionsUri, {'keywords': keywords}, []);
    if (response.statusCode == 200) {
      return ServiceTitleSuggestionModel.fromJson(response.body);
    }
    return null;
  }

  @override
  Future<Response> analyzeImage({required XFile image}) async {
    return await apiClient.postMultipartData(AppConstants.serviceAiAnalyzeImageUri, {}, [MultipartBody('image', image)]);
  }

  @override
  Future add(value) => throw UnimplementedError();

  @override
  Future delete(int? id) => throw UnimplementedError();

  @override
  Future get(int? id) => throw UnimplementedError();

  @override
  Future update(Map<String, dynamic> body) => throw UnimplementedError();

  @override
  Future getList() => throw UnimplementedError();
}
