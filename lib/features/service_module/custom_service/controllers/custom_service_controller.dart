import 'package:get/get.dart';
import 'package:sixam_mart_store/features/service_module/custom_service/domain/services/custom_service_service_interface.dart';

class CustomServiceController extends GetxController implements GetxService {
  final CustomServiceServiceInterface customServiceServiceInterface;
  CustomServiceController({required this.customServiceServiceInterface});

}
