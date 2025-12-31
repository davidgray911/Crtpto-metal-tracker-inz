import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

// =============================================================================
// GLOBALNY SYSTEM WALUT
// =============================================================================
class GlobalFinance {
  static ValueNotifier<String> selectedCurrency = ValueNotifier<String>("USD");
  static Map<String, double> rates = {
    "USD": 1.0, 
    "PLN": 4.02, 
    "EUR": 0.91, 
    "CHF": 0.88, 
    "GBP": 0.78
  };

  static double convert(double usdAmount) {
    return usdAmount * (rates[selectedCurrency.value] ?? 1.0);
  }

  static String get sign {
    switch (selectedCurrency.value) {
      case "PLN": return "zł";
      case "EUR": return "€";
      case "CHF": return "fr";
      case "GBP": return "£";
      default: return "\$";
    }
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const InvestorMasterApp());
}

class InvestorMasterApp extends StatelessWidget {
  const InvestorMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Investor Master',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF070707),
        cardColor: const Color(0xFF121212),
        primarySwatch: Colors.amber,
        useMaterial3: true,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const CryptoMarketScreen(),
    const MetalsMarketScreen(),
    const CurrencyExchangeScreen(),
    const AssetBankScreen(),
    const RelaxationHub(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5))
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          backgroundColor: const Color(0xFF070707),
          indicatorColor: Colors.amber.withOpacity(0.1),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.show_chart_rounded), label: 'Giełda'),
            NavigationDestination(icon: Icon(Icons.diamond_outlined), label: 'Metale'),
            NavigationDestination(icon: Icon(Icons.currency_exchange_rounded), label: 'Kantor'),
            NavigationDestination(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Portfel'),
            NavigationDestination(icon: Icon(Icons.sports_esports_rounded), label: 'Relaks'),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// KOMPONENTY WSPÓLNE
// =============================================================================

class ProfessionalHeader extends StatelessWidget {
  final String title;
  const ProfessionalHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
      child: SizedBox(
        height: 50,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              title, 
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)
            ),
            Align(
              alignment: Alignment.centerRight,
              child: _CurrencyPickerWidget(height: 40),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencyPickerWidget extends StatelessWidget {
  final double height;
  const _CurrencyPickerWidget({super.key, this.height = 45});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: GlobalFinance.selectedCurrency,
      builder: (context, val, _) => Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: val,
            dropdownColor: const Color(0xFF1A1A1A),
            items: ["USD", "PLN", "EUR", "CHF", "GBP"].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)))).toList(),
            onChanged: (v) => GlobalFinance.selectedCurrency.value = v!,
          ),
        ),
      ),
    );
  }
}

// Helper do instrukcji gier
Future<void> showGameInfo(BuildContext context, String title, String desc, VoidCallback onPlay, {bool warning = false}) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white10)),
      title: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 24)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(color: Colors.white24),
          const SizedBox(height: 15),
          Text(desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, height: 1.5)),
          if(warning) ...[
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.15), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.redAccent)),
              child: const Row(children: [
                Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 30),
                SizedBox(width: 10),
                Expanded(child: Text("UWAGA: Gra zawiera szybko migające kolory. Może wywołać napad epilepsji.", style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)))
              ])
            )
          ],
          const SizedBox(height: 10),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
          onPressed: () {
            Navigator.of(ctx).pop();
            onPlay();
          },
          child: const Text("GRAJ", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        )
      ],
    ),
  );
}

// Helper do ekranu przegranej
Widget buildGameOverScreen({required String scoreInfo, required VoidCallback onRestart, required VoidCallback onExit, String title = "KONIEC GRY"}) {
  return Center(
    child: Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withOpacity(0.5), width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.9), blurRadius: 30)]
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.redAccent)),
          const SizedBox(height: 15),
          Text(scoreInfo, style: const TextStyle(fontSize: 18, color: Colors.white70), textAlign: TextAlign.center),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRestart,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, padding: const EdgeInsets.all(15)),
              child: const Text("ZAGRAJ PONOWNIE", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onExit,
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24), padding: const EdgeInsets.all(15)),
              child: const Text("WYJDŹ DO MENU", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    ),
  );
}

// =============================================================================
// EKRAN GŁÓWNY (CryptoMarketScreen) + DETALE (CryptoDetails)
// Wklej to w miejsce starego kodu.
// =============================================================================

class CryptoMarketScreen extends StatefulWidget {
  const CryptoMarketScreen({super.key});
  @override State<CryptoMarketScreen> createState() => _CryptoMarketScreenState();
}

class _CryptoMarketScreenState extends State<CryptoMarketScreen> {
  List _allCoins = [];
  List _filteredCoins = [];
  bool _loading = true;
  bool _showOnlyFavs = false;
  final Set<String> _favoritedIds = {};
  final TextEditingController _searchController = TextEditingController();

  final Map<String, dynamic> _coinStyleMap = {
    'btc': {'color': const Color(0xFFF7931A), 'icon': Icons.currency_bitcoin},
    'eth': {'color': const Color(0xFF627EEA), 'icon': Icons.token},
    'usdt': {'color': const Color(0xFF26A17B), 'icon': Icons.attach_money},
    'bnb': {'color': const Color(0xFFF3BA2F), 'icon': Icons.account_balance_wallet},
    'sol': {'color': const Color(0xFF9945FF), 'icon': Icons.sunny},
    'xrp': {'color': Colors.blueGrey, 'icon': Icons.change_circle},
    'usdc': {'color': const Color(0xFF2775CA), 'icon': Icons.monetization_on},
    'ada': {'color': const Color(0xFF0033AD), 'icon': Icons.timeline},
    'doge': {'color': const Color(0xFFC2A633), 'icon': Icons.pets},
    'dot': {'color': const Color(0xFFE6007A), 'icon': Icons.hub},
  };

  @override void initState() { super.initState(); _fetch(); }

  Future<void> _fetch() async {
    try {
      final res = await http.get(Uri.parse('https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=250&page=1'));
      if (res.statusCode == 200 && mounted) {
        setState(() { 
          _allCoins = json.decode(res.body); 
          _filteredCoins = _allCoins;
          _loading = false; 
        });
      }
    } catch (e) { if (mounted) _generateFallbackData(); }
  }

  void _generateFallbackData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Prosty mechanizm, żeby nie blokować UI w razie błędu sieci
    if (mounted) setState(() { _loading = false; }); 
  }

  void _filter(String query) {
    setState(() {
      _filteredCoins = _allCoins.where((coin) {
        final name = coin['name'].toString().toLowerCase();
        final symbol = coin['symbol'].toString().toLowerCase();
        return (name.contains(query.toLowerCase()) || symbol.contains(query.toLowerCase())) && (_showOnlyFavs ? _favoritedIds.contains(coin['id']) : true);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Używamy GlobalFinance (które masz zdefiniowane wyżej w pliku)
    return ValueListenableBuilder(
      valueListenable: GlobalFinance.selectedCurrency,
      builder: (context, currency, _) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
            // TŁO GRADIENTOWE (CIEMNE)
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF150A25), Color(0xFF000000)], 
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // --- 1. NAGŁÓWEK ---
                  const Padding(
                    padding: EdgeInsets.only(top: 30, bottom: 20),
                    child: Center(
                      child: Text("KRYPTOWALUTY", 
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white)
                      )
                    ),
                  ),
                  
                  // --- 2. WYSZUKIWARKA (CIEMNA PASTYLKA) ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111), // Bardzo ciemne tło
                        borderRadius: BorderRadius.circular(20), // Zaokrąglenie
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filter,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Wpisz kryptowalutę +200",
                          hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // --- 3. PRZYCISKI W JEDNYM RZĘDZIE (ULUBIONE + WALUTA) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // BUTTON: ULUBIONE
                      GestureDetector(
                        onTap: () { setState(() => _showOnlyFavs = !_showOnlyFavs); _filter(_searchController.text); },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16161E), // Ciemne tło
                            borderRadius: BorderRadius.circular(12),
                            border: _showOnlyFavs ? Border.all(color: Colors.amber, width: 1) : null,
                          ),
                          child: Row(
                            children: [
                              Icon(_showOnlyFavs ? Icons.star : Icons.star_border, color: Colors.amber, size: 18),
                              const SizedBox(width: 8),
                              const Text("Ulubione", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 15),

                      // BUTTON: WALUTA (USD)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16161E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: currency,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                            dropdownColor: const Color(0xFF1E1E1E),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            items: GlobalFinance.rates.keys.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (v) => GlobalFinance.selectedCurrency.value = v!,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // --- 4. LISTA KART ---
                  Expanded(
                    child: _loading 
                      ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                      : ListView.builder(
                          itemCount: _filteredCoins.length,
                          padding: const EdgeInsets.only(top: 10, bottom: 20),
                          itemBuilder: (context, i) => _buildCoinItem(_filteredCoins[i]),
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildCoinItem(dynamic coin) {
    final double rawPrice = (coin['current_price'] as num?)?.toDouble() ?? 0.0;
    final double price = GlobalFinance.convert(rawPrice);
    final double change = (coin['price_change_percentage_24h'] as num?)?.toDouble() ?? 0.0;
    final bool isFav = _favoritedIds.contains(coin['id']);
    final String symbol = (coin['symbol'] ?? '').toString().toLowerCase();

    Widget iconWidget = CircleAvatar(
      radius: 22,
      backgroundColor: Colors.white.withOpacity(0.05),
      child: Image.network(
        coin['image'] ?? '', 
        width: 32, height: 32,
        errorBuilder: (context, error, stackTrace) {
          if (_coinStyleMap.containsKey(symbol)) {
             var style = _coinStyleMap[symbol];
             return Icon(style['icon'] as IconData, color: style['color'] as Color, size: 26);
          }
          return const Icon(Icons.currency_bitcoin, color: Colors.amber, size: 26);
        },
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0B0B0B), // Prawie czarne tło karty
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            iconWidget,
            const SizedBox(width: 15),
            
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(coin['name'] ?? 'Brak', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
              Text(symbol.toUpperCase(), style: const TextStyle(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.w500)),
            ])),
            
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text("${GlobalFinance.sign}${price.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white)),
              Row(children: [
                Icon(change >= 0 ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: change >= 0 ? Colors.greenAccent : Colors.redAccent, size: 18),
                Text("${change.abs().toStringAsFixed(2)}%", style: TextStyle(color: change >= 0 ? Colors.greenAccent : Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
              ])
            ]),
            
            const SizedBox(width: 10),
            
            IconButton(
              constraints: const BoxConstraints(), 
              padding: EdgeInsets.zero, 
              icon: Icon(isFav ? Icons.star : Icons.star_border, color: Colors.amber, size: 24), 
              onPressed: () => setState(() => isFav ? _favoritedIds.remove(coin['id']) : _favoritedIds.add(coin['id']))
            ),
            
            IconButton(
              constraints: const BoxConstraints(), 
              padding: EdgeInsets.zero, 
              icon: const Icon(Icons.bar_chart_rounded, color: Colors.amber, size: 24), 
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CryptoDetails(coin: coin)))
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// EKRAN SZCZEGÓŁÓW (CryptoDetails) - BEZ ZMIAN, ŻEBYŚ NIE MIAŁ BŁĘDÓW
// =============================================================================
class CryptoDetails extends StatefulWidget {
  final dynamic coin;
  const CryptoDetails({required this.coin, super.key});
  @override State<CryptoDetails> createState() => _CryptoDetailsState();
}

class _CryptoDetailsState extends State<CryptoDetails> {
  int _range = 7;
  List<FlSpot> _spots = [];

  @override void initState() { super.initState(); _loadChart(); }

  Future<void> _loadChart() async {
    try {
      final res = await http.get(Uri.parse('https://api.coingecko.com/api/v3/coins/${widget.coin['id']}/market_chart?vs_currency=usd&days=$_range'));
      if (res.statusCode == 200 && mounted) {
        final List prices = json.decode(res.body)['prices'];
        setState(() {
          _spots = prices.asMap().entries.map((e) => FlSpot(e.key.toDouble(), GlobalFinance.convert(e.value[1].toDouble()))).toList();
        });
      }
    } catch (e) {
       if (mounted) setState(() => _spots = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white), title: Text(widget.coin['name'], style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white))),
      body: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [1, 7, 30].map((d) => Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: ChoiceChip(label: Text(d == 1 ? "24H" : "${d}D"), labelStyle: TextStyle(color: _range == d ? Colors.black : Colors.white), selectedColor: Colors.amber, backgroundColor: Colors.white10, selected: _range == d, onSelected: (v) { setState(() => _range = d); _loadChart(); }))).toList()),
          const SizedBox(height: 30),
          Container(
            height: 250,
            width: double.infinity,
            padding: const EdgeInsets.only(right: 20),
            child: _spots.isEmpty ? const Center(child: CircularProgressIndicator(color: Colors.amber)) : LineChart(LineChartData(gridData: const FlGridData(show: false), titlesData: const FlTitlesData(show: false), borderData: FlBorderData(show: false), lineBarsData: [LineChartBarData(spots: _spots, isCurved: true, barWidth: 4, color: Colors.amber, isStrokeCapRound: true, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: true, gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.amber.withOpacity(0.2), Colors.transparent])))]))),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: const Color(0xFF121212), borderRadius: BorderRadius.circular(28)),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Kapitalizacja", style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold)), Text("${GlobalFinance.sign}${widget.coin['market_cap'] ?? '984,231,000'}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))]),
                const Divider(height: 30, color: Colors.white10),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Wolumen (24h)", style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold)), Text("${GlobalFinance.sign}${widget.coin['total_volume'] ?? '42,120,500'}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))]),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
// =============================================================================
// 2. METALE SZLACHETNE (PORTFOLIO HEADER STYLE - STRZAŁECZKA I WALUTA PIONOWO)
// =============================================================================

class MetalsMarketScreen extends StatefulWidget {
  const MetalsMarketScreen({super.key});
  @override State<MetalsMarketScreen> createState() => _MetalsMarketScreenState();
}

class _MetalsMarketScreenState extends State<MetalsMarketScreen> {
  double _gold = 0, _silver = 0, _platinum = 0, _palladium = 0;
  bool _loading = true;
  final TextEditingController _gramsController = TextEditingController(text: "1");
  String _selectedMetal = 'Złoto';

  @override void initState() { super.initState(); _fetchMetalsData(); }

  Future<void> _fetchMetalsData() async {
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() { _gold = 2655.80; _silver = 31.45; _platinum = 985.20; _palladium = 1060.10; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: GlobalFinance.selectedCurrency,
      builder: (context, currentCurrency, _) {
        double grams = double.tryParse(_gramsController.text.replaceAll(',', '.')) ?? 0;
        double priceOz = _selectedMetal == 'Srebro' ? _silver : _selectedMetal == 'Platyna' ? _platinum : _selectedMetal == 'Pallad' ? _palladium : _gold;
        double totalValue = GlobalFinance.convert((priceOz / 31.1035) * grams);

        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [Color(0xFF150A25), Color(0xFF070707)], 
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // --- NAGŁÓWEK (STYL PORTFELA) ---
                  Padding(
                    padding: const EdgeInsets.only(top: 25, bottom: 10),
                    child: Column(
                      children: [
                        const Text("KRUSZCE", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 3, color: Colors.white)),
                        const SizedBox(height: 10),
                        
                        // SPECJALNY DROPDOWN (PIONOWY: WALUTA -> STRZAŁKA) 
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: currentCurrency,
                            icon: const SizedBox.shrink(), // Ukrywamy domyślną strzałkę z boku
                            alignment: Alignment.center,
                            dropdownColor: const Color(0xFF1E1E2C),
                            // Widok przed rozwinięciem (Pionowo)
                            selectedItemBuilder: (BuildContext context) {
                              return GlobalFinance.rates.keys.map<Widget>((String value) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                    const Icon(Icons.keyboard_arrow_down, color: Colors.amber, size: 20), // Strzałka pod spodem
                                  ],
                                );
                              }).toList();
                            },
                            // Lista rozwijana
                            items: GlobalFinance.rates.keys.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Center(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold))),
                              );
                            }).toList(),
                            onChanged: (v) => GlobalFinance.selectedCurrency.value = v!,
                          ),
                        ),
                        // MAŁY NAPIS POD SPODEM
                        const Text("Zmień walutę", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  
                  // --- SIATKA CEN ---
                  Expanded(
                    flex: 5,
                    child: _loading 
                      ? const Center(child: CircularProgressIndicator(color: Colors.amber)) 
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GridView.count(
                            physics: const NeverScrollableScrollPhysics(), 
                            crossAxisCount: 2,
                            childAspectRatio: 1.3,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            children: [
                              _card("Złoto", _gold, 1.2, Colors.amber, Icons.diamond), 
                              _card("Srebro", _silver, -0.8, Colors.blueGrey, Icons.lens_blur),
                              _card("Platyna", _platinum, 0.4, Colors.indigoAccent, Icons.settings), 
                              _card("Pallad", _palladium, -1.5, Colors.tealAccent, Icons.filter_hdr),
                            ],
                          ),
                        ),
                  ),
                  
                  // --- KALKULATOR ---
                  Expanded(
                    flex: 4, 
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20), 
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E2C), 
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15, offset: const Offset(0, 5))]
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                        crossAxisAlignment: CrossAxisAlignment.center, 
                        children: [
                          const Text("SZYBKA WYCENA", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white54, letterSpacing: 1.5)),
                          
                          // INPUTY
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // LEWA STRONA (KRUSZEC)
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center, 
                                  children: [
                                    const Padding(padding: EdgeInsets.only(bottom: 8), child: Text("Kruszec", style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold))),
                                    Container(
                                      height: 55, 
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)),
                                      alignment: Alignment.center,
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _selectedMetal, 
                                          isExpanded: true,
                                          dropdownColor: const Color(0xFF252535),
                                          icon: const Icon(Icons.arrow_drop_down, color: Colors.amber),
                                          style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                                          items: ["Złoto", "Srebro", "Platyna", "Pallad"].map((e) => DropdownMenuItem(value: e, child: Center(child: Text(e)))).toList(),
                                          onChanged: (v) => setState(() => _selectedMetal = v!),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 15),
                              
                              // PRAWA STRONA (GRAMY)
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center, 
                                  children: [
                                    const Padding(padding: EdgeInsets.only(bottom: 8), child: Text("Gramy", style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold))),
                                    Container(
                                      height: 55, 
                                      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)),
                                      alignment: Alignment.center,
                                      child: TextField(
                                        controller: _gramsController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        onChanged: (v) => setState(() {}),
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero, isDense: true),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const Divider(color: Colors.white10),
                          
                          // WYNIK
                          Column(
                            children: [
                              const Text("Wartość", style: TextStyle(color: Colors.white54, fontSize: 13, letterSpacing: 1)),
                              const SizedBox(height: 5),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text("${GlobalFinance.sign} ${totalValue.toStringAsFixed(2)}", style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.amber)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _card(String n, double p, double change, Color col, IconData icon) {
    double price = GlobalFinance.convert(p);
    bool up = change >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8), 
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C), 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.white.withOpacity(0.05))
      ), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
        children: [
          Icon(icon, color: col, size: 28),
          Text(n, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), 
          FittedBox(fit: BoxFit.scaleDown, child: Text("${GlobalFinance.sign}${price.toStringAsFixed(2)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: up ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(up ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: up ? Colors.greenAccent : Colors.redAccent, size: 16),
                Text("${change.abs()}%", style: TextStyle(color: up ? Colors.greenAccent : Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold))
              ],
            )
          ),
        ]
      )
    );
  }
}
// =============================================================================
// 3. KANTOR (RED BUTTON, WHITE ARROWS, CENTERED TITLE)
// =============================================================================

class CurrencyExchangeScreen extends StatefulWidget {
  const CurrencyExchangeScreen({super.key});
  @override State<CurrencyExchangeScreen> createState() => _CurrencyExchangeScreenState();
}

class _CurrencyExchangeScreenState extends State<CurrencyExchangeScreen> {
  final _input = TextEditingController(text: "1000"); 
  String _from = "USD", _to = "PLN";

  // Helper do flag
  String _getFlag(String code) {
    switch (code) {
      case 'USD': return '🇺🇸';
      case 'PLN': return '🇵🇱';
      case 'EUR': return '🇪🇺';
      case 'CHF': return '🇨🇭';
      case 'GBP': return '🇬🇧';
      default: return '🏳️';
    }
  }

  @override Widget build(BuildContext context) {
    double amt = double.tryParse(_input.text.replaceAll(',', '.')) ?? 0;
    double result = amt * (GlobalFinance.rates[_to]! / GlobalFinance.rates[_from]!);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        // TŁO GRADIENTOWE
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [Color(0xFF150A25), Color(0xFF070707)], 
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            // NAGŁÓWEK "KANTOR"
            const Padding(
              padding: EdgeInsets.only(top: 35, bottom: 5), 
              child: Center(
                child: Text("KANTOR", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 4, color: Colors.white))
              )
            ),
            const Center(child: Text("Szybki przelicznik walut", style: TextStyle(color: Colors.white38, fontSize: 13, letterSpacing: 1))),
            
            const SizedBox(height: 30),
            
            // GŁÓWNA KARTA PRZELICZNIKA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2C), 
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15, offset: const Offset(0, 5))],
                  border: Border.all(color: Colors.white.withOpacity(0.05))
                ),
                child: Column(
                  children: [
                    // GÓRA - Z WALUTY
                    _currencyRow("Sprzedajesz", _from, _input, (v) => setState(() => _from = v!), false),
                    
                    // PRZYCISK ZAMIANY (CZERWONY + BIAŁE STRZAŁKI)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Divider(color: Colors.white10, height: 1),
                          GestureDetector(
                            onTap: () { setState(() { var t = _from; _from = _to; _to = t; }); },
                            child: Container(
                              padding: const EdgeInsets.all(10), // Nieco większy padding dla wygody
                              decoration: BoxDecoration(
                                color: Colors.redAccent, // CZERWONY KOLOR
                                shape: BoxShape.circle, 
                                boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(0.4), blurRadius: 12)] // Czerwona poświata
                              ),
                              child: const Icon(Icons.swap_vert_rounded, color: Colors.white, size: 26), // BIAŁE STRZAŁKI
                            ),
                          )
                        ],
                      ),
                    ),

                    // DÓŁ - NA WALUTĘ
                    _currencyRow("Kupujesz", _to, TextEditingController(text: result.toStringAsFixed(2)), (v) => setState(() => _to = v!), true),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // NAGŁÓWEK LISTY - TERAZ WYŚRODKOWANY
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 15),
                child: Text("POPULARNE KURSY", style: TextStyle(letterSpacing: 2, fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white38)),
              ),
            ),
            
            // LISTA KURSÓW
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: GlobalFinance.rates.keys.where((k) => k != "PLN").map((target) {
                  double rateToPln = GlobalFinance.rates["PLN"]! / GlobalFinance.rates[target]!;
                  bool isUp = (target == "USD" || target == "GBP"); 
                  double pct = isUp ? 0.12 : 0.08;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2C), 
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.03))
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Text(_getFlag(target), style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("$target / PLN", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                              const Text("Kurs średni", style: TextStyle(color: Colors.white24, fontSize: 11)),
                            ],
                          ),
                        ]),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text("${rateToPln.toStringAsFixed(4)} zł", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white)),
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: isUp ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                            child: Text("${isUp ? '+' : '-'}${pct}%", style: TextStyle(color: isUp ? Colors.greenAccent : Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                          )
                        ]),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _currencyRow(String label, String cur, TextEditingController c, Function(String?) onC, bool lock) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextField(
                controller: c,
                readOnly: lock,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white), 
                decoration: const InputDecoration(border: InputBorder.none, isDense: true, hintText: "0.00", hintStyle: TextStyle(color: Colors.white10)),
              )
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(15)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: cur,
                  dropdownColor: const Color(0xFF252535),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 18),
                  items: GlobalFinance.rates.keys.map((e) => DropdownMenuItem(value: e, child: Row(children: [Text(_getFlag(e), style: const TextStyle(fontSize: 18)), const SizedBox(width: 8), Text(e, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]))).toList(),
                  onChanged: onC
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}
// =============================================================================
// 4. PORTFEL (REAL CRYPTO ICONS - IKONY KRYPTO JAK W EKRANIE 1)
// =============================================================================

class AssetBankScreen extends StatefulWidget {
  const AssetBankScreen({super.key});
  @override State<AssetBankScreen> createState() => _AssetBankScreenState();
}

class _AssetBankScreenState extends State<AssetBankScreen> {
  // Przykładowe portfolio - TERAZ Z LINKAMI DO OBRAZKÓW DLA KRYPTO
  final List<Map<String, dynamic>> _portfolio = [
    {'type': 'CRYPTO', 'name': 'Bitcoin', 'symbol': 'BTC', 'amount': 0.45, 'price': 96500.0, 'image': 'https://assets.coingecko.com/coins/images/1/large/bitcoin.png', 'color': const Color(0xFFF7931A), 'change': 2.45},
    {'type': 'CRYPTO', 'name': 'Ethereum', 'symbol': 'ETH', 'amount': 12.5, 'price': 2750.0, 'image': 'https://assets.coingecko.com/coins/images/279/large/ethereum.png', 'color': const Color(0xFF627EEA), 'change': -1.12},
    {'type': 'METAL', 'name': 'Złoto', 'symbol': 'XAU', 'amount': 50.0, 'price': 85.40, 'icon': Icons.diamond_outlined, 'color': const Color(0xFFFFD700), 'change': 0.85},
    {'type': 'FIAT', 'name': 'Dolar', 'symbol': 'USD', 'amount': 12500.0, 'price': 1.0, 'icon': Icons.attach_money, 'color': const Color(0xFF00E676), 'change': 0.0},
    {'type': 'CRYPTO', 'name': 'Solana', 'symbol': 'SOL', 'amount': 150.0, 'price': 195.0, 'image': 'https://assets.coingecko.com/coins/images/4128/large/solana.png', 'color': const Color(0xFF9945FF), 'change': 5.20},
  ];

  // BAZA DANYCH (ZAKTUALIZOWANA O LINKI)
  final List<Map<String, dynamic>> _database = [
     {'type': 'METAL', 'name': 'Złoto', 'symbol': 'XAU', 'price': 85.40, 'icon': Icons.diamond, 'color': const Color(0xFFFFD700)},
     {'type': 'METAL', 'name': 'Srebro', 'symbol': 'XAG', 'price': 1.05, 'icon': Icons.lens_blur, 'color': Colors.grey},
     {'type': 'FIAT', 'name': 'Dolar', 'symbol': 'USD', 'price': 1.0, 'icon': Icons.attach_money, 'color': Colors.green},
     {'type': 'FIAT', 'name': 'Euro', 'symbol': 'EUR', 'price': 1.08, 'icon': Icons.euro, 'color': Colors.blue},
     {'type': 'CRYPTO', 'name': 'Bitcoin', 'symbol': 'BTC', 'price': 96500.0, 'image': 'https://assets.coingecko.com/coins/images/1/large/bitcoin.png', 'color': Colors.orange},
     {'type': 'CRYPTO', 'name': 'Ethereum', 'symbol': 'ETH', 'price': 2750.0, 'image': 'https://assets.coingecko.com/coins/images/279/large/ethereum.png', 'color': const Color(0xFF627EEA)},
     {'type': 'CRYPTO', 'name': 'Solana', 'symbol': 'SOL', 'price': 195.0, 'image': 'https://assets.coingecko.com/coins/images/4128/large/solana.png', 'color': const Color(0xFF9945FF)},
     {'type': 'CRYPTO', 'name': 'Cardano', 'symbol': 'ADA', 'price': 0.65, 'image': 'https://assets.coingecko.com/coins/images/975/large/cardano.png', 'color': Colors.blueAccent},
  ];

  void _openAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => _AssetSelectionModal(
        database: _database,
        onSelected: (item) {
          Navigator.pop(ctx);
          double randomChange = (Random().nextDouble() * 20) - 10;
          _openEditModal(item: {...item, 'change': randomChange}, isNew: true);
        },
      ),
    );
  }

  void _openEditModal({required Map<String, dynamic> item, bool isNew = false, int? index}) {
    final controller = TextEditingController(text: isNew ? '' : item['amount'].toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF252535),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          // Tutaj też obsługa ikony vs obrazka w tytule modala
          item.containsKey('image') 
            ? Image.network(item['image'], width: 24, height: 24)
            : Icon(item['icon'], color: item['color']),
          const SizedBox(width: 10),
          Flexible(child: Text(isNew ? "Dodaj ${item['name']}" : "Edytuj ${item['name']}", style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: "0.00",
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.black38,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                suffixText: item['symbol'],
              ),
            ),
            const SizedBox(height: 20),
            if (!isNew && index != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _portfolio.removeAt(index));
                    Navigator.pop(ctx);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: Colors.redAccent
                  ),
                  icon: const Icon(Icons.delete_forever),
                  label: const Text("USUŃ Z PORTFELA"),
                ),
              )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Anuluj", style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)),
            onPressed: () {
              double? val = double.tryParse(controller.text.replaceAll(',', '.'));
              if (val != null && val >= 0) {
                setState(() {
                  if (isNew) {
                    _portfolio.add({...item, 'amount': val});
                  } else if (index != null) {
                    _portfolio[index]['amount'] = val;
                  }
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text("Zapisz"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: GlobalFinance.selectedCurrency,
      builder: (context, currency, _) {
        double total = 0, crypto = 0, metal = 0, fiat = 0;
        for (var a in _portfolio) {
          double v = GlobalFinance.convert((a['amount'] as double) * (a['price'] as double));
          total += v;
          if (a['type'] == 'CRYPTO') crypto += v;
          if (a['type'] == 'METAL') metal += v;
          if (a['type'] == 'FIAT') fiat += v;
        }

        Color cCrypto = const Color(0xFF9C27B0);
        Color cMetal = const Color(0xFFFFC107);
        Color cFiat = const Color(0xFF00E676);

        List<PieChartSectionData> sections = [];
        if (total > 0) {
          if (crypto > 0) sections.add(PieChartSectionData(value: crypto, color: cCrypto, radius: 28, showTitle: false));
          if (metal > 0) sections.add(PieChartSectionData(value: metal, color: cMetal, radius: 28, showTitle: false));
          if (fiat > 0) sections.add(PieChartSectionData(value: fiat, color: cFiat, radius: 28, showTitle: false));
        } else {
          sections.add(PieChartSectionData(value: 1, color: Colors.white10, radius: 25, showTitle: false));
        }

        return Scaffold(
          floatingActionButton: FloatingActionButton(backgroundColor: const Color(0xFF6C63FF), onPressed: _openAddModal, child: const Icon(Icons.add, color: Colors.white)),
          body: Container(
            decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.center, colors: [Color(0xFF150A25), Color(0xFF070707)])),
            child: SafeArea(
              child: Column(
                children: [
                  // --- NAGŁÓWEK WYŚRODKOWANY Z PIONOWYM WYBOREM WALUTY ---
                  Padding(
                    padding: const EdgeInsets.only(top: 25, bottom: 10),
                    child: Column(
                      children: [
                        const Text("PORTFEL", style: TextStyle(color: Colors.white, letterSpacing: 4, fontWeight: FontWeight.w900, fontSize: 32)),
                        const SizedBox(height: 10),
                        
                        // SPECJALNY DROPDOWN (PIONOWY: WALUTA -> STRZAŁKA)
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: currency,
                            icon: const SizedBox.shrink(), // Ukrywamy domyślną strzałkę z boku
                            alignment: Alignment.center,
                            dropdownColor: const Color(0xFF1E1E2C),
                            // To buduje widok, który widzisz przed kliknięciem (Pionowo)
                            selectedItemBuilder: (BuildContext context) {
                              return GlobalFinance.rates.keys.map<Widget>((String value) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                    const Icon(Icons.keyboard_arrow_down, color: Colors.amber, size: 20), // Strzałka pod spodem
                                  ],
                                );
                              }).toList();
                            },
                            // To buduje listę rozwijaną (Standardowo)
                            items: GlobalFinance.rates.keys.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Center(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold))),
                              );
                            }).toList(),
                            onChanged: (v) => GlobalFinance.selectedCurrency.value = v!,
                          ),
                        ),
                        // MAŁY NAPIS POD SPODEM
                        const Text("ZMIEŃ WALUTĘ", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  
                  // WYKRES KOŁOWY
                  SizedBox(
                    height: 360, 
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(PieChartData(sections: sections, centerSpaceRadius: 100, sectionsSpace: 3, startDegreeOffset: 270)),
                        // Kontener na tekst w środku
                        Container(
                          width: 180, height: 180,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("CAŁKOWITE SALDO", style: TextStyle(color: Colors.white54, fontSize: 13, letterSpacing: 1.2)),
                              const SizedBox(height: 5),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text("${GlobalFinance.sign}${total.toStringAsFixed(0)}", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                        // LEGENDA NA SAMYM DOLE
                        Positioned(
                          bottom: 10,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (crypto > 0) _leg(cCrypto, "KRYPTO ${(crypto/total*100).toInt()}%"),
                              if (metal > 0) _leg(cMetal, "KRUSZCE ${(metal/total*100).toInt()}%"),
                              if (fiat > 0) _leg(cFiat, "GOTÓWKA ${(fiat/total*100).toInt()}%"),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  
                  // TYTUŁ WYŚRODKOWANY
                  const Center(child: Text("TWOJE AKTYWA", style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 13))),
                  const SizedBox(height: 10),
                  
                  // SIATKA (GRID) - ZAKTUALIZOWANA O LOGIKĘ OBRAZKÓW
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(color: Color(0xFF090909), borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
                      child: _portfolio.isEmpty
                        ? const Center(child: Text("PORTFEL JEST PUSTY", style: TextStyle(color: Colors.white24)))
                        : GridView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: _portfolio.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.95,
                            ),
                            itemBuilder: (ctx, i) {
                              final item = _portfolio[i];
                              double val = GlobalFinance.convert((item['amount'] as double) * (item['price'] as double));
                              double change = item['change'] as double;
                              bool up = change >= 0;

                              return GestureDetector(
                                onTap: () => _openEditModal(item: item, index: i),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E1E2C),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 4))]
                                  ),
                                  padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          // --- LOGIKA WYŚWIETLANIA: OBRAZEK DLA KRYPTO, IKONA DLA RESZTY ---
                                          item.containsKey('image') 
                                            ? CircleAvatar(
                                                radius: 20,
                                                backgroundColor: Colors.transparent,
                                                backgroundImage: NetworkImage(item['image']),
                                              )
                                            : Icon(item['icon'], color: item['color'], size: 36),
                                          
                                          const SizedBox(height: 10),
                                          Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 5),
                                          FittedBox(child: Text("${GlobalFinance.sign}${val.toStringAsFixed(0)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white), textAlign: TextAlign.center)),
                                          Text("${item['amount']} ${item['symbol']}", style: const TextStyle(color: Colors.white38, fontSize: 11), textAlign: TextAlign.center),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(color: up ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                                            child: Text("${up?'+':''}$change%", style: TextStyle(color: up ? Colors.greenAccent : Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                                          ),
                                          Row(children: const [
                                            Icon(Icons.edit, size: 14, color: Colors.white54),
                                            SizedBox(width: 4),
                                            Text("EDYCJA", style: TextStyle(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.bold))
                                          ])
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _leg(Color c, String t) => Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)), const SizedBox(width: 5), Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white70))]));
}

// MODAL Z WYSZUKIWARKĄ (ZMODYFIKOWANY POD IKONY/OBRAZKI)
class _AssetSelectionModal extends StatefulWidget {
  final List<Map<String, dynamic>> database;
  final Function(Map<String, dynamic>) onSelected;
  const _AssetSelectionModal({required this.database, required this.onSelected});
  @override State<_AssetSelectionModal> createState() => _AssetSelectionModalState();
}

class _AssetSelectionModalState extends State<_AssetSelectionModal> {
  String _q = "";
  @override Widget build(BuildContext context) {
    final list = widget.database.where((e) => e['name'].toString().toLowerCase().contains(_q.toLowerCase()) || e['symbol'].toString().toLowerCase().contains(_q.toLowerCase())).toList();
    return Container(
      height: 600,
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        const Text("Wybierz Aktywo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 20),
        TextField(
          onChanged: (v) => setState(() => _q = v),
          decoration: InputDecoration(hintText: "Szukaj (np. Bitcoin, Złoto...)", prefixIcon: const Icon(Icons.search, color: Colors.white54), filled: true, fillColor: Colors.white10, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
        ),
        const SizedBox(height: 10),
        Expanded(child: ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_,__) => const Divider(color: Colors.white10),
          itemBuilder: (ctx, i) {
            final item = list[i];
            return ListTile(
              // Logika wyświetlania: Obrazek dla Krypto, Ikona dla reszty
              leading: item.containsKey('image') 
                  ? CircleAvatar(backgroundColor: Colors.transparent, backgroundImage: NetworkImage(item['image']))
                  : Icon(item['icon'], color: item['color']),
              title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item['type']),
              trailing: const Icon(Icons.chevron_right, color: Colors.white24),
              onTap: () => widget.onSelected(item),
            );
          }
        ))
      ]),
    );
  }
}
// =============================================================================
// 5. RELAKS (GRY - BEZ ZMIAN LOGIKI)
// =============================================================================

class RelaxationHub extends StatefulWidget {
  const RelaxationHub({super.key});
  @override State<RelaxationHub> createState() => _RelaxationHubState();
}

class _RelaxationHubState extends State<RelaxationHub> {
  int _view = 0;
  @override Widget build(BuildContext context) {
    if (_view == 1) { return _TTTGame(onBack: () => setState(() => _view = 0)); }
    if (_view == 2) { return _ClickerGame(onBack: () => setState(() => _view = 0)); }
    if (_view == 3) { return _ReflexGame(onBack: () => setState(() => _view = 0)); }
    if (_view == 4) { return _MemoryGame(onBack: () => setState(() => _view = 0)); }
    if (_view == 5) { return _CryptoJumpGame(onBack: () => setState(() => _view = 0)); }
    if (_view == 6) { return _CatchGame(onBack: () => setState(() => _view = 0)); }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30), 
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("STREFA", style: TextStyle(color: Colors.amber, letterSpacing: 6, fontWeight: FontWeight.w900)), 
            const Text("RELAKSU", style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, height: 0.9)), 
            const SizedBox(height: 50), 
            Expanded(child: GridView.count(
              crossAxisCount: 2, crossAxisSpacing: 20, mainAxisSpacing: 20, 
              children: [
                _tile("Tic Tac Toe", Icons.grid_3x3_rounded, Colors.blue, 1), 
                _tile("Clicker", Icons.touch_app_rounded, Colors.amber, 2), 
                _tile("Refleks", Icons.bolt_rounded, Colors.redAccent, 3),
                _tile("Memory", Icons.psychology_rounded, Colors.purpleAccent, 4),
                _tile("Crypto Jump", Icons.rocket_launch, Colors.greenAccent, 5),
                _tile("Catch Coin", Icons.savings_rounded, Colors.orangeAccent, 6),
              ],
            ))
          ]),
        )
      )
    );
  }
  Widget _tile(String t, IconData i, Color c, int id) => InkWell(onTap: () => setState(() => _view = id), child: Container(decoration: BoxDecoration(color: const Color(0xFF121212), borderRadius: BorderRadius.circular(32), border: Border.all(color: c.withOpacity(0.1))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, size: 60, color: c), const SizedBox(height: 10), Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),]),),);
}

// KLASY POMOCNICZE
class FlyingParticle {
  double x, y, speedX, speedY, opacity = 1.0; IconData icon; Color color;
  FlyingParticle(this.x, this.y) : speedX = (Random().nextDouble()-0.5)*10, speedY = (Random().nextDouble()-0.5)*10, icon = [Icons.attach_money, Icons.euro, Icons.currency_bitcoin, Icons.diamond, Icons.savings, Icons.trending_up].elementAt(Random().nextInt(6)), color = Colors.primaries[Random().nextInt(Colors.primaries.length)];
}

// 1. TIC TAC TOE
class _TTTGame extends StatefulWidget {
  final VoidCallback onBack; const _TTTGame({required this.onBack}); @override State<_TTTGame> createState() => _TTTGameState();
}
class _TTTGameState extends State<_TTTGame> {
  List<String> b = List.filled(9, ""); 
  int pScore = 0, bScore = 0;
  String w = "";
  int diff = 1; 
  bool playing = false;

  @override void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showGameInfo(context, "Kółko i Krzyżyk", "Klasyczna gra logiczna.\nWybierz poziom trudności i pokonaj bota.", () => setState(() => playing = true));
    });
  }

  void reset() { setState(() { b = List.filled(9, ""); w = ""; }); }
  void tap(int i) {
    if (b[i] == "" && w == "") {
      setState(() { b[i] = "X"; check(); });
      if (w == "") { Timer(const Duration(milliseconds: 400), botMove); }
    }
  }
  void botMove() {
    List<int> avail = [];
    for (int i = 0; i < 9; i++) { if (b[i] == "") avail.add(i); }
    if (avail.isNotEmpty) {
      int move = avail[Random().nextInt(avail.length)];
      if (diff == 2) move = getBestMove(b); 
      setState(() { b[move] = "O"; check(); });
    }
  }
  int getBestMove(List<String> board) {
    for (int i = 0; i < 9; i++) { if (board[i] == "") { board[i] = "O"; if (checkWin(board, "O")) { board[i] = ""; return i; } board[i] = ""; } }
    for (int i = 0; i < 9; i++) { if (board[i] == "") { board[i] = "X"; if (checkWin(board, "X")) { board[i] = ""; return i; } board[i] = ""; } }
    List<int> empty = [];
    for (int i = 0; i < 9; i++) { if (board[i] == "") empty.add(i); }
    return empty[Random().nextInt(empty.length)];
  }
  bool checkWin(List<String> board, String p) {
    var l = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]];
    for (var s in l) { if (board[s[0]] == p && board[s[1]] == p && board[s[2]] == p) return true; }
    return false;
  }
  void check() {
    if (checkWin(b, "X")) { setState(() { w = "X"; pScore++; }); }
    else if (checkWin(b, "O")) { setState(() { w = "O"; bScore++; }); }
    else if (!b.contains("")) { setState(() => w = "R"); }
  }

  @override Widget build(BuildContext context) {
    if (!playing) return const SizedBox(); 
    return Scaffold(
      appBar: AppBar(leading: const SizedBox(), title: const Text("Tic Tac Toe"), centerTitle: true),
      body: Stack(children: [
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [0,1,2].map((i) => Padding(padding: const EdgeInsets.all(4), child: ChoiceChip(label: Text(i==0?"Łatwy":i==1?"Średni":"Expert"), selected: diff==i, onSelected: (v)=>setState(()=>diff=i)))).toList()),
          const SizedBox(height: 20),
          Text("JA $pScore : $bScore BOT", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber)),
          const SizedBox(height: 40),
          Center(child: Container(width: 320, child: GridView.builder(shrinkWrap: true, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: 9, itemBuilder: (c,i) => GestureDetector(onTap: () => tap(i), child: Container(decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(15)), child: Center(child: Text(b[i], style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: b[i]=="X"?Colors.blue:Colors.red)))))))),
          const SizedBox(height: 30),
          SizedBox(width: 200, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white12, foregroundColor: Colors.white), onPressed: widget.onBack, child: const Text("ZAKOŃCZ GRĘ (X)"))),
        ]),
        if(w != "") Container(color: Colors.black87, child: buildGameOverScreen(scoreInfo: w=="R"?"REMIS":"WYGRAŁ $w", onRestart: reset, onExit: widget.onBack)),
      ]),
    );
  }
}

// 2. CLICKER
class _ClickerGame extends StatefulWidget {
  final VoidCallback onBack; const _ClickerGame({required this.onBack}); @override State<_ClickerGame> createState() => _ClickerState();
}
class _ClickerState extends State<_ClickerGame> {
  int count=0, time=10; List<int> rank=[0,0,0]; bool playing=false, active=false; Color bg=Colors.amber; Timer? t; List<FlyingParticle> parts=[];
  @override void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) => showGameInfo(context, "Clicker Pro", "10 sekund.\nKlikaj jak szalony!", start, warning: true)); 
    Timer.periodic(const Duration(milliseconds: 16), (t){ if(mounted && parts.isNotEmpty) setState((){ for(var p in parts){p.x+=p.speedX;p.y+=p.speedY;p.opacity-=0.02;} parts.removeWhere((p)=>p.opacity<=0); }); }); }
  void start() { setState((){ playing=true; active=true; count=0; time=10; parts.clear(); }); t=Timer.periodic(const Duration(seconds:1), (ti){ if(time==0){ti.cancel(); setState((){active=false; rank.add(count); rank.sort((a,b)=>b.compareTo(a)); if(rank.length>3)rank=rank.sublist(0,3);}); } else { if(mounted) setState(()=>time--); } }); }
  void tap() { if(active) { setState((){ count++; bg=Colors.primaries[Random().nextInt(Colors.primaries.length)]; 
    double angle = Random().nextDouble() * 2 * pi;
    double r = 130; 
    double startX = (MediaQuery.of(context).size.width/2) + r*cos(angle) - 15;
    double startY = (MediaQuery.of(context).size.height/2) + r*sin(angle) - 15;
    parts.add(FlyingParticle(startX, startY)); }); } }
  @override Widget build(BuildContext context) {
    if(!playing) return const SizedBox();
    return Scaffold(body: Stack(children: [
      InkWell(onTap: tap, child: AnimatedContainer(duration: const Duration(milliseconds: 50), color: bg.withOpacity(0.1), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text("$time s", style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold)), const SizedBox(height: 40),
        Container(width: 250, height: 250, decoration: BoxDecoration(color: bg, shape: BoxShape.circle, boxShadow: [BoxShadow(color: bg.withOpacity(0.5), blurRadius: 30)]), child: Center(child: Text("$count", style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w900, color: Colors.black)))),
      ])))),
      ...parts.map((p)=>Positioned(left: p.x, top: p.y, child: Opacity(opacity: p.opacity.clamp(0,1), child: Icon(p.icon, color: p.color, size: 30)))),
      Positioned(bottom: 40, left: 20, right: 20, child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)), child: Column(children: [const Text("RANKING", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)), const SizedBox(height: 10), Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [Text("🥇 ${rank[0]}"), Text("🥈 ${rank[1]}"), Text("🥉 ${rank[2]}")])]))),
      if(!active && playing) Container(color: Colors.black87, child: buildGameOverScreen(scoreInfo: "Wynik: $count", onRestart: start, onExit: widget.onBack)),
      Positioned(top: 40, right: 20, child: IconButton(icon: const Icon(Icons.close), onPressed: (){t?.cancel(); widget.onBack();}))
    ]));
  }
}

// 3. REFLEKS
class _ReflexGame extends StatefulWidget {
  final VoidCallback onBack; const _ReflexGame({required this.onBack}); @override State<_ReflexGame> createState() => _ReflexState();
}
class _ReflexState extends State<_ReflexGame> {
  String m=""; Color bg=Colors.black; Timer? t; bool playing=false; int lvl=1;
  List<Color> colors = [Colors.red, Colors.blue, Colors.purple, Colors.orange, Colors.pink, Colors.yellow];
  List<String> praises = ["FANTASTYCZNIE! 🔥", "MISTRZ! 🚀", "BŁYSKAWICA! ⚡", "IDEALNIE! ⭐", "NIESAMOWITE! 🤯"];
  
  @override void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) => showGameInfo(context, "Ruletka Refleksu", "Kliknij TYLKO gdy zobaczysz CZYSTY ZIELONY.\nKażdy błąd kończy grę.", start, warning: true)); }
  void start() { setState((){ playing=true; lvl=1; m=""; }); nextLevel(); }
  void nextLevel() {
    setState(() { bg = Colors.black; m = "POZIOM $lvl"; });
    Timer(const Duration(seconds: 1), () {
      t = Timer.periodic(Duration(milliseconds: (700 - (lvl*50)).clamp(200, 1000)), (ti) {
        if(!mounted) return;
        if(Random().nextDouble() < 0.25) {
          setState(() { bg = const Color(0xFF00C853); m = ""; }); 
        } else {
          setState(() { bg = colors[Random().nextInt(colors.length)]; m = Random().nextBool() ? ["🐸","🐢","🍀"][Random().nextInt(3)] : ""; });
        }
      });
    });
  }
  @override Widget build(BuildContext context) {
    if(!playing) return const SizedBox();
    return Scaffold(backgroundColor: bg, body: GestureDetector(onTap: (){
      t?.cancel();
      if(bg == const Color(0xFF00C853)) {
        int ms = (700-(lvl*50)).clamp(200,700);
        setState(() { lvl++; bg=Colors.black; });
        showDialog(context: context, barrierDismissible: false, builder: (c) {
          Future.delayed(const Duration(milliseconds: 1000), () { if(mounted && Navigator.canPop(c)) Navigator.of(c).pop(); });
          return AlertDialog(backgroundColor: Colors.transparent, content: Column(mainAxisSize: MainAxisSize.min, children:[
             Text(praises[Random().nextInt(praises.length)], style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
             Text("~${ms}ms", style: const TextStyle(color: Colors.white, fontSize: 20))
          ]));
        }).then((_) => nextLevel());
      } else {
        setState(() { bg=Colors.black; });
        showDialog(context: context, barrierDismissible: false, builder: (c)=>buildGameOverScreen(scoreInfo: "Dotarłeś do poziomu $lvl", onRestart: start, onExit: widget.onBack, title: "POMYŁKA!"));
      }
    }, child: Container(color: Colors.transparent, width: double.infinity, height: double.infinity, child: Center(child: Text(m, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold))))));
  }
}

// 4. MEMORY
class _MemoryGame extends StatefulWidget {
  final VoidCallback onBack; const _MemoryGame({required this.onBack}); @override State<_MemoryGame> createState() => _MemoryGameState();
}
class _MemoryGameState extends State<_MemoryGame> {
  List<IconData> all = [Icons.currency_bitcoin, Icons.currency_exchange, Icons.monetization_on, Icons.attach_money, Icons.euro, Icons.currency_pound];
  List<IconData> cards=[]; List<bool> f=[], s=[]; List<int> sel=[]; int score=0; bool playing=false;
  @override void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) => showGameInfo(context, "Memory", "Znajdź pary. Ułóż całość by zdobyć punkt.", start)); }
  void start() { List<IconData> p=[...all,...all]; p.shuffle(); setState((){ cards=p; f=List.filled(12,false); s=List.filled(12,false); sel=[]; playing=true; }); }
  void tap(int i) {
    if(sel.length<2 && !f[i] && !s[i]) {
      setState((){ f[i]=true; sel.add(i); });
      if(sel.length==2) {
        if(cards[sel[0]]==cards[sel[1]]) {
          setState((){ s[sel[0]]=true; s[sel[1]]=true; sel.clear(); });
          if(s.every((x)=>x)) { score++; Timer(const Duration(seconds:1), start); }
        } else { Timer(const Duration(seconds:1), (){ if(mounted) setState((){ f[sel[0]]=false; f[sel[1]]=false; sel.clear(); }); }); }
      }
    }
  }
  @override Widget build(BuildContext context) {
    if(!playing) return const SizedBox();
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("Punkty: $score")), leading: const SizedBox(), actions: [const SizedBox(width: 48)]),
      body: Column(children: [
        Expanded(child: GridView.builder(padding: const EdgeInsets.all(20), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: 12, itemBuilder: (c,i)=>GestureDetector(onTap:()=>tap(i), child:Container(decoration:BoxDecoration(color: (f[i]||s[i])?Colors.amber:Colors.black, borderRadius:BorderRadius.circular(10), border:Border.all(color:Colors.white24)), child:Center(child: (f[i]||s[i])?Icon(cards[i],size:40,color:Colors.black):const Icon(Icons.help_outline,color:Colors.white10)))))),
        Padding(padding: const EdgeInsets.only(bottom: 30), child: FloatingActionButton(backgroundColor: Colors.white10, onPressed: widget.onBack, child: const Icon(Icons.close, color: Colors.white)))
      ]),
    );
  }
}

// 5. CRYPTO JUMP
class _CryptoJumpGame extends StatefulWidget {
  final VoidCallback onBack; const _CryptoJumpGame({required this.onBack}); @override State<_CryptoJumpGame> createState() => _CryptoJumpGameState();
}
class _CryptoJumpGameState extends State<_CryptoJumpGame> {
  double pX=0.5, pY=0.5, vY=0.0, g=-0.002, jS=0.035; 
  List<Map<String, dynamic>> plats=[]; 
  List<Offset> stars=[];
  double scrY=0.0; int score=0; bool playing=false, go=false; Timer? t;

  @override void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) => showGameInfo(context, "Crypto Jump", "Skacz na zielone belki (💰).\nUważaj na pęknięte! 🚫\nSprężyny dają boost. 🚀\nPrzesuwaj palcem po ekranie.", start)); }
  void start() { 
    setState((){ playing=true; go=false; score=0; pX=0.5; pY=0.2; vY=jS; scrY=0.0; plats=[{'x':0.5, 'y':0.1, 'type':0}]; stars=List.generate(20, (i)=>Offset(Random().nextDouble(), Random().nextDouble())); for(int i=1;i<10;i++) genPlat(0.1+(i*0.2)); }); 
    t=Timer.periodic(const Duration(milliseconds:16), (tk){
      if(!mounted){tk.cancel();return;}
      setState((){
        vY+=g; pY+=vY;
        if(pY>0.5) { 
          double d=pY-0.5; pY=0.5; scrY+=d; score+=(d*1000).toInt();
          for(var p in plats) p['y']-=d;
          plats.removeWhere((p)=>p['y']<-0.1);
          while(plats.length<10) genPlat(plats.last['y']+0.2+Random().nextDouble()*0.1);
          for(int i=0;i<stars.length;i++) { stars[i]=Offset(stars[i].dx, stars[i].dy-d*0.2); if(stars[i].dy<0) stars[i]=Offset(Random().nextDouble(), 1.0); }
        }
        if(vY<0) {
          for(var p in plats) {
            if((pX-(p['x'] as num).toDouble()).abs()<0.15 && (pY-(p['y'] as num).toDouble()).abs()<0.05) {
              if(p['type']==2) { plats.remove(p); } 
              else { vY = p['type']==1 ? jS*2.5 : jS; } 
            }
          }
        }
        if(pY<-0.1) { tk.cancel(); setState(()=>go=true); }
      });
    });
  }
  void genPlat(double y) {
    int type = 0;
    if(score > 3000 && Random().nextDouble() < 0.1) type = 1; 
    if(score > 5000 && Random().nextDouble() < 0.1) type = 2; 
    plats.add({'x':Random().nextDouble(), 'y':y.toDouble(), 'type':type});
  }
  void move(double d) => pX=(pX+d).clamp(0.0,1.0);
  @override Widget build(BuildContext context) {
    if(!playing) return const SizedBox();
    return Scaffold(body: Stack(children: [
      Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black, Color(0xFF111122)]))),
      ...stars.map((s)=>Align(alignment: FractionalOffset(s.dx, s.dy), child: const Icon(Icons.star, color: Colors.white12, size: 4))),
      ...plats.map((p)=>Align(alignment: FractionalOffset((p['x'] as num).toDouble(), 1-(p['y'] as num).toDouble()), child: Column(mainAxisSize: MainAxisSize.min, children: [
        if(p['type']==1) const Icon(Icons.keyboard_double_arrow_up, size: 15, color: Colors.white),
        Container(width: 60, height: 10, decoration: BoxDecoration(color: p['type']==2 ? Colors.brown : Colors.green, borderRadius: BorderRadius.circular(5), border: p['type']==2 ? Border.all(color: Colors.black, width: 2) : null))
      ]))),
      Align(alignment: FractionalOffset(pX, 1-pY), child: const Icon(Icons.currency_bitcoin, color: Colors.orange, size: 40)),
      Row(children: [Expanded(child: GestureDetector(onTapDown:(_)=>move(-0.1), onPanUpdate:(d)=>move(d.delta.dx/200), child: Container(color:Colors.transparent))), Expanded(child: GestureDetector(onTapDown:(_)=>move(0.1), onPanUpdate:(d)=>move(d.delta.dx/200), child: Container(color:Colors.transparent)))]),
      Positioned(top: 50, width: MediaQuery.of(context).size.width, child: Center(child: Text("DYSTANS: ${score ~/ 100} m", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)))),
      if(go) Container(color: Colors.black87, child: buildGameOverScreen(scoreInfo: "Wynik: ${score ~/ 100} m", onRestart: start, onExit: widget.onBack)),
      Positioned(top: 40, right: 20, child: IconButton(icon: const Icon(Icons.close), onPressed: (){t?.cancel(); widget.onBack();}))
    ]));
  }
}

// 6. CATCH COIN
class _CatchGame extends StatefulWidget {
  final VoidCallback onBack; const _CatchGame({required this.onBack}); @override State<_CatchGame> createState() => _CatchGameState();
}
class _CatchGameState extends State<_CatchGame> {
  double x=0; List<Map<String, dynamic>> items=[]; int score=0, lives=3, lvl=1; Timer? t; bool p=false, go=false; double sp=0.015; Color pc=Colors.grey;
  @override void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) => showGameInfo(context, "Łap Okazję", "📉 Spadek = -1 życie 💔\nOpuszczenie monety = -1 życie.", start)); }
  void start() { setState((){ p=true; go=false; score=0; lives=3; lvl=1; sp=0.015; items.clear(); pc=Colors.grey; }); t=Timer.periodic(const Duration(milliseconds: 20), (tk){
    if(!mounted){tk.cancel();return;}
    setState((){
      if(Random().nextDouble() < (0.02+(lvl*0.005))) { items.add({'x':Random().nextDouble()*2-1, 'y':-1.2, 'bad':Random().nextDouble()<0.25, 'c':Colors.primaries[Random().nextInt(Colors.primaries.length)]}); }
      List<Map<String,dynamic>> rem=[];
      for(var i in items) {
        i['y']+=sp;
        if(i['y']>0.85 && i['y']<1.0 && (i['x']-x).abs()<0.3) {
          if(i['bad']) { lives--; pc=Colors.red; } else { score++; pc=i['c']; if(score%10==0){lvl++;sp+=0.002;} }
          Timer(const Duration(milliseconds: 150), ()=>setState(()=>pc=Colors.grey)); rem.add(i);
        } else if(i['y']>1.2) { if(!i['bad'])lives--; rem.add(i); }
      }
      items.removeWhere((e)=>rem.contains(e));
      if(lives<=0) { tk.cancel(); setState(()=>go=true); }
    });
  });}
  @override Widget build(BuildContext context) {
    if(!p) return const SizedBox();
    return Scaffold(body: Stack(children: [
      GestureDetector(onHorizontalDragUpdate: (d)=>setState(()=>x=(x+d.delta.dx/150).clamp(-1.0, 1.0)), child: Container(color: Colors.transparent, width: double.infinity, height: double.infinity)),
      ...items.map((i)=>Align(alignment: Alignment(i['x'], i['y']), child: Icon(i['bad']?Icons.trending_down:Icons.monetization_on, color: i['bad']?Colors.red:i['c'], size: 35))),
      Align(alignment: Alignment(x, 0.9), child: Container(width: 80, height: 15, decoration: BoxDecoration(color: pc, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: pc.withOpacity(0.5), blurRadius: 10)]))),
      Positioned(top: 60, left: 0, right: 0, child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (i)=>Icon(i<lives?Icons.favorite:Icons.heart_broken, color: Colors.red, size: 30))), const SizedBox(height: 10), Text("WYNIK: $score (LVL $lvl)", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))])),
      if(go) Container(color: Colors.black87, child: buildGameOverScreen(scoreInfo: "Wynik: $score", onRestart: start, onExit: widget.onBack)),
      Positioned(top: 40, right: 20, child: IconButton(icon: const Icon(Icons.close), onPressed: (){t?.cancel(); widget.onBack();}))
    ]));
  }
}