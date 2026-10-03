import 'package:get/get.dart';
import 'package:sixam_mart_store/features/html/domain/services/html_service_interface.dart';

class HtmlController extends GetxController implements GetxService {
  final HtmlServiceInterface htmlServiceInterface;
  HtmlController({required this.htmlServiceInterface});

  String? _htmlText;
  String? get htmlText => _htmlText;

  Future<void> getHtmlText(bool isPrivacyPolicy) async {
    _htmlText = null;
    Response response = await htmlServiceInterface.getHtmlText(isPrivacyPolicy);
    if (response.statusCode == 200) {
      dynamic content = response.body is Map ? response.body['content'] : response.body;
      if(content != null && content is String && content.isNotEmpty) {
        _htmlText = content.replaceAll('href=', 'target="_blank" href=');
      }else {
        _htmlText = '';
      }
    }
    update();
  }

}
