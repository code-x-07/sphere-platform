import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const UniSphereOS());
}

const Color kSlateBg = Color(0xFF0F172A);
const Color kSlateCard = Color(0xFF1E293B);
const Color kElectricBlue = Color(0xFF38BDF8);
const Color kSharpGreen = Color(0xFF34D399);
const Color kAlertRed = Color(0xFFFB7185);
const Color kGold = Color(0xFFFBBF24);
const Color kTextWhite = Colors.white;

enum VisibilityType { public, uniPrivate, streamPrivate }

class Event {
  final String id;
  final String title;
  final String collegeId;
  final VisibilityType visibility;
  final String? allowedStream;
  final String imageUrl;
  final DateTime dateTime;
  final String category;
  final String description;
  final String host;
  final int price;
  final int totalSeats;
  int attendees;
  final String masterKey;    
  final String operatorCode; 
  final bool hasConflict;
  final int prevAttendees; 
  final double prevRating; 
  final List<String> pastReviews; 
  
  Event({
    required this.id, required this.title, required this.collegeId, required this.visibility,
    this.allowedStream, required this.imageUrl, required this.dateTime,
    required this.category, required this.description, required this.host,
    required this.price, required this.totalSeats, required this.attendees,
    required this.masterKey, required this.operatorCode,
    this.hasConflict = false,
    this.prevAttendees = 0, this.prevRating = 0.0, this.pastReviews = const []
  });
}

List<Event> globalEvents = [
  Event(
    id: '1', title: "WAVES Opening Night", collegeId: 'bits', visibility: VisibilityType.public,
    imageUrl: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?q=80&w=800",
    dateTime: DateTime.now().add(const Duration(days: 2)), category: "Cultural",
    description: "The biggest cultural fest opening night with EDM stars.", host: "StuCCA", price: 499, 
    totalSeats: 5000, attendees: 4120, 
    masterKey: "1111-2222-3333", operatorCode: "SCAN-OASIS",
    hasConflict: false,
    prevAttendees: 4800, prevRating: 4.9, pastReviews: ["Insane energy!", "Best DJ lineup", "Crowded but worth it"]
  ),
  Event(
    id: '2', title: "Advanced AI Workshop", collegeId: 'bits', visibility: VisibilityType.streamPrivate,
    allowedStream: 'CS',
    imageUrl: "https://images.unsplash.com/photo-1555949963-ff9fe0c870eb?q=80&w=800",
    dateTime: DateTime.now().add(const Duration(hours: 5)), category: "Academic",
    description: "Deep dive into Transformer models.", host: "Dept of CS", price: 0, 
    totalSeats: 100, attendees: 45, 
    masterKey: "AI-2026", operatorCode: "SCAN-AI",
    hasConflict: true,
    prevAttendees: 85, prevRating: 4.7, pastReviews: ["Very informative", "Hard prerequisites", "Great food"]
  ),
  Event(
    id: '3', title: "Mood Indigo Concert", collegeId: 'iitb', visibility: VisibilityType.public,
    imageUrl: "https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?q=80&w=800",
    dateTime: DateTime.now().add(const Duration(days: 10)), category: "Music",
    description: "Asia's largest college cultural festival.", host: "IITB Gymkhana", price: 999, 
    totalSeats: 10000, attendees: 200, 
    masterKey: "MI-2026", operatorCode: "SCAN-MI",
    hasConflict: false,
    prevAttendees: 12000, prevRating: 4.8, pastReviews: ["Legendary night", "Huge crowd"]
  ),
  Event(
    id: '4', title: "Antardhvani Fest", collegeId: 'delhi', visibility: VisibilityType.public,
    imageUrl: "https://images.unsplash.com/photo-1514525253440-b393452e3383?q=80&w=800",
    dateTime: DateTime.now().add(const Duration(days: 15)), category: "Cultural",
    description: "The heartbeat of North Campus.", host: "DUSU", price: 0, 
    totalSeats: 8000, attendees: 500, 
    masterKey: "DU-2026", operatorCode: "SCAN-DU",
    hasConflict: false,
    prevAttendees: 6000, prevRating: 4.5, pastReviews: ["Great food stalls", "Vibrant atmosphere"]
  ),
];

class College {
  final String id, name, domain, logoUrl;
  College(this.id, this.name, this.domain, this.logoUrl);
}

final List<College> kUniversities = [
  College('bits', 'BITS Pilani', 'bits-pilani.ac.in', 'https://images.unsplash.com/photo-1562774053-701939374585?q=80&w=200'),
  College('iitb', 'IIT Bombay', 'iitb.ac.in', 'https://images.unsplash.com/photo-1592280771190-3e2e4d571952?q=80&w=200'),
  College('delhi', 'Delhi Univ', 'du.ac.in', 'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?q=80&w=200'),
];

class UniSphereOS extends StatelessWidget {
  const UniSphereOS({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: kSlateBg,
        primaryColor: kElectricBlue,
        cardColor: kSlateCard,
        textTheme: const TextTheme(bodyMedium: TextStyle(fontFamily: 'Roboto', color: kTextWhite)),
      ),
      home: const SplashScreen(), 
    );
  }
}

class LoginGateway extends StatefulWidget {
  const LoginGateway({super.key});
  @override
  State<LoginGateway> createState() => _LoginGatewayState();
}

class _LoginGatewayState extends State<LoginGateway> {
  final _nameCtrl = TextEditingController(text: "Hemant");
  final _emailCtrl = TextEditingController(text: "hemant@bits-pilani.ac.in");
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    final domain = _emailCtrl.text.split('@')[1];
    College userCollege = kUniversities.firstWhere((c) => c.domain == domain, orElse: () => kUniversities[0]);
    if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AcademicCalibration(name: _nameCtrl.text, userCollege: userCollege)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyBackground(
        child: Center(
          child: Container(
          width: 350, 
         padding: const EdgeInsets.all(30),
         decoration: const BoxDecoration(
          color: Colors.transparent, 
        ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.hub, size: 60, color: kElectricBlue),
                const SizedBox(height: 20),
                const Text("SPHERE", style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 4)),
                const SizedBox(height: 30),
                _input("Name", Icons.person, _nameCtrl),
                const SizedBox(height: 15),
                _input("Uni Email", Icons.email, _emailCtrl),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, 
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kElectricBlue, 
                      foregroundColor: Colors.black, 
                      padding: const EdgeInsets.symmetric(vertical: 18)
                    ), 
                    onPressed: _isLoading ? null : _handleLogin, 
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.black) 
                      : const Text("DISCOVER EVENTS")
                  )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _input(String l, IconData i, TextEditingController c) => TextField(
    controller: c, 
    style: const TextStyle(color: Colors.white), 
    decoration: InputDecoration(
      filled: true, 
      fillColor: kSlateBg.withOpacity(0.5), 
      labelText: l, 
      prefixIcon: Icon(i, color: Colors.grey), 
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))
    )
  );
}

class AcademicCalibration extends StatelessWidget {
  final String name;
  final College userCollege;
  const AcademicCalibration({super.key, required this.name, required this.userCollege});

  final List<String> _streams = const ["CS", "ECE", "EEE", "ENI", "MECH", "CHEM", "CIVIL", "PHARMA"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: kSlateBg, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginGateway())))),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome, $name", style: const TextStyle(color: kElectricBlue, fontSize: 16)),
            const Text("Select Major", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 1.2, crossAxisSpacing: 10, mainAxisSpacing: 10),
                itemCount: _streams.length,
                itemBuilder: (ctx, i) => GestureDetector(
                  onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => RoleSelector(name: name, college: userCollege, stream: _streams[i]))),
                  child: Container(decoration: BoxDecoration(color: kSlateCard, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white10)), child: Center(child: Text(_streams[i], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)))),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class RoleSelector extends StatelessWidget {
  final String name;
  final College college;
  final String stream;
  const RoleSelector({super.key, required this.name, required this.college, required this.stream});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Identity Verified.", style: const TextStyle(color: kSharpGreen, fontWeight: FontWeight.bold)),
            Text(name, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
            const SizedBox(height: 50),
            _roleCard(context, "STUDENT", "Browse events & tickets", Icons.explore, kElectricBlue, () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudentDashboard(name: name, college: college, stream: stream)))),
            _roleCard(context, "ADMIN", "Create & Manage events", Icons.admin_panel_settings, kSharpGreen, () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminChoicePage(college: college)))),
            _roleCard(context, "OPERATOR", "Scan tickets & Security", Icons.qr_code_scanner, kAlertRed, () => Navigator.push(context, MaterialPageRoute(builder: (_) => OperatorLogin()))),
          ],
        ),
      ),
    );
  }

  Widget _roleCard(BuildContext c, String t, String s, IconData i, Color col, VoidCallback tap) {
    return GestureDetector(
      onTap: tap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15), padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: kSlateCard, borderRadius: BorderRadius.circular(12), border: Border(left: BorderSide(color: col, width: 4))),
        child: Row(children: [Icon(i, color: col), const SizedBox(width: 20), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(s, style: const TextStyle(color: Colors.grey, fontSize: 12))]), const Spacer(), const Icon(Icons.arrow_forward, color: Colors.white24)]),
      ),
    );
  }
}

class AdminChoicePage extends StatelessWidget {
  final College college;
  const AdminChoicePage({super.key, required this.college});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Portal"), backgroundColor: kSlateBg),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _bigButton(context, "CREATE A NEW EVENT", "Generate a 12-digit key & setup", Icons.add_circle, kSharpGreen, 
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => CreateEventPage(college: college)))),
            const SizedBox(height: 30),
            _bigButton(context, "ACCESS AN EVENT", "Enter existing Master Key", Icons.vpn_key, kElectricBlue, 
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => AccessEventPage(college: college)))),
          ],
        ),
      ),
    );
  }

  Widget _bigButton(BuildContext context, String title, String sub, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(30),
        width: double.infinity,
        decoration: BoxDecoration(color: kSlateCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.5), width: 2)),
        child: Column(children: [Icon(icon, size: 50, color: color), const SizedBox(height: 15), Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)), Text(sub, style: const TextStyle(color: Colors.grey))]),
      ),
    );
  }
}

class CreateEventPage extends StatefulWidget {
  final College college;
  const CreateEventPage({super.key, required this.college});
  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _seatsCtrl = TextEditingController(text: "100");
  final _priceCtrl = TextEditingController(text: "0");
  final _streamCtrl = TextEditingController();
  final _opPassCtrl = TextEditingController(text: "OP-${math.Random().nextInt(9999)}");
  
  String _category = "Cultural";
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  late String _masterKey;

  @override
  void initState() {
    super.initState();
    var r = math.Random();
    _masterKey = "${r.nextInt(9000)+1000}-${r.nextInt(9000)+1000}-${r.nextInt(9000)+1000}";
  }

  VisibilityType _vis = VisibilityType.public;

  void _submit() {
    final dt = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute);
    final newEvent = Event(
      id: DateTime.now().toString(),
      title: _titleCtrl.text,
      collegeId: widget.college.id,
      visibility: _vis,
      allowedStream: _vis == VisibilityType.streamPrivate ? _streamCtrl.text : null,
      imageUrl: "https://images.unsplash.com/photo-1514525253440-b393452e3383?q=80&w=800",
      dateTime: dt,
      category: _category,
      description: _descCtrl.text,
      host: "Admin",
      price: int.tryParse(_priceCtrl.text) ?? 0,
      totalSeats: int.tryParse(_seatsCtrl.text) ?? 100,
      attendees: 0,
      masterKey: _masterKey,
      operatorCode: _opPassCtrl.text,
      prevAttendees: 120, 
      prevRating: 4.5,
      pastReviews: ["Great initiative!", "Well organized"]
    );
    globalEvents.add(newEvent);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminDashboard(event: newEvent)));
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
    if (d != null) setState(() => _selectedDate = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null) setState(() => _selectedTime = t);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create New Event"), backgroundColor: kSlateBg),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: kGold.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: kGold)),
              child: Row(children: [const Icon(Icons.vpn_key, color: kGold), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("MASTER KEY (AUTO-GENERATED)", style: TextStyle(color: kGold, fontSize: 10, fontWeight: FontWeight.bold)), Text(_masterKey, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2))]))]),
            ),
            const SizedBox(height: 20),
            _fieldLabel("Event Title *"), _textField(_titleCtrl, "Enter event title"),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_fieldLabel("Price (₹) *"), _textField(_priceCtrl, "0")])),
              const SizedBox(width: 15),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_fieldLabel("Seats *"), _textField(_seatsCtrl, "100")]))
            ]),
            const SizedBox(height: 10),
            _fieldLabel("Category *"),
            DropdownButtonFormField<String>(
              value: _category, dropdownColor: kSlateCard,
              items: ["Cultural", "Tech", "Academic", "Sports", "Music"].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _category = v!), decoration: _inputDeco(""),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_fieldLabel("Date *"), GestureDetector(onTap: _pickDate, child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: kSlateCard, borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.calendar_today, size: 16, color: Colors.grey), const SizedBox(width: 10), Text("${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}", style: const TextStyle(color: Colors.white))])))] )),
              const SizedBox(width: 15),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_fieldLabel("Time *"), GestureDetector(onTap: _pickTime, child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: kSlateCard, borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.access_time, size: 16, color: Colors.grey), const SizedBox(width: 10), Text(_selectedTime.format(context), style: const TextStyle(color: Colors.white))])))] )),
            ]),
            const SizedBox(height: 10),
            _fieldLabel("Description *"), TextField(controller: _descCtrl, maxLines: 4, style: const TextStyle(color: Colors.white), decoration: _inputDeco("Describe your event...")),
            const SizedBox(height: 20),
            _fieldLabel("Event Image"), Container(height: 150, width: double.infinity, decoration: BoxDecoration(color: kSlateCard.withOpacity(0.5), borderRadius: BorderRadius.circular(10), border: Border.all(color: kElectricBlue, style: BorderStyle.solid)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.image, size: 40, color: kElectricBlue), SizedBox(height: 10), Text("Upload a file or drag and drop", style: TextStyle(color: kElectricBlue)), Text("PNG, JPG up to 10MB", style: TextStyle(color: Colors.grey, fontSize: 10))])),
            const SizedBox(height: 20),
            const Divider(color: Colors.white24),
            _fieldLabel("Visibility"),
            DropdownButtonFormField<VisibilityType>(
              value: _vis, dropdownColor: kSlateCard,
              items: const [DropdownMenuItem(value: VisibilityType.public, child: Text("Public (All Colleges)")), DropdownMenuItem(value: VisibilityType.uniPrivate, child: Text("Private (My Uni Only)")), DropdownMenuItem(value: VisibilityType.streamPrivate, child: Text("Private (Branch Only)"))],
              onChanged: (v) => setState(() => _vis = v!), decoration: _inputDeco(""),
            ),
            if (_vis == VisibilityType.streamPrivate) ...[const SizedBox(height: 10), _fieldLabel("Allowed Stream"), _textField(_streamCtrl, "CS")],
            _fieldLabel("Operator Verification Password"), _textField(_opPassCtrl, "e.g. SCAN123"),
            const SizedBox(height: 30),
            SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: kSharpGreen, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16)), onPressed: _submit, child: const Text("PUBLISH EVENT")))
          ],
        ),
      ),
    );
  }
  Widget _fieldLabel(String t) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(t, style: const TextStyle(color: Colors.grey, fontSize: 12)));
  Widget _textField(TextEditingController c, String hint, {bool readOnly = false}) => TextField(controller: c, readOnly: readOnly, style: const TextStyle(color: Colors.white), decoration: _inputDeco(hint));
  InputDecoration _inputDeco(String hint) => InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.white24), filled: true, fillColor: kSlateCard, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none));
}

class AccessEventPage extends StatefulWidget {
  final College college;
  const AccessEventPage({super.key, required this.college});
  @override
  State<AccessEventPage> createState() => _AccessEventPageState();
}

class _AccessEventPageState extends State<AccessEventPage> {
  final _keyCtrl = TextEditingController();
  
  void _access() {
    try {
      final event = globalEvents.firstWhere((e) => e.masterKey == _keyCtrl.text);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminDashboard(event: event)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid Master Key"), backgroundColor: kAlertRed));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Access Event"), backgroundColor: kSlateBg),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Enter 12-Digit Master Key", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: _keyCtrl, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, letterSpacing: 2), decoration: InputDecoration(hintText: "XXXX-XXXX-XXXX", filled: true, fillColor: kSlateCard, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: kElectricBlue, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16)), onPressed: _access, child: const Text("ACCESS DASHBOARD")))
          ],
        ),
      ),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  final Event event;
  const AdminDashboard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event.title), backgroundColor: kSlateBg),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: kSlateCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: kGold.withOpacity(0.5))),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("MASTER KEY", style: TextStyle(color: kGold, fontSize: 10)), Text(event.masterKey, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
                IconButton(icon: const Icon(Icons.copy, color: Colors.grey), onPressed: () {})
              ]),
            ),
            const SizedBox(height: 20),
            Row(children: [Expanded(child: _statCard("Attendees", "${event.attendees}/${event.totalSeats}")), const SizedBox(width: 15), Expanded(child: _statCard("Operator Code", event.operatorCode))]),
            const SizedBox(height: 20),
            const Text("Live Occupancy", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: event.attendees/event.totalSeats, minHeight: 10, color: kSharpGreen, backgroundColor: Colors.black),
          ],
        ),
      ),
    );
  }
  Widget _statCard(String t, String v) => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: kSlateCard, borderRadius: BorderRadius.circular(12)), child: Column(children: [Text(t, style: const TextStyle(color: Colors.grey)), Text(v, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kElectricBlue))]));
}

class StudentDashboard extends StatefulWidget {
  final String name;
  final College college;
  final String stream;
  const StudentDashboard({super.key, required this.name, required this.college, required this.stream});
  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  late College _selectedCollege;
  @override 
  void initState() { super.initState(); _selectedCollege = widget.college; }

  @override
  Widget build(BuildContext context) {
    List<College> otherColleges = List.from(kUniversities)..removeWhere((c) => c.id == widget.college.id);
    
    final visibleEvents = globalEvents.where((e) {
      if (e.collegeId != _selectedCollege.id) return false; 
      if (_selectedCollege.id == widget.college.id) {
        if (e.visibility == VisibilityType.public) return true;
        if (e.visibility == VisibilityType.uniPrivate) return true;
        if (e.visibility == VisibilityType.streamPrivate) return e.allowedStream == widget.stream;
      } else {
        return e.visibility == VisibilityType.public;
      }
      return false;
    }).toList();

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 80, color: kSlateBg,
            child: Column(
              children: [
                const SizedBox(height: 50),
                IconButton(icon: const Icon(Icons.arrow_back, color: Colors.grey), onPressed: () => Navigator.pop(context)),
                const SizedBox(height: 20),
                _collegeIcon(widget.college, isMyCollege: true),
                const SizedBox(height: 20),
                Container(height: 1, width: 40, color: Colors.white10), 
                const SizedBox(height: 20),
                ...otherColleges.map((c) => _collegeIcon(c)).toList(),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                AppBar(
                  title: Row(children: const [Icon(Icons.circle, color: kGold, size: 14), SizedBox(width: 5), Text("50 Spheres", style: TextStyle(color: kGold, fontSize: 14))]),
                  backgroundColor: kSlateBg, elevation: 0, automaticallyImplyLeading: false,
                ),
                Expanded(
                  child: visibleEvents.isEmpty 
                  ? Center(child: Text("No events found for ${_selectedCollege.name}", style: const TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: visibleEvents.length,
                      itemBuilder: (ctx, i) => _heroEventCard(visibleEvents[i]),
                    ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _collegeIcon(College c, {bool isMyCollege = false}) {
    bool isSelected = _selectedCollege.id == c.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedCollege = c),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle, 
          border: isSelected ? Border.all(color: kElectricBlue, width: 2) : null,
          boxShadow: isSelected ? [BoxShadow(color: kElectricBlue.withOpacity(0.5), blurRadius: 10)] : []
        ),
        child: CircleAvatar(backgroundImage: NetworkImage(c.logoUrl), radius: 24),
      ),
    );
  }

  Widget _heroEventCard(Event e) {
    String price = e.price == 0 ? "FREE" : "₹${e.price}";
    String badge = e.visibility == VisibilityType.public ? "PUBLIC" : "PRIVATE";
    Color badgeCol = e.visibility == VisibilityType.public ? kSharpGreen : kAlertRed;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailsPage(event: e))),
      child: Container(
        height: 280,
        margin: const EdgeInsets.only(bottom: 25),
        decoration: BoxDecoration(color: kSlateCard, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))]),
        child: Stack(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(e.imageUrl, height: 280, width: double.infinity, fit: BoxFit.cover, color: Colors.black.withOpacity(0.4), colorBlendMode: BlendMode.darken)),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: badgeCol, borderRadius: BorderRadius.circular(8)), child: Text(badge, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10))),
                    const SizedBox(width: 8),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: kElectricBlue, borderRadius: BorderRadius.circular(8)), child: Text(e.category.toUpperCase(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10))),
                  ]),
                  const SizedBox(height: 10),
                  Text(e.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 5),
                  Row(children: [
                    Text("${e.dateTime.day}/${e.dateTime.month}/${e.dateTime.year}", style: const TextStyle(color: kSharpGreen, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 10),
                    const Icon(Icons.circle, size: 5, color: Colors.grey),
                    const SizedBox(width: 10),
                    Text(e.host, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  ]),
                  const SizedBox(height: 5),
                  Text(price, style: const TextStyle(color: kGold, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class EventDetailsPage extends StatelessWidget {
  final Event event;
  const EventDetailsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(top: 0, left: 0, right: 0, height: 400, child: Image.network(event.imageUrl, fit: BoxFit.cover)),
          Positioned(top: 0, left: 0, right: 0, height: 400, child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, kSlateBg])))),
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 320),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.1)),
                    const SizedBox(height: 10),
                    Row(children: [
                      const CircleAvatar(backgroundColor: kSlateCard, radius: 20, child: Icon(Icons.verified, color: kElectricBlue, size: 20)),
                      const SizedBox(width: 10),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Organized by", style: const TextStyle(color: Colors.grey, fontSize: 10)), Text(event.host, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))])
                    ]),
                    const SizedBox(height: 30),
                    
                    const Text("LEGACY INTELLIGENCE", style: TextStyle(color: kElectricBlue, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(child: _detailBox(Icons.groups, "${event.prevAttendees}+", "Attendees Last Year")),
                        const SizedBox(width: 10),
                        Expanded(child: _detailBox(Icons.star, "${event.prevRating}", "Avg Rating")),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: kSlateCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text("Past Feedback", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 5),
                        ...event.pastReviews.map((r) => Padding(padding: const EdgeInsets.only(top: 5), child: Row(children: [const Icon(Icons.format_quote, size: 12, color: kGold), const SizedBox(width: 5), Text(r, style: const TextStyle(fontStyle: FontStyle.italic))]))).toList()
                      ]),
                    ),
                    
                    const SizedBox(height: 30),
                    const Text("ABOUT", style: TextStyle(color: kElectricBlue, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                    const SizedBox(height: 10),
                    Text(event.description, style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.white70)),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
          Positioned(top: 50, left: 20, child: CircleAvatar(backgroundColor: Colors.black54, child: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)))),
          Positioned(bottom: 30, left: 20, right: 20, child: SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: kElectricBlue, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 18)), onPressed: (){}, child: const Text("GET TICKET"))))
        ],
      ),
    );
  }

  Widget _detailBox(IconData icon, String val, String label) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: kSlateCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
      child: Column(children: [Icon(icon, color: kElectricBlue), const SizedBox(height: 5), Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10))]),
    );
  }
}

class OperatorLogin extends StatelessWidget {
  OperatorLogin({super.key});
  final _codeCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Operator Access"), backgroundColor: kSlateBg),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Enter Operator Password", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            TextField(controller: _codeCtrl, decoration: InputDecoration(filled: true, fillColor: kSlateCard, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: kElectricBlue, padding: const EdgeInsets.symmetric(vertical: 15)), onPressed: () {
              try {
                final e = globalEvents.firstWhere((x) => x.operatorCode == _codeCtrl.text);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Scanning for: ${e.title}"), backgroundColor: kSharpGreen));
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid Code"), backgroundColor: kAlertRed));
              }
            }, child: const Text("LOGIN", style: TextStyle(color: Colors.black))))
          ],
        ),
      ),
    );
  }
}

class MyBackground extends StatelessWidget {
  final Widget child;
  const MyBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: kSlateBg, 
        image: DecorationImage(
          image: const AssetImage("assets/bg.jpg"), 
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.7), BlendMode.darken),
        ),
      ),
      child: child,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<Offset> _textSlide;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    Timer(const Duration(milliseconds: 3500), () {
      Navigator.pushReplacement(
        context, 
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginGateway(),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSlateBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _logoScale,
              child: Image.asset(
                "assets/logo.png", 
                width: 400, 
                height: 400,
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -140), 
              child: SlideTransition(
                position: _textSlide,
                child: FadeTransition(
                  opacity: _textOpacity,
                  child: Column(
                    children: [
                      const Text(
                        "SPHERE",
                        style: TextStyle(
                          color: kElectricBlue,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}