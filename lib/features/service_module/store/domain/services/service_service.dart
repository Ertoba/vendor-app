import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart_store/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/models/service_ai_model.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/models/service_model.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/repositories/service_repository_interface.dart';
import 'package:sixam_mart_store/features/service_module/store/domain/services/service_service_interface.dart';

class ServiceService implements ServiceServiceInterface {
  final ServiceRepositoryInterface serviceRepositoryInterface;
  ServiceService({required this.serviceRepositoryInterface});

  @override
  Future<Response> addService(ServiceModel service, XFile? image, XFile? metaImage, List<XFile> images, List<String> savedImages, Map<String, String> fields, bool isAdd) async {
    return await serviceRepositoryInterface.addService(service, image, metaImage, images, savedImages, fields, isAdd);
  }

  @override
  Future<ServiceTitleDesModel?> getAiTitle({required String name, required String langCode}) async {
    return await serviceRepositoryInterface.getAiTitle(name: name, langCode: langCode);
  }

  @override
  Future<ServiceTitleDesModel?> getAiDescription({required String name, required String langCode}) async {
    return await serviceRepositoryInterface.getAiDescription(name: name, langCode: langCode);
  }

  @override
  Future<ServiceSeoModel?> getAiSeo({required String name, String? description}) async {
    return await serviceRepositoryInterface.getAiSeo(name: name, description: description);
  }

  @override
  Future<ServiceGeneralSetupModel?> getAiGeneralSetup({required String name, String? description, int? moduleId}) async {
    return await serviceRepositoryInterface.getAiGeneralSetup(name: name, description: description, moduleId: moduleId);
  }

  @override
  Future<ServicePriceVariationModel?> getAiPriceVariation({required String name, String? description}) async {
    return await serviceRepositoryInterface.getAiPriceVariation(name: name, description: description);
  }

  @override
  Future<ServiceTagsModel?> getAiTags({required String name, String? description}) async {
    return await serviceRepositoryInterface.getAiTags(name: name, description: description);
  }

  @override
  Future<ServiceTitleSuggestionModel?> getAiTitleSuggestions({required String keywords}) async {
    return await serviceRepositoryInterface.getAiTitleSuggestions(keywords: keywords);
  }

  @override
  Future<Response> analyzeImage({required XFile image}) async {
    return await serviceRepositoryInterface.analyzeImage(image: image);
  }

  @override
  Future<XFile?> pickImageFromGallery() async {
    XFile? pickImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickImage != null) {
      pickImage.length().then((value) {
        if (value > 2000000) {
          showCustomSnackBar('please_upload_lower_size_file'.tr);
        }
      });
    }
    return pickImage;
  }
}
