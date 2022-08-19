class Order {
  String id;
  String area;
  String name;
  int quantity;
  String brand;

  Order(this.id, this.area, this.name, this.quantity, this.brand);

  Order.fromList(List<String> items) :
        this(items[0], items[1], items[2],int.parse(items[3]),items[4],);

  @override
  String toString() {
    return 'Product {id: $id, name: $name, quantity: $quantity ,brand: $brand, area: $area}';
  }
}
