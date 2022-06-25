
class PrinterModel {
  String? name;
  String? address;
  int? type;
  bool? connected;
  String id;

  PrinterModel({
    required this.name,
    required this.address,
    required this.type,
    required this.connected,
    required this.id
      });

    static PrinterModel fromJson(Map<String,dynamic> json) => PrinterModel(
  

  name: json['name'],
  address: json['address'],
  type: json['type'],
  connected: json['connected'],
  id: json['id']
  
);

 Map<String, dynamic> toJson()=>{
  
   'name':name,
   'address':address,
   'type':type,
   'connected':connected,
   'id':id
 };
}