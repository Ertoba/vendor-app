import 'package:sixam_mart_store/features/service_module/service_campaign/domain/models/service_campaign_model.dart';
import 'package:sixam_mart_store/features/service_module/service_campaign/domain/repositories/service_campaign_repository_interface.dart';
import 'package:sixam_mart_store/features/service_module/service_campaign/domain/services/service_campaign_service_interface.dart';

class ServiceCampaignService implements ServiceCampaignServiceInterface {
  final ServiceCampaignRepositoryInterface serviceCampaignRepositoryInterface;
  ServiceCampaignService({required this.serviceCampaignRepositoryInterface});

  @override
  Future<List<ServiceCampaignModel>?> getCampaignList() async {
    return await serviceCampaignRepositoryInterface.getList();
  }

  @override
  Future<ServiceCampaignModel?> getCampaignDetails(int? campaignID) async {
    return await serviceCampaignRepositoryInterface.get(campaignID);
  }

  @override
  Future<bool> joinCampaign(int? campaignID) async {
    return await serviceCampaignRepositoryInterface.joinCampaign(campaignID);
  }

  @override
  Future<bool> leaveCampaign(int? campaignID) async {
    return await serviceCampaignRepositoryInterface.leaveCampaign(campaignID);
  }

  @override
  List<ServiceCampaignModel>? filterCampaign(String status, List<ServiceCampaignModel> allCampaignList) {
    List<ServiceCampaignModel>? campaignList = [];
    if(status == 'joined') {
      for (var campaign in allCampaignList) {
        if(campaign.isJoined ?? false) {
          campaignList.add(campaign);
        }
      }
    }else {
      campaignList.addAll(allCampaignList);
    }
    return campaignList;
  }

}
