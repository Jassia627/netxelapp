class Client {
  final int? id;
  final String? name;

  Client({this.id, this.name});

  factory Client.fromMap(Map<String, dynamic> data) {
    return Client(
      id: data['id'],
      name: data['name'],
    );
  }
}
