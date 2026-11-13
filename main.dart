import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const TrucoApp());

class TrucoApp extends StatelessWidget {
  const TrucoApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Truco Mineiro',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff146b42)), useMaterial3: true),
    home: const TablePage(),
  );
}

class PlayingCard {
  final String rank, suit;
  const PlayingCard(this.rank, this.suit);
  String get label => '$rank$suit';
}

class TablePage extends StatefulWidget {
  const TablePage({super.key});
  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  final roomController = TextEditingController(text: 'TRUCO7');
  final random = Random();
  List<PlayingCard> myCards = [], played = [];
  bool started = false, roomReady = false;
  String status = 'Crie uma sala ou entre com um código para começar.';
  final players = ['Você', 'Aguardando', 'Aguardando', 'Aguardando'];

  List<PlayingCard> makeDeck() {
    const ranks = ['4','5','6','7','Q','J','K','A','2','3'];
    const suits = ['♣','♥','♠','♦'];
    return [for (final s in suits) for (final r in ranks) PlayingCard(r,s)];
  }
  void createRoom() => setState(() { roomReady=true; status='Sala criada. Código: ${roomController.text.toUpperCase()}'; });
  void joinRoom() => setState(() { roomReady=true; status='Entrada demonstrativa. Ainda não conecta celulares pela internet.'; });
  void fillBots() => setState(() {
    for (var i=1;i<4;i++) { players[i]='Bot $i'; }
    status='Mesa completa: você e 3 bots. Bots ainda não jogam automaticamente.';
  });
  void deal() {
    final deck=makeDeck()..shuffle(random);
    setState(() { myCards=deck.take(3).toList(); played=[]; started=true; status='Cartas distribuídas! Você recebeu 3 cartas.'; });
  }
  void playCard(int i) {
    if (!started || i>=myCards.length) return;
    setState(() { played.add(myCards.removeAt(i)); status='Você jogou uma carta.'; });
  }
  @override
  void dispose() { roomController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xff102f25),
    appBar: AppBar(title: const Text('TRUCO MINEIRO'), centerTitle: true, backgroundColor: const Color(0xff0b241c), foregroundColor: Colors.white),
    body: SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [
      Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xff1d6847), borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          const Text('SALA ONLINE', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(controller: roomController, textCapitalization: TextCapitalization.characters, style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Código da sala', labelStyle: TextStyle(color: Colors.white70), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54)), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)))),
          const SizedBox(height: 10),
          Wrap(spacing: 8, children: [
            FilledButton(onPressed: createRoom, child: const Text('Criar sala')),
            OutlinedButton(onPressed: joinRoom, style: OutlinedButton.styleFrom(foregroundColor: Colors.white,side: const BorderSide(color: Colors.white)), child: const Text('Entrar na sala')),
          ]),
        ])),
      const SizedBox(height: 16),
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xff17613e),borderRadius: BorderRadius.circular(20),border: Border.all(color: const Color(0xff8ac7a4),width: 2)),
        child: Column(children: [
          const Text('MESA — 4 JOGADORES / 2 DUPLAS', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
          const SizedBox(height: 16), seat(players[1],'Dupla adversária'),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [seat(players[2],'Sua dupla'),seat(players[0],'Você')]),
          const SizedBox(height: 18),
          Container(height: 110,width: double.infinity,decoration: BoxDecoration(color: const Color(0xff0d4a32),borderRadius: BorderRadius.circular(14),border: Border.all(color: Colors.white30)),
            child: Center(child: played.isEmpty ? const Text('Cartas jogadas aparecem aqui',style: TextStyle(color: Colors.white70)) : Wrap(spacing: 8,children: played.map((c)=>cardWidget(c,small:true)).toList()))),
          const SizedBox(height: 12), seat(players[3],'Dupla adversária'),
        ])),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: FilledButton.tonal(onPressed: roomReady?fillBots:null,child: const Text('Completar com bots'))),
        const SizedBox(width: 8),
        Expanded(child: FilledButton(onPressed: roomReady?deal:null,child: const Text('Distribuir cartas'))),
      ]),
      const SizedBox(height: 16),
      const Text('SUAS CARTAS',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      if (myCards.isEmpty) const Text('As cartas aparecerão aqui depois da distribuição.',style: TextStyle(color: Colors.white70))
      else Wrap(spacing: 10,runSpacing: 10,children: List.generate(myCards.length,(i)=>InkWell(onTap:()=>playCard(i),child:cardWidget(myCards[i])))),
      const SizedBox(height: 16),
      Container(padding: const EdgeInsets.all(12),decoration: BoxDecoration(color: Colors.black26,borderRadius: BorderRadius.circular(12)),child: Text(status,style: const TextStyle(color: Colors.white))),
      const SizedBox(height: 10),
      const Text('Protótipo visual local. Conexão real entre celulares, regras completas e bots que jogam serão etapas futuras.',style: TextStyle(color: Colors.white60,fontSize:12),textAlign: TextAlign.center),
    ])),
  );

  Widget seat(String name,String role)=>Column(children:[
    const CircleAvatar(backgroundColor: Color(0xffd7e8d9),child: Icon(Icons.person,color: Color(0xff16452f))),
    const SizedBox(height:4),Text(name,style: const TextStyle(color:Colors.white,fontWeight:FontWeight.bold)),
    Text(role,style: const TextStyle(color:Colors.white60,fontSize:11)),
  ]);
  Widget cardWidget(PlayingCard c,{bool small=false}) {
    final red=c.suit=='♥'||c.suit=='♦';
    return Container(width:small?48:76,height:small?68:108,padding:const EdgeInsets.all(6),
      decoration:BoxDecoration(color:const Color(0xfffffdf4),borderRadius:BorderRadius.circular(8),border:Border.all(color:Colors.black26),boxShadow:const [BoxShadow(color:Colors.black26,blurRadius:4,offset:Offset(1,2))]),
      child:Center(child:Text(c.label,style:TextStyle(fontSize:small?18:28,fontWeight:FontWeight.bold,color:red?Colors.red.shade700:Colors.black87))));
  }
}
