class PostModel {
  String? product;

  String? qty;

  String? sellingPrice;

  PostModel({
    this.product,
    this.qty,
    this.sellingPrice,
  });

  PostModel.fromJson(Map<String, dynamic> json) {
    product = json['product'];
    qty = json['qty'];
    sellingPrice = json['selling_price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();

    data['product'] = this.product;
    data['qty'] = this.qty;
    data['selling_price'] = this.sellingPrice;
    return data;
  }
}
