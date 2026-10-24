import 'package:get/get.dart';
import 'package:sixam_mart_store/features/service_module/service_campaign/domain/services/service_campaign_service_interface.dart';

class ServiceCampaignController extends GetxController implements GetxService {
  final ServiceCampaignServiceInterface serviceCampaignServiceInterface;
  ServiceCampaignController({required this.serviceCampaignServiceInterface});
}
