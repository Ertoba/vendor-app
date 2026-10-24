import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixam_mart_store/common/models/response_model.dart';
import 'package:sixam_mart_store/common/widgets/custom_snackbar_widget.dart';
import 'package:sixam_mart_store/features/service_module/serviceman/domain/models/service_man_completed_booking_model.dart';
import 'package:sixam_mart_store/features/service_module/serviceman/domain/models/service_man_list_model.dart';
import 'package:sixam_mart_store/features/service_module/serviceman/domain/models/service_man_model.dart';
import 'package:sixam_mart_store/features/service_module/serviceman/domain/repositories/serviceman_repository_interface.dart';
import 'package:sixam_mart_store/features/service_module/serviceman/domain/services/serviceman_service_interface.dart';

class ServicemanService implements ServicemanServiceInterface {
  final ServicemanRepositoryInterface servicemanRepositoryInterface;
  ServicemanService({required this.servicemanRepositoryInterface});

  @override
  Future<ServiceManListModel?> getServiceManList({required String offset}) async {
    return await servicemanRepositoryInterface.getServiceManList(offset: offset);
  }

  @override
  Future<ServiceManModel?> getServiceManDetails(int id) async {
    return await servicemanRepositoryInterface.getServiceManDetails(id);
  }

  @override
  Future<ServiceManCompletedBookingListModel?> getServiceManCompletedBookings(int id, {required String offset}) async {
    return await servicemanRepositoryInterface.getServiceManCompletedBookings(id, offset: offset);
  }

  @override
  Future<ResponseModel> addServiceMan(ServiceManModel serviceMan, String pass, XFile? image, List<XFile> identities, bool isAdd) async {
    return await servicemanRepositoryInterface.addServiceMan(serviceMan, pass, image, identities, isAdd);
  }

  @override
  Future<ResponseModel> deleteServiceMan(int id) async {
    return await servicemanRepositoryInterface.deleteServiceMan(id);
  }

  @override
  Future<ResponseModel> updateServiceManStatus(int id, int status) async {
    return await servicemanRepositoryInterface.updateServiceManStatus(id, status);
  }

  @override
  int identityTypeIndex(List<String> identityTypeList, String? identityType) {
    int index0 = 0;
    for (int index = 0; index < identityTypeList.length; index++) {
      if (identityTypeList[index] == identityType) {
        index0 = index;
        break;
      }
    }
    return index0;
  }

  @override
  Future<XFile?> pickImageFromGallery() async {
    XFile? pickImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickImage != null) {
      pickImage.length().then((value) {
        if (value > 2000000) {
          showCustomSnackBar('please_upload_lower_size_file'.tr);
        } else {
          return pickImage;
        }
      });
    }
    return pickImage;
  }
}
