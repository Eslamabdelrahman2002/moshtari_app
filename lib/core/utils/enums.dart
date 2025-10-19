// lib/core/utils/enums.dart

enum RealStateUserTypes {
  buyer('user', 'مشتري'),
  seller('profile', 'بائع');

  const RealStateUserTypes(this.icon, this.name);
  final String icon;
  final String name;
}

enum RealStateApplicationType {
  residential('home-2'),
  commercial('shop'),
  building('buildings'), // تم إضافته ليعمل مع الكود
  villa('villa');      // تم إضافته للتوافق

  const RealStateApplicationType(this.icon);
  final String icon;
}

enum RealStatePaymentType {
  cash('money-2', 'كاش'),
  installments('card-pos', 'أقساط');

  const RealStatePaymentType(this.icon, this.name);
  final String icon;
  final String name;
}


// Other Enums from your project (you can keep them as they are)
enum CarStatus {
  newCar,
  used,
  damged,
}

enum BuyTypes {
  cash,
  installment,
}

enum WarrantyTypes {
  outWarranty,
  inWarranty,
}

enum GearType {
  manual,
  automatic,
}

enum FualType {
  hybrid,
  electric,
  disel,
  gasoline,
}

enum WeelDriveType {
  frontWeelDrive,
  backWeelDrive,
  fourWeelDrive,
}

enum DoorsType {
  twoDoors,
  fourDoors,
  other,
}

enum UserType { user, admin }
