import 'package:sixam_mart_store/features/service_module/service_campaign/domain/models/service_campaign_model.dart';

abstract class ServiceCampaignServiceInterface {
  Future<List<ServiceCampaignModel>?> getCampaignList();
  Future<ServiceCampaignModel?> getCampaignDetails(int? campaignID);
  Future<bool> joinCampaign(int? campaignID);
  Future<bool> leaveCampaign(int? campaignID);
  List<ServiceCampaignModel>? filterCampaign(String status, List<ServiceCampaignModel> allCampaignList);
}
