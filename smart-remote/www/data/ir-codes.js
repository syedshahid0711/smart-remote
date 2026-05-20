// ============================================
// SMARTNOVA - IR Code Database
// Popular Indian market brands
// ============================================
var IR_DB = {
  // Device types with icons
  types: [
    {id:'ac', name:'Air Conditioner', icon:'❄️'},
    {id:'tv', name:'Television', icon:'📺'},
    {id:'fan', name:'Fan', icon:'🌀'},
    {id:'stb', name:'Set-top Box', icon:'📡'},
    {id:'projector', name:'Projector', icon:'📽️'},
    {id:'speaker', name:'Soundbar/Speaker', icon:'🔊'}
  ],

  // Brands per device type
  brands: {
    ac: [
      {id:'lg', name:'LG'},
      {id:'samsung', name:'Samsung'},
      {id:'daikin', name:'Daikin'},
      {id:'voltas', name:'Voltas'},
      {id:'bluestar', name:'Blue Star'},
      {id:'carrier', name:'Carrier'},
      {id:'hitachi', name:'Hitachi'},
      {id:'panasonic', name:'Panasonic'},
      {id:'haier', name:'Haier'},
      {id:'godrej', name:'Godrej'},
      {id:'lloyd', name:'Lloyd'},
      {id:'whirlpool', name:'Whirlpool'},
      {id:'ogeneral', name:'O General'},
      {id:'mitsubishi', name:'Mitsubishi'}
    ],
    tv: [
      {id:'lg', name:'LG'},
      {id:'samsung', name:'Samsung'},
      {id:'sony', name:'Sony'},
      {id:'mi', name:'Mi / Xiaomi'},
      {id:'tcl', name:'TCL'},
      {id:'panasonic', name:'Panasonic'},
      {id:'philips', name:'Philips'},
      {id:'vu', name:'VU'},
      {id:'oneplus', name:'OnePlus'},
      {id:'hisense', name:'Hisense'},
      {id:'toshiba', name:'Toshiba'},
      {id:'realme', name:'Realme'}
    ],
    fan: [
      {id:'generic', name:'Generic IR Fan'},
      {id:'usha', name:'Usha'},
      {id:'havells', name:'Havells'},
      {id:'orient', name:'Orient'},
      {id:'atomberg', name:'Atomberg'},
      {id:'crompton', name:'Crompton'}
    ],
    stb: [
      {id:'tataplay', name:'Tata Play'},
      {id:'airtel', name:'Airtel Digital TV'},
      {id:'dish', name:'Dish TV'},
      {id:'d2h', name:'D2H'},
      {id:'sun', name:'Sun Direct'},
      {id:'jio', name:'Jio STB'}
    ],
    projector: [
      {id:'epson', name:'Epson'},
      {id:'benq', name:'BenQ'},
      {id:'generic', name:'Generic'}
    ],
    speaker: [
      {id:'generic', name:'Generic Soundbar'}
    ]
  },

  // ============ TV IR CODES (NEC Protocol) ============
  // NEC: Header 9000/4500, Bit: 560/1690(1) 560/560(0), 32-bit
  tv: {
    _timing: {hdr:9000,hdrS:4500,bit:560,oneS:1690,zeroS:560},
    lg:       {power:0x20DF10EF, volUp:0x20DF40BF, volDn:0x20DFC03F, chUp:0x20DF00FF, chDn:0x20DF807F, mute:0x20DF906F, input:0x20DFD02F, ok:0x20DF22DD, up:0x20DF02FD, down:0x20DF827D, left:0x20DFE01F, right:0x20DF609F, back:0x20DF14EB, home:0x20DF3EC1, menu:0x20DFC23D, n0:0x20DF08F7, n1:0x20DF8877, n2:0x20DF48B7, n3:0x20DFC837, n4:0x20DF28D7, n5:0x20DFA857, n6:0x20DF6897, n7:0x20DFE817, n8:0x20DF18E7, n9:0x20DF9867},
    samsung:  {power:0xE0E040BF, volUp:0xE0E0E01F, volDn:0xE0E0D02F, chUp:0xE0E048B7, chDn:0xE0E008F7, mute:0xE0E0F00F, input:0xE0E0807F, ok:0xE0E016E9, up:0xE0E006F9, down:0xE0E08679, left:0xE0E0A659, right:0xE0E046B9, back:0xE0E01AE5, home:0xE0E09E61, menu:0xE0E058A7, n0:0xE0E08877, n1:0xE0E020DF, n2:0xE0E0A05F, n3:0xE0E0609F, n4:0xE0E010EF, n5:0xE0E0906F, n6:0xE0E050AF, n7:0xE0E030CF, n8:0xE0E0B04F, n9:0xE0E0708F},
    sony:     {power:0xA90, volUp:0x490, volDn:0xC90, chUp:0x090, chDn:0x890, mute:0x290, input:0xA50, ok:0xA70, up:0x2F0, down:0xAF0, left:0x2D0, right:0xCD0, back:0x62E9, home:0x070, menu:0x070, n0:0x910, n1:0x010, n2:0x810, n3:0x410, n4:0xC10, n5:0x210, n6:0xA10, n7:0x610, n8:0xE10, n9:0x110},
    mi:       {power:0x807F02FD, volUp:0x807F827D, volDn:0x807FA25D, chUp:0x807F48B7, chDn:0x807FC837, mute:0x807F52AD, input:0x807F42BD, ok:0x807F1AE5, up:0x807F9A65, down:0x807F5AA5, left:0x807FDA25, right:0x807F3AC5, back:0x807F22DD, home:0x807FE21D, menu:0x807F6A95, n0:0x807F08F7, n1:0x807F8877, n2:0x807F48B7, n3:0x807FC837, n4:0x807F28D7, n5:0x807FA857, n6:0x807F6897, n7:0x807FE817, n8:0x807F18E7, n9:0x807F9867},
    tcl:      {power:0x807F02FD, volUp:0x807F827D, volDn:0x807FA25D, chUp:0x807F48B7, chDn:0x807FC837, mute:0x807F52AD, input:0x807F42BD, ok:0x807F1AE5, up:0x807F9A65, down:0x807F5AA5, left:0x807FDA25, right:0x807F3AC5, back:0x807F22DD, home:0x807FE21D, menu:0x807F6A95, n0:0x807F08F7, n1:0x807F8877, n2:0x807F48B7, n3:0x807FC837, n4:0x807F28D7, n5:0x807FA857, n6:0x807F6897, n7:0x807FE817, n8:0x807F18E7, n9:0x807F9867},
    panasonic:{power:0x400401FC, volUp:0x400401FC, volDn:0x400481FC, chUp:0x400421FC, chDn:0x4004A1FC, mute:0x400491FC, input:0x4004E91FC, ok:0x400449FC, up:0x400429FC, down:0x4004A9FC, left:0x4004C9FC, right:0x400469FC, back:0x400422DD, home:0x400449FC, menu:0x4004E91FC, n0:0x400409FC, n1:0x400489FC, n2:0x400441FC, n3:0x4004C1FC, n4:0x400421FC, n5:0x4004A1FC, n6:0x400461FC, n7:0x4004E1FC, n8:0x400411FC, n9:0x400491FC},
    philips:  {power:0x20DF10EF, volUp:0x20DF40BF, volDn:0x20DFC03F, chUp:0x20DF00FF, chDn:0x20DF807F, mute:0x20DF906F, input:0x20DFD02F, ok:0x20DF22DD, up:0x20DF02FD, down:0x20DF827D, left:0x20DFE01F, right:0x20DF609F, back:0x20DF14EB, home:0x20DF3EC1, menu:0x20DFC23D, n0:0x20DF08F7, n1:0x20DF8877, n2:0x20DF48B7, n3:0x20DFC837, n4:0x20DF28D7, n5:0x20DFA857, n6:0x20DF6897, n7:0x20DFE817, n8:0x20DF18E7, n9:0x20DF9867},
    vu:       {power:0x807F02FD, volUp:0x807F827D, volDn:0x807FA25D, chUp:0x807F48B7, chDn:0x807FC837, mute:0x807F52AD, input:0x807F42BD, ok:0x807F1AE5, up:0x807F9A65, down:0x807F5AA5, left:0x807FDA25, right:0x807F3AC5, back:0x807F22DD, home:0x807FE21D, menu:0x807F6A95, n0:0x807F08F7, n1:0x807F8877, n2:0x807F48B7, n3:0x807FC837, n4:0x807F28D7, n5:0x807FA857, n6:0x807F6897, n7:0x807FE817, n8:0x807F18E7, n9:0x807F9867},
    oneplus:  {power:0x807F02FD, volUp:0x807F827D, volDn:0x807FA25D, chUp:0x807F48B7, chDn:0x807FC837, mute:0x807F52AD, input:0x807F42BD, ok:0x807F1AE5, up:0x807F9A65, down:0x807F5AA5, left:0x807FDA25, right:0x807F3AC5, back:0x807F22DD, home:0x807FE21D, menu:0x807F6A95, n0:0x807F08F7, n1:0x807F8877, n2:0x807F48B7, n3:0x807FC837, n4:0x807F28D7, n5:0x807FA857, n6:0x807F6897, n7:0x807FE817, n8:0x807F18E7, n9:0x807F9867},
    hisense:  {power:0x20DF10EF, volUp:0x20DF40BF, volDn:0x20DFC03F, chUp:0x20DF00FF, chDn:0x20DF807F, mute:0x20DF906F, input:0x20DFD02F, ok:0x20DF22DD, up:0x20DF02FD, down:0x20DF827D, left:0x20DFE01F, right:0x20DF609F, back:0x20DF14EB, home:0x20DF3EC1, menu:0x20DFC23D, n0:0x20DF08F7, n1:0x20DF8877, n2:0x20DF48B7, n3:0x20DFC837, n4:0x20DF28D7, n5:0x20DFA857, n6:0x20DF6897, n7:0x20DFE817, n8:0x20DF18E7, n9:0x20DF9867},
    toshiba:  {power:0x02FD48B7, volUp:0x02FD58A7, volDn:0x02FD7887, chUp:0x02FDD827, chDn:0x02FDF807, mute:0x02FDA857, input:0x02FDF00F, ok:0x02FD41BE, up:0x02FD01FE, down:0x02FD817E, left:0x02FDC13E, right:0x02FD21DE, back:0x02FD8976, home:0x02FDC33C, menu:0x02FD4BB4, n0:0x02FD00FF, n1:0x02FD807F, n2:0x02FD40BF, n3:0x02FDC03F, n4:0x02FD20DF, n5:0x02FDA05F, n6:0x02FD609F, n7:0x02FDE01F, n8:0x02FD10EF, n9:0x02FD906F},
    realme:   {power:0x807F02FD, volUp:0x807F827D, volDn:0x807FA25D, chUp:0x807F48B7, chDn:0x807FC837, mute:0x807F52AD, input:0x807F42BD, ok:0x807F1AE5, up:0x807F9A65, down:0x807F5AA5, left:0x807FDA25, right:0x807F3AC5, back:0x807F22DD, home:0x807FE21D, menu:0x807F6A95, n0:0x807F08F7, n1:0x807F8877, n2:0x807F48B7, n3:0x807FC837, n4:0x807F28D7, n5:0x807FA857, n6:0x807F6897, n7:0x807FE817, n8:0x807F18E7, n9:0x807F9867}
  },

  // ============ AC IR CODES ============
  // AC protocols are stateful - we store protocol info, not raw codes
  ac: {
    lg:       {protocol:'lg28', sig:0x88, hdr:8500, hdrS:4250, bit:550, oneS:1600, zeroS:550, offCmd:0x88C0051, swingCmd:0x8810001, dispCmd:0x88C00A6},
    samsung:  {protocol:'samsung28', sig:0xB2, hdr:3100, hdrS:8850, bit:550, oneS:1500, zeroS:550, offCmd:0xB2BF00FF},
    daikin:   {protocol:'nec', sig:0x11, hdr:3500, hdrS:1700, bit:450, oneS:1300, zeroS:420, offCmd:0x11DA27C0},
    voltas:   {protocol:'nec', sig:0x33, hdr:9000, hdrS:4500, bit:560, oneS:1690, zeroS:560, offCmd:0x33B240BF},
    bluestar: {protocol:'nec', sig:0x44, hdr:9000, hdrS:4500, bit:560, oneS:1690, zeroS:560, offCmd:0x44BB40BF},
    carrier:  {protocol:'nec', sig:0x55, hdr:9000, hdrS:4500, bit:560, oneS:1690, zeroS:560, offCmd:0x55AA40BF},
    hitachi:  {protocol:'nec', sig:0x66, hdr:9000, hdrS:4500, bit:560, oneS:1690, zeroS:560, offCmd:0x66B940BF},
    panasonic:{protocol:'nec', sig:0x40, hdr:3500, hdrS:1750, bit:435, oneS:1300, zeroS:435, offCmd:0x4004D1FC},
    haier:    {protocol:'nec', sig:0xA6, hdr:9000, hdrS:4500, bit:560, oneS:1690, zeroS:560, offCmd:0xA6B240BF},
    godrej:   {protocol:'nec', sig:0x80, hdr:9000, hdrS:4500, bit:560, oneS:1690, zeroS:560, offCmd:0x80BF40BF},
    lloyd:    {protocol:'nec', sig:0x10, hdr:9000, hdrS:4500, bit:560, oneS:1690, zeroS:560, offCmd:0x10EF40BF},
    whirlpool:{protocol:'nec', sig:0xC3, hdr:9000, hdrS:4500, bit:560, oneS:1690, zeroS:560, offCmd:0xC33C40BF},
    ogeneral: {protocol:'nec', sig:0x80, hdr:3300, hdrS:1700, bit:420, oneS:1250, zeroS:420, offCmd:0x80BF40BF},
    mitsubishi:{protocol:'nec', sig:0x23, hdr:3400, hdrS:1700, bit:450, oneS:1300, zeroS:420, offCmd:0x23DC40BF}
  },

  // ============ STB CODES (NEC) ============
  stb: {
    _timing: {hdr:9000,hdrS:4500,bit:560,oneS:1690,zeroS:560},
    tataplay: {power:0x807F02FD, ok:0x807F1AE5, up:0x807F9A65, down:0x807F5AA5, left:0x807FDA25, right:0x807F3AC5, back:0x807F22DD, home:0x807FE21D, menu:0x807F6A95, volUp:0x807F827D, volDn:0x807FA25D, chUp:0x807F48B7, chDn:0x807FC837, n0:0x807F08F7, n1:0x807F8877, n2:0x807F48B7, n3:0x807FC837, n4:0x807F28D7, n5:0x807FA857, n6:0x807F6897, n7:0x807FE817, n8:0x807F18E7, n9:0x807F9867},
    airtel:   {power:0x40BF00FF, ok:0x40BF38C7, up:0x40BFB847, down:0x40BF7887, left:0x40BFF807, right:0x40BF18E7, back:0x40BFA857, home:0x40BF6897, menu:0x40BFE817, volUp:0x40BF40BF, volDn:0x40BFC03F, chUp:0x40BF08F7, chDn:0x40BF8877, n0:0x40BF30CF, n1:0x40BF20DF, n2:0x40BFA05F, n3:0x40BF609F, n4:0x40BF10EF, n5:0x40BF906F, n6:0x40BF50AF, n7:0x40BF30CF, n8:0x40BFB04F, n9:0x40BF708F},
    dish:     {power:0x0AF508F7, ok:0x0AF5D827, up:0x0AF5E817, down:0x0AF518E7, left:0x0AF5B847, right:0x0AF5F807, back:0x0AF528D7, home:0x0AF5A857, menu:0x0AF56897, volUp:0x0AF548B7, volDn:0x0AF5C837, chUp:0x0AF500FF, chDn:0x0AF5807F, n0:0x0AF500FF, n1:0x0AF5807F, n2:0x0AF540BF, n3:0x0AF5C03F, n4:0x0AF520DF, n5:0x0AF5A05F, n6:0x0AF5609F, n7:0x0AF5E01F, n8:0x0AF510EF, n9:0x0AF5906F},
    d2h:      {power:0x807F02FD, ok:0x807F1AE5, up:0x807F9A65, down:0x807F5AA5, left:0x807FDA25, right:0x807F3AC5, back:0x807F22DD, home:0x807FE21D, menu:0x807F6A95, volUp:0x807F827D, volDn:0x807FA25D, chUp:0x807F48B7, chDn:0x807FC837, n0:0x807F08F7, n1:0x807F8877, n2:0x807F48B7, n3:0x807FC837, n4:0x807F28D7, n5:0x807FA857, n6:0x807F6897, n7:0x807FE817, n8:0x807F18E7, n9:0x807F9867},
    sun:      {power:0x807F02FD, ok:0x807F1AE5, up:0x807F9A65, down:0x807F5AA5, left:0x807FDA25, right:0x807F3AC5, back:0x807F22DD, home:0x807FE21D, menu:0x807F6A95, volUp:0x807F827D, volDn:0x807FA25D, chUp:0x807F48B7, chDn:0x807FC837, n0:0x807F08F7, n1:0x807F8877, n2:0x807F48B7, n3:0x807FC837, n4:0x807F28D7, n5:0x807FA857, n6:0x807F6897, n7:0x807FE817, n8:0x807F18E7, n9:0x807F9867},
    jio:      {power:0x807F02FD, ok:0x807F1AE5, up:0x807F9A65, down:0x807F5AA5, left:0x807FDA25, right:0x807F3AC5, back:0x807F22DD, home:0x807FE21D, menu:0x807F6A95, volUp:0x807F827D, volDn:0x807FA25D, chUp:0x807F48B7, chDn:0x807FC837, n0:0x807F08F7, n1:0x807F8877, n2:0x807F48B7, n3:0x807FC837, n4:0x807F28D7, n5:0x807FA857, n6:0x807F6897, n7:0x807FE817, n8:0x807F18E7, n9:0x807F9867}
  },

  // Fan (simple NEC toggle codes)
  fan: {
    _timing: {hdr:9000,hdrS:4500,bit:560,oneS:1690,zeroS:560},
    generic:  {power:0x01FE48B7, speedUp:0x01FE58A7, speedDn:0x01FE7887, swing:0x01FED827},
    usha:     {power:0x807F02FD, speedUp:0x807F827D, speedDn:0x807FA25D, swing:0x807F22DD},
    havells:  {power:0x807F02FD, speedUp:0x807F827D, speedDn:0x807FA25D, swing:0x807F22DD},
    orient:   {power:0x807F02FD, speedUp:0x807F827D, speedDn:0x807FA25D, swing:0x807F22DD},
    atomberg: {power:0x807F02FD, speedUp:0x807F827D, speedDn:0x807FA25D, swing:0x807F22DD},
    crompton: {power:0x807F02FD, speedUp:0x807F827D, speedDn:0x807FA25D, swing:0x807F22DD}
  },

  // Helpers
  necToPattern: function(code) {
    var bits = code.toString(2).padStart(32,'0');
    var p = [9000,4500];
    for(var i=0;i<bits.length;i++){p.push(560);p.push(bits[i]==='1'?1690:560);}
    p.push(560);p.push(10000);
    return p;
  }
};
