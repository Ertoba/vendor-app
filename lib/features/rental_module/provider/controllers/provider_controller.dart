import 'package:get/get.dart';
import 'package:sixam_mart_store/features/rental_module/provider/domain/models/vehicle_list_model.dart';
import 'package:sixam_mart_store/features/rental_module/provider/domain/services/provider_service_interface.dart';

class ProviderController extends GetxController implements GetxService {
  final ProviderServiceInterface providerServiceInterface;
  ProviderController({required this.providerServiceInterface});

  List<Vehicles>? _vehicleList;
  List<Vehicles>? get vehicleList => _vehicleList;

  int? _vehiclePageSize;
  int? get vehiclePageSize => _vehiclePageSize;

  bool isLoading = false;

  Future<void> getVehicleList({required String offset, String? search, bool willUpdate = true}) async {
  }


}