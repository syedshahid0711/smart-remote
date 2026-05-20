class DeviceType {
  final String id;
  final String name;
  final String icon;

  const DeviceType({required this.id, required this.name, required this.icon});
}

class Brand {
  final String id;
  final String name;

  const Brand({required this.id, required this.name});
}

class IrDatabase {
  static const List<DeviceType> types = [
    DeviceType(id: 'ac', name: 'Air Conditioner', icon: '❄️'),
    DeviceType(id: 'tv', name: 'Television', icon: '📺'),
    DeviceType(id: 'fan', name: 'Fan', icon: '🌀'),
    DeviceType(id: 'stb', name: 'Set-top Box', icon: '📡'),
    DeviceType(id: 'lights', name: 'Smart Lights', icon: '💡'),
    DeviceType(id: 'projector', name: 'Projector', icon: '📽️'),
    DeviceType(id: 'speaker', name: 'Soundbar/Speaker', icon: '🔊'),
  ];

  static const Map<String, List<Brand>> brands = {
    'ac': [
      Brand(id: 'lg', name: 'LG'),
      Brand(id: 'samsung', name: 'Samsung'),
      Brand(id: 'daikin', name: 'Daikin'),
      Brand(id: 'voltas', name: 'Voltas'),
      Brand(id: 'bluestar', name: 'Blue Star'),
      Brand(id: 'carrier', name: 'Carrier'),
      Brand(id: 'hitachi', name: 'Hitachi'),
      Brand(id: 'panasonic', name: 'Panasonic'),
      Brand(id: 'haier', name: 'Haier'),
      Brand(id: 'godrej', name: 'Godrej'),
      Brand(id: 'lloyd', name: 'Lloyd'),
      Brand(id: 'whirlpool', name: 'Whirlpool'),
      Brand(id: 'ogeneral', name: 'O General'),
      Brand(id: 'mitsubishi', name: 'Mitsubishi'),
    ],
    'tv': [
      Brand(id: 'lg', name: 'LG'),
      Brand(id: 'samsung', name: 'Samsung'),
      Brand(id: 'sony', name: 'Sony'),
      Brand(id: 'mi', name: 'Mi / Xiaomi'),
      Brand(id: 'tcl', name: 'TCL'),
      Brand(id: 'panasonic', name: 'Panasonic'),
      Brand(id: 'philips', name: 'Philips'),
      Brand(id: 'vu', name: 'VU'),
      Brand(id: 'oneplus', name: 'OnePlus'),
      Brand(id: 'hisense', name: 'Hisense'),
      Brand(id: 'toshiba', name: 'Toshiba'),
      Brand(id: 'realme', name: 'Realme'),
    ],
    'fan': [
      Brand(id: 'generic', name: 'Generic IR Fan'),
      Brand(id: 'usha', name: 'Usha'),
      Brand(id: 'havells', name: 'Havells'),
      Brand(id: 'orient', name: 'Orient'),
      Brand(id: 'atomberg', name: 'Atomberg'),
      Brand(id: 'crompton', name: 'Crompton'),
    ],
    'stb': [
      Brand(id: 'tataplay', name: 'Tata Play'),
      Brand(id: 'airtel', name: 'Airtel Digital TV'),
      Brand(id: 'dish', name: 'Dish TV'),
      Brand(id: 'd2h', name: 'D2H'),
      Brand(id: 'sun', name: 'Sun Direct'),
      Brand(id: 'jio', name: 'Jio STB'),
    ],
    'lights': [
      Brand(id: 'generic', name: 'Smart Wi-Fi Lights'),
    ],
    'projector': [
      Brand(id: 'epson', name: 'Epson'),
      Brand(id: 'benq', name: 'BenQ'),
      Brand(id: 'generic', name: 'Generic'),
    ],
    'speaker': [
      Brand(id: 'generic', name: 'Generic Soundbar'),
    ],
  };

  // TV Codes mapping (NEC protocol values)
  static const Map<String, Map<String, int>> tvCodes = {
    'lg': {
      'power': 0x20DF10EF, 'volUp': 0x20DF40BF, 'volDn': 0x20DFC03F, 'chUp': 0x20DF00FF, 'chDn': 0x20DF807F,
      'mute': 0x20DF906F, 'input': 0x20DFD02F, 'ok': 0x20DF22DD, 'up': 0x20DF02FD, 'down': 0x20DF827D,
      'left': 0x20DFE01F, 'right': 0x20DF609F, 'back': 0x20DF14EB, 'home': 0x20DF3EC1, 'menu': 0x20DFC23D,
      'n0': 0x20DF08F7, 'n1': 0x20DF8877, 'n2': 0x20DF48B7, 'n3': 0x20DFC837, 'n4': 0x20DF28D7,
      'n5': 0x20DFA857, 'n6': 0x20DF6897, 'n7': 0x20DFE817, 'n8': 0x20DF18E7, 'n9': 0x20DF9867
    },
    'samsung': {
      'power': 0xE0E040BF, 'volUp': 0xE0E0E01F, 'volDn': 0xE0E0D02F, 'chUp': 0xE0E048B7, 'chDn': 0xE0E008F7,
      'mute': 0xE0E0F00F, 'input': 0xE0E0807F, 'ok': 0xE0E016E9, 'up': 0xE0E006F9, 'down': 0xE0E08679,
      'left': 0xE0E0A659, 'right': 0xE0E046B9, 'back': 0xE0E01AE5, 'home': 0xE0E09E61, 'menu': 0xE0E058A7,
      'n0': 0xE0E08877, 'n1': 0xE0E020DF, 'n2': 0xE0E0A05F, 'n3': 0xE0E0609F, 'n4': 0xE0E010EF,
      'n5': 0xE0E0906F, 'n6': 0xE0E050AF, 'n7': 0xE0E030CF, 'n8': 0xE0E0B04F, 'n9': 0xE0E0708F
    },
    'sony': {
      'power': 0xA90, 'volUp': 0x490, 'volDn': 0xC90, 'chUp': 0x090, 'chDn': 0x890,
      'mute': 0x290, 'input': 0xA50, 'ok': 0xA70, 'up': 0x2F0, 'down': 0xAF0,
      'left': 0x2D0, 'right': 0xCD0, 'back': 0x62E9, 'home': 0x070, 'menu': 0x070,
      'n0': 0x910, 'n1': 0x010, 'n2': 0x810, 'n3': 0x410, 'n4': 0xC10,
      'n5': 0x210, 'n6': 0xA10, 'n7': 0x610, 'n8': 0xE10, 'n9': 0x110
    },
    'mi': {
      'power': 0x807F02FD, 'volUp': 0x807F827D, 'volDn': 0x807FA25D, 'chUp': 0x807F48B7, 'chDn': 0x807FC837,
      'mute': 0x807F52AD, 'input': 0x807F42BD, 'ok': 0x807F1AE5, 'up': 0x807F9A65, 'down': 0x807F5AA5,
      'left': 0x807FDA25, 'right': 0x807F3AC5, 'back': 0x807F22DD, 'home': 0x807FE21D, 'menu': 0x807F6A95,
      'n0': 0x807F08F7, 'n1': 0x807F8877, 'n2': 0x807F48B7, 'n3': 0x807FC837, 'n4': 0x807F28D7,
      'n5': 0x807FA857, 'n6': 0x807F6897, 'n7': 0x807FE817, 'n8': 0x807F18E7, 'n9': 0x807F9867
    },
    'tcl': {
      'power': 0x807F02FD, 'volUp': 0x807F827D, 'volDn': 0x807FA25D, 'chUp': 0x807F48B7, 'chDn': 0x807FC837,
      'mute': 0x807F52AD, 'input': 0x807F42BD, 'ok': 0x807F1AE5, 'up': 0x807F9A65, 'down': 0x807F5AA5,
      'left': 0x807FDA25, 'right': 0x807F3AC5, 'back': 0x807F22DD, 'home': 0x807FE21D, 'menu': 0x807F6A95,
      'n0': 0x807F08F7, 'n1': 0x807F8877, 'n2': 0x807F48B7, 'n3': 0x807FC837, 'n4': 0x807F28D7,
      'n5': 0x807FA857, 'n6': 0x807F6897, 'n7': 0x807FE817, 'n8': 0x807F18E7, 'n9': 0x807F9867
    }
  };

  // STB Codes mapping (NEC)
  static const Map<String, Map<String, int>> stbCodes = {
    'tataplay': {
      'power': 0x807F02FD, 'ok': 0x807F1AE5, 'up': 0x807F9A65, 'down': 0x807F5AA5,
      'left': 0x807FDA25, 'right': 0x807F3AC5, 'back': 0x807F22DD, 'home': 0x807FE21D,
      'menu': 0x807F6A95, 'volUp': 0x807F827D, 'volDn': 0x807FA25D, 'chUp': 0x807F48B7,
      'chDn': 0x807FC837, 'n0': 0x807F08F7, 'n1': 0x807F8877, 'n2': 0x807F48B7,
      'n3': 0x807FC837, 'n4': 0x807F28D7, 'n5': 0x807FA857, 'n6': 0x807F6897,
      'n7': 0x807FE817, 'n8': 0x807F18E7, 'n9': 0x807F9867
    },
    'airtel': {
      'power': 0x40BF00FF, 'ok': 0x40BF38C7, 'up': 0x40BFB847, 'down': 0x40BF7887,
      'left': 0x40BFF807, 'right': 0x40BF18E7, 'back': 0x40BFA857, 'home': 0x40BF6897,
      'menu': 0x40BFE817, 'volUp': 0x40BF40BF, 'volDn': 0x40BFC03F, 'chUp': 0x40BF08F7,
      'chDn': 0x40BF8877, 'n0': 0x40BF30CF, 'n1': 0x40BF20DF, 'n2': 0x40BFA05F,
      'n3': 0x40BF609F, 'n4': 0x40BF10EF, 'n5': 0x40BF906F, 'n6': 0x40BF50AF,
      'n7': 0x40BF30CF, 'n8': 0x40BFB04F, 'n9': 0x40BF708F
    }
  };

  // Fan Codes mapping
  static const Map<String, Map<String, int>> fanCodes = {
    'generic': {
      'power': 0x01FE48B7, 'speedUp': 0x01FE58A7, 'speedDn': 0x01FE7887, 'swing': 0x01FED827
    },
    'usha': {
      'power': 0x807F02FD, 'speedUp': 0x807F827D, 'speedDn': 0x807FA25D, 'swing': 0x807F22DD
    },
    'havells': {
      'power': 0x807F02FD, 'speedUp': 0x807F827D, 'speedDn': 0x807FA25D, 'swing': 0x807F22DD
    }
  };

  // AC Configuration Details
  static const Map<String, Map<String, dynamic>> acConfig = {
    'lg': {
      'protocol': 'lg28', 'sig': 0x88, 'hdr': 8500, 'hdrS': 4250, 'bit': 550, 'oneS': 1600, 'zeroS': 550,
      'offCmd': 0x88C0051, 'swingCmd': 0x8810001, 'dispCmd': 0x88C00A6
    },
    'samsung': {
      'protocol': 'samsung28', 'sig': 0xB2, 'hdr': 3100, 'hdrS': 8850, 'bit': 550, 'oneS': 1500, 'zeroS': 550,
      'offCmd': 0xB2BF00FF
    },
    'daikin': {
      'protocol': 'nec', 'sig': 0x11, 'hdr': 3500, 'hdrS': 1700, 'bit': 450, 'oneS': 1300, 'zeroS': 420,
      'offCmd': 0x11DA27C0
    },
    'voltas': {
      'protocol': 'nec', 'sig': 0x33, 'hdr': 9000, 'hdrS': 4500, 'bit': 560, 'oneS': 1690, 'zeroS': 560,
      'offCmd': 0x33B240BF
    }
  };

  // Helper method: generate NEC raw time patterns
  static List<int> necToPattern(int code) {
    String bits = code.toRadixString(2).padLeft(32, '0');
    List<int> pattern = [9000, 4500];
    for (int i = 0; i < bits.length; i++) {
      pattern.add(560);
      pattern.add(bits[i] == '1' ? 1690 : 560);
    }
    pattern.add(560);
    pattern.add(10000); // Stop/gap
    return pattern;
  }
  
  static List<int> lgAcToPattern(int code) {
    String bits = code.toRadixString(2).padLeft(28, '0');
    List<int> pattern = [8500, 4250];
    for (int i = 0; i < bits.length; i++) {
      pattern.add(550);
      pattern.add(bits[i] == '1' ? 1600 : 550);
    }
    pattern.add(550);
    pattern.add(10000);
    return pattern;
  }
}
