import 'package:get/get.dart';
import 'package:sixam_mart_store/api/api_client.dart';
import 'package:sixam_mart_store/features/service_module/service_campaign/domain/models/service_campaign_model.dart';
import 'package:sixam_mart_store/features/service_module/service_campaign/domain/repositories/service_campaign_repository_interface.dart';
import 'package:sixam_mart_store/util/app_constants.dart';

class ServiceCampaignRepository implements ServiceCampaignRepositoryInterface {
  final ApiClient apiClient;
  ServiceCampaignRepository({required this.apiClient});

  @override
  Future<List<ServiceCampaignModel>?> getList() async {
    List<ServiceCampaignModel>? campaignList;
    Response response = await apiClient.getData(AppConstants.serviceCampaignListUri);
    if (response.statusCode == 200) {
      campaignList = [];
      response.body.forEach((campaign) {
        campaignList!.add(ServiceCampaignModel.fromJson(campaign));
      });
    }
    return campaignList;
  }

  @override
  Future<ServiceCampaignModel?> get(int? id) async {
    ServiceCampaignModel? campaign;
    Response response = await apiClient.getData('${AppConstants.serviceCampaignDetailsUri}/$id');
    if (response.statusCode == 200) {
      campaign = ServiceCampaignModel.fromJson(response.body);
    }
    return campaign;
  }

  @override
  Future<bool> joinCampaign(int? campaignID) async {
    Response response = await apiClient.postData(AppConstants.serviceCampaignJoinUri, {'campaign_id': campaignID});
    return (response.statusCode == 200);
  }

  @override
  Future<bool> leaveCampaign(int? campaignID) async {
    Response response = await apiClient.postData(AppConstants.serviceCampaignLeaveUri, {'campaign_id': campaignID});
    return (response.statusCode == 200);
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body) {
    throw UnimplementedError();
  }

}
