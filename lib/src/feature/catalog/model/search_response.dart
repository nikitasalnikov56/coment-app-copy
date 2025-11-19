import 'package:coment_app/src/feature/main/model/product_dto.dart';

class SearchResponse {
  final List<ProductDTO> items;
  final int total;
  final int page;
  final int limit;

  SearchResponse({required this.items, required this.total, required this.page, required this.limit});
}