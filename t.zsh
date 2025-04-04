#!/bin/zsh

names=(
  ChiomaAguoru
  CameronAllison
  YarisAmayaOrellana
  ReginaAvila
  KalebAziz
  EllaBagby
  John_CodyBaird
  FridaBalderas_Pena
  JennaBarro
  AndrewBautista
  KeeganBeard
  TanmayeeBharadwaj
  AnthonyBoardman
  NicoleCain
  AvaCarzola
  MicheleCastroMancilla
  OliviaCeaser
  TheodoreChau
  DavidChien
  ThomasChun
  LillianCoan
  LaurenCogbill
  DanielColcock
  AngelDuran_Gonzalez
  SethEastman
  CharisElkinton
  ElijahEngland
  EzraEstrada
  MichelleEstrella
  SkylarEvans
  LaurenFinnerty
  VanessaFlores
  EricFreeman
  MichaelGame
  YasminGarcia
  EllaGault
  TannerGerhardt
  SarasGruber
  ElizabethHan
  AndrewHeitmeyer
  ClaireHuang
  KeiraHumphries
  MarcoHurtado
  AbrilIracheta
  JialiJaddangi
  MeghanJames
  EvaJimenez
  RosalindaJoachim
  MelikeKara
  GabrielKaye
  AnnabelleKim
  HeatherKim
  SydneyKittelberger
  WesleyKuykendall
  ArielLagunas
  SissiLai
  AlanaLee
  ChelseaLee
  ElvisLee
  JadarienLester
  AmeliaLewey
  RihannaLyu
  KaylaMarin
  ZahraMehdi
  MarceloMendez
  FinchMiller
  CarlyMills
  EricMoczygemba
  JovannaMolina
  KattiaMoralesGonzalez
  NickMorris
  CrystalNguyen
  EverestNguyen
  HoangMinhNguyen
  KimNganNguyen
  LanaNguyen
  VictoriaNicolaevna
  SebastianNieto
  RinNishiwaki
  OllieOtou_Branckaert
  JocelynePartida
  KylaPatel
  KayliePerez
  NathanPoling
  DanielPortillo
  ShemarPradia
  HelenRadza
  CristianRodriguez
  AlexRosemann
  HaydenRoss
  NoahRutledge
  AllysonSalas
  JaeSandweg
  JeremyScheppers
  CullenScott
  AdahSkaff
  NatalieSottek
  LuisTorresMillan
  BriannaTorres
  LinhTran
  TreTrevino
  NaomiVega
  JosiahVillarrealFlores
  DevonVoyles
  LuxiWang
  BrandonWicken
  MeganYeoman
  BeccaYoungers
  DaeYparraguirre
  AlanZhou
  AdamZuber
)

for name in $names; do
  cat <<EOF > "${name}.pde"
class ${name} extends Snake {
  ${name}(int x, int y) {
    super(x, y, "${name}");
    updateInterval = 100;  // Standard speed
  }

  void think(ArrayList<Food> food, ArrayList<Snake> snakes) {
    // Just randomly choose a direction
    float rand = random(1);
    float dx = 0, dy = 0;

    if (rand < 0.25) {
      dx = 1;  // Right
    } else if (rand < 0.5) {
      dx = -1; // Left
    } else if (rand < 0.75) {
      dy = 1;  // Down
    } else {
      dy = -1; // Up
    }

    // Only set direction if it won't cause a collision
    PVector newPos = new PVector(
      segments.get(0).x + dx,
      segments.get(0).y + dy
      );

    if (!checkWallCollision(newPos) && !checkSnakeCollisions(newPos, snakes)) {
      setDirection(dx, dy);
    }
  }
}
EOF
done

