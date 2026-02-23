import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  runApp(const UniSphereOS());
}

const Color kSlateBg = Color(0xFF0F172A);
const Color kSlateCard = Color(0xFF1E293B);
const Color kElectricBlue = Color(0xFF38BDF8);
const Color kSharpGreen = Color(0xFF34D399);
const Color kAlertRed = Color(0xFFFB7185);
const Color kGold = Color(0xFFFBBF24);
const Color kPurple = Color(0xFFA78BFA);
const Color kTextWhite = Colors.white;

enum VisibilityType { public, uniPrivate, streamPrivate }
enum UserRole { student, admin, operator }

class Event {
  final String id, title, collegeId, imageUrl, category, description, host, masterKey, operatorCode;
  final VisibilityType visibility;
  final String? allowedStream;
  final DateTime dateTime;
  final int price, totalSeats, prevAttendees;
  int attendees;
  final double prevRating;
  final List<String> pastReviews;
  final bool hasConflict;

  Event({
    required this.id, required this.title, required this.collegeId, required this.visibility,
    this.allowedStream, required this.imageUrl, required this.dateTime, required this.category,
    required this.description, required this.host, required this.price, required this.totalSeats,
    required this.attendees, required this.masterKey, required this.operatorCode,
    this.hasConflict = false, this.prevAttendees = 0, this.prevRating = 0.0, this.pastReviews = const [],
  });
}

class Ticket {
  final String ticketId, eventId, eventTitle, eventDate, holderName;
  bool isScanned;
  Ticket({required this.ticketId, required this.eventId, required this.eventTitle, required this.eventDate, required this.holderName, this.isScanned = false});
  String get qrData => 'SPHERE:$ticketId:$eventId:$holderName';
}

class Room {
  final String id, name, building;
  final int capacity;
  final List<String> amenities;
  Room({required this.id, required this.name, required this.building, required this.capacity, required this.amenities});
}

class RoomBooking {
  final String bookingId, roomId, roomName, building, bookedBy, purpose;
  final DateTime date;
  final int startHour, endHour;
  RoomBooking({required this.bookingId, required this.roomId, required this.roomName, required this.building, required this.bookedBy, required this.date, required this.startHour, required this.endHour, required this.purpose});
}

class VolunteerApplication {
  final String id, eventId, eventTitle, applicantName, skills;
  String status;
  VolunteerApplication({required this.id, required this.eventId, required this.eventTitle, required this.applicantName, required this.skills, this.status = 'pending'});
}

class College {
  final String id, name, domain, logoUrl;
  College(this.id, this.name, this.domain, this.logoUrl);
}

// ─── GLOBAL STATE ─────────────────────────────────────────────────────────────

List<Ticket> globalTickets = [];
List<RoomBooking> globalRoomBookings = [];
List<VolunteerApplication> globalVolunteerApplications = [];

final List<Room> globalRooms = [
  Room(id: 'r1', name: 'LTC 101', building: 'LTC Block', capacity: 60, amenities: ['Projector', 'AC', 'Whiteboard']),
  Room(id: 'r2', name: 'LTC 201', building: 'LTC Block', capacity: 40, amenities: ['Projector', 'AC']),
  Room(id: 'r3', name: 'A-101', building: 'A Block', capacity: 30, amenities: ['Whiteboard', 'Fans']),
  Room(id: 'r4', name: 'A-201', building: 'A Block', capacity: 50, amenities: ['Projector', 'Fans']),
  Room(id: 'r5', name: 'Library Seminar', building: 'Library', capacity: 20, amenities: ['AC', 'Whiteboard']),
  Room(id: 'r6', name: 'NAB 001', building: 'NAB', capacity: 120, amenities: ['Projector', 'AC', 'Mic']),
];

final List<College> kUniversities = [
  College('bits', 'BITS Pilani', 'bits-pilani.ac.in', 'https://images.unsplash.com/photo-1562774053-701939374585?q=80&w=200'),
  College('iitb', 'IIT Bombay', 'iitb.ac.in', 'https://images.unsplash.com/photo-1592280771190-3e2e4d571952?q=80&w=200'),
  College('delhi', 'Delhi Univ', 'du.ac.in', 'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?q=80&w=200'),
];

List<Event> globalEvents = [
  Event(id: '1', title: "WAVES Opening Night", collegeId: 'bits', visibility: VisibilityType.public,
    imageUrl: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?q=80&w=800",
    dateTime: DateTime.now().add(const Duration(days: 2)), category: "Cultural",
    description: "The biggest cultural fest opening night with EDM stars.", host: "StuCCA",
    price: 499, totalSeats: 5000, attendees: 4120, masterKey: "1111-2222-3333", operatorCode: "SCAN-OASIS",
    prevAttendees: 4800, prevRating: 4.9, pastReviews: ["Insane energy!", "Best DJ lineup", "Crowded but worth it"]),
  Event(id: '2', title: "Advanced AI Workshop", collegeId: 'bits', visibility: VisibilityType.streamPrivate, allowedStream: 'CS',
    imageUrl: "https://images.unsplash.com/photo-1555949963-ff9fe0c870eb?q=80&w=800",
    dateTime: DateTime.now().add(const Duration(hours: 5)), category: "Academic",
    description: "Deep dive into Transformer models and LLM fine-tuning.", host: "Dept of CS",
    price: 0, totalSeats: 100, attendees: 45, masterKey: "AI-2026", operatorCode: "SCAN-AI", hasConflict: true,
    prevAttendees: 85, prevRating: 4.7, pastReviews: ["Very informative", "Hard prerequisites", "Great food"]),
  Event(id: '3', title: "Mood Indigo Concert", collegeId: 'iitb', visibility: VisibilityType.public,
    imageUrl: "https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?q=80&w=800",
    dateTime: DateTime.now().add(const Duration(days: 10)), category: "Music",
    description: "Asia's largest college cultural festival.", host: "IITB Gymkhana",
    price: 999, totalSeats: 10000, attendees: 200, masterKey: "MI-2026", operatorCode: "SCAN-MI",
    prevAttendees: 12000, prevRating: 4.8, pastReviews: ["Legendary night", "Huge crowd"]),
  Event(id: '4', title: "Antardhvani Fest", collegeId: 'delhi', visibility: VisibilityType.public,
    imageUrl: "https://images.unsplash.com/photo-1514525253440-b393452e3383?q=80&w=800",
    dateTime: DateTime.now().add(const Duration(days: 15)), category: "Cultural",
    description: "The heartbeat of North Campus.", host: "DUSU",
    price: 0, totalSeats: 8000, attendees: 500, masterKey: "DU-2026", operatorCode: "SCAN-DU",
    prevAttendees: 6000, prevRating: 4.5, pastReviews: ["Great food stalls", "Vibrant atmosphere"]),
];

// ─── APP ──────────────────────────────────────────────────────────────────────

class UniSphereOS extends StatelessWidget {
  const UniSphereOS({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: kSlateBg, primaryColor: kElectricBlue, cardColor: kSlateCard),
    home: const SplashScreen(),
  );
}

// ─── SPLASH ───────────────────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _scale, _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _scale = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _c, curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack)));
    _slide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(CurvedAnimation(parent: _c, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)));
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _c, curve: const Interval(0.5, 1.0, curve: Curves.easeIn)));
    _c.forward();
    Timer(const Duration(milliseconds: 3500), () {
      if (mounted) Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, __, ___) => const LoginGateway(), transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c), transitionDuration: const Duration(milliseconds: 800)));
    });
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kSlateBg,
    body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      ScaleTransition(scale: _scale, child: const Icon(Icons.hub, size: 120, color: kElectricBlue)),
      Transform.translate(offset: const Offset(0, 20), child: SlideTransition(position: _slide, child: FadeTransition(opacity: _opacity, child: const Text("SPHERE", style: TextStyle(color: kElectricBlue, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 6))))),
    ])),
  );
}

// ─── LOGIN ────────────────────────────────────────────────────────────────────

class LoginGateway extends StatefulWidget {
  const LoginGateway({super.key});
  @override
  State<LoginGateway> createState() => _LoginGatewayState();
}

class _LoginGatewayState extends State<LoginGateway> {
  final _nameCtrl = TextEditingController(text: "Athish");
  final _emailCtrl = TextEditingController(text: "athish@bits-pilani.ac.in");
  UserRole _role = UserRole.student;
  bool _loading = false;

  Color get _roleColor => _role == UserRole.student ? kElectricBlue : _role == UserRole.admin ? kSharpGreen : kAlertRed;

  void _login() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    final domain = _emailCtrl.text.contains('@') ? _emailCtrl.text.split('@')[1] : '';
    final college = kUniversities.firstWhere((c) => c.domain == domain, orElse: () => kUniversities[0]);
    if (_role == UserRole.operator) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OperatorLogin()));
    } else if (_role == UserRole.admin) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminChoicePage(college: college)));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AcademicCalibration(name: _nameCtrl.text, userCollege: college)));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: MyBackground(child: Center(child: Container(
      width: 380, padding: const EdgeInsets.all(30),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.hub, size: 60, color: kElectricBlue),
        const SizedBox(height: 20),
        const Text("SPHERE", style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 4)),
        const Text("University Event Platform", style: TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 30),
        _inp("Name", Icons.person, _nameCtrl),
        const SizedBox(height: 15),
        _inp("Uni Email", Icons.email, _emailCtrl),
        const SizedBox(height: 20),
        const Align(alignment: Alignment.centerLeft, child: Text("Login as", style: TextStyle(color: Colors.grey, fontSize: 12))),
        const SizedBox(height: 8),
        Row(children: [
          _chip("Student", Icons.explore, UserRole.student, kElectricBlue),
          const SizedBox(width: 8),
          _chip("Admin", Icons.admin_panel_settings, UserRole.admin, kSharpGreen),
          const SizedBox(width: 8),
          _chip("Operator", Icons.qr_code_scanner, UserRole.operator, kAlertRed),
        ]),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: _roleColor, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 18)),
          onPressed: _loading ? null : _login,
          child: _loading ? const CircularProgressIndicator(color: Colors.black) : Text("ENTER AS ${_role.name.toUpperCase()}"),
        )),
      ]),
    ))),
  );

  Widget _chip(String label, IconData icon, UserRole role, Color color) {
    final sel = _role == role;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _role = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: sel ? color.withOpacity(0.15) : kSlateCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: sel ? color : Colors.white10, width: 1.5)),
        child: Column(children: [Icon(icon, color: sel ? color : Colors.grey, size: 20), const SizedBox(height: 4), Text(label, style: TextStyle(color: sel ? color : Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))]),
      ),
    ));
  }

  Widget _inp(String l, IconData i, TextEditingController c) => TextField(controller: c, style: const TextStyle(color: Colors.white), decoration: InputDecoration(filled: true, fillColor: kSlateBg.withOpacity(0.5), labelText: l, prefixIcon: Icon(i, color: Colors.grey), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))));
}

// ─── ACADEMIC CALIBRATION ────────────────────────────────────────────────────

class AcademicCalibration extends StatelessWidget {
  final String name;
  final College userCollege;
  const AcademicCalibration({super.key, required this.name, required this.userCollege});
  final List<String> _streams = const ["CS", "ECE", "EEE", "ENI", "MECH", "CHEM", "CIVIL", "PHARMA"];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(backgroundColor: kSlateBg, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginGateway())))),
    body: Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Welcome, $name", style: const TextStyle(color: kElectricBlue, fontSize: 16)),
      const Text("Select Major", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
      const SizedBox(height: 20),
      Expanded(child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 1.2, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemCount: _streams.length,
        itemBuilder: (ctx, i) => GestureDetector(
          onTap: () => Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (_) => StudentDashboard(name: name, college: userCollege, stream: _streams[i]))),
          child: Container(decoration: BoxDecoration(color: kSlateCard, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white10)), child: Center(child: Text(_streams[i], style: const TextStyle(fontWeight: FontWeight.bold)))),
        ),
      )),
    ])),
  );
}

// ─── STUDENT DASHBOARD ────────────────────────────────────────────────────────

class StudentDashboard extends StatefulWidget {
  final String name; final College college; final String stream;
  const StudentDashboard({super.key, required this.name, required this.college, required this.stream});
  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  late College _sel;
  int _tab = 0;
  String _search = '';
  String _cat = 'All';

  @override
  void initState() { super.initState(); _sel = widget.college; }

  @override
  Widget build(BuildContext context) {
    final others = List.from(kUniversities)..removeWhere((c) => c.id == widget.college.id);
    final events = globalEvents.where((e) {
      if (e.collegeId != _sel.id) return false;
      bool ok = false;
      if (_sel.id == widget.college.id) {
        if (e.visibility == VisibilityType.public) ok = true;
        if (e.visibility == VisibilityType.uniPrivate) ok = true;
        if (e.visibility == VisibilityType.streamPrivate) ok = e.allowedStream == widget.stream;
      } else { ok = e.visibility == VisibilityType.public; }
      if (!ok) return false;
      if (_cat != 'All' && e.category != _cat) return false;
      if (_search.isNotEmpty && !e.title.toLowerCase().contains(_search.toLowerCase())) return false;
      return true;
    }).toList();
    final myTickets = globalTickets.where((t) => t.holderName == widget.name).toList();

    return Scaffold(body: Row(children: [
      // Sidebar
      Container(width: 80, color: kSlateBg, child: Column(children: [
        const SizedBox(height: 50),
        IconButton(icon: const Icon(Icons.arrow_back, color: Colors.grey), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginGateway()))),
        const SizedBox(height: 20),
        _colIcon(widget.college, isMe: true),
        const SizedBox(height: 20),
        Container(height: 1, width: 40, color: Colors.white10),
        const SizedBox(height: 20),
        ...others.cast<College>().map(_colIcon),
      ])),
      // Main
      Expanded(child: Column(children: [
        // Top bar
        Container(color: kSlateBg, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Row(children: [
          const Icon(Icons.circle, color: kGold, size: 14), const SizedBox(width: 5),
          const Text("50 Spheres", style: TextStyle(color: kGold, fontSize: 14)),
          const Spacer(),
          _tabBtn(Icons.explore, "Events", 0),
          const SizedBox(width: 8),
          _tabBtn(Icons.wallet, myTickets.isNotEmpty ? "Wallet (${myTickets.length})" : "Wallet", 1),
          const SizedBox(width: 8),
          _tabBtn(Icons.meeting_room, "Rooms", 2),
        ])),
        // Search bar (events only)
        if (_tab == 0) Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: Row(children: [
          Expanded(child: TextField(onChanged: (v) => setState(() => _search = v), style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "Search events...", hintStyle: const TextStyle(color: Colors.white24), prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 18), filled: true, fillColor: kSlateCard, contentPadding: const EdgeInsets.symmetric(vertical: 10), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)))),
          const SizedBox(width: 10),
          DropdownButton<String>(value: _cat, dropdownColor: kSlateCard, underline: const SizedBox(), style: const TextStyle(color: Colors.white, fontSize: 13),
            items: ['All','Cultural','Tech','Academic','Sports','Music'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _cat = v!)),
        ])),
        if (_tab == 0) const SizedBox(height: 8),
        Expanded(child: _tab == 0
          ? (events.isEmpty ? const Center(child: Text("No events found", style: TextStyle(color: Colors.grey))) : ListView.builder(padding: const EdgeInsets.all(16), itemCount: events.length, itemBuilder: (ctx, i) => _eventCard(events[i])))
          : _tab == 1 ? WalletTab(name: widget.name)
          : RoomBookingPage(userName: widget.name)),
      ])),
    ]));
  }

  Widget _tabBtn(IconData icon, String label, int idx) {
    final active = _tab == idx;
    return GestureDetector(onTap: () => setState(() => _tab = idx), child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: active ? kElectricBlue : kSlateCard, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [Icon(icon, size: 14, color: active ? Colors.black : Colors.white), const SizedBox(width: 5), Text(label, style: TextStyle(fontSize: 12, color: active ? Colors.black : Colors.white, fontWeight: FontWeight.bold))]),
    ));
  }

  Widget _colIcon(College c, {bool isMe = false}) {
    final sel = _sel.id == c.id;
    return GestureDetector(onTap: () => setState(() { _sel = c; _tab = 0; }), child: Container(
      margin: const EdgeInsets.only(bottom: 15), padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(shape: BoxShape.circle, border: sel ? Border.all(color: kElectricBlue, width: 2) : null, boxShadow: sel ? [BoxShadow(color: kElectricBlue.withOpacity(0.5), blurRadius: 10)] : []),
      child: CircleAvatar(backgroundImage: NetworkImage(c.logoUrl), radius: 24),
    ));
  }

  Widget _eventCard(Event e) {
    final price = e.price == 0 ? "FREE" : "₹${e.price}";
    final badge = e.visibility == VisibilityType.public ? "PUBLIC" : "PRIVATE";
    final badgeCol = e.visibility == VisibilityType.public ? kSharpGreen : kAlertRed;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailsPage(event: e, userName: widget.name))).then((_) => setState(() {})),
      child: Container(height: 280, margin: const EdgeInsets.only(bottom: 25), decoration: BoxDecoration(color: kSlateCard, borderRadius: BorderRadius.circular(20)), child: Stack(children: [
        ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(e.imageUrl, height: 280, width: double.infinity, fit: BoxFit.cover, color: Colors.black.withOpacity(0.4), colorBlendMode: BlendMode.darken)),
        if (e.hasConflict) Positioned(top: 15, right: 15, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(8)), child: const Row(children: [Icon(Icons.warning, size: 12, color: Colors.black), SizedBox(width: 4), Text("TIME CONFLICT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10))]))),
        Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: badgeCol, borderRadius: BorderRadius.circular(8)), child: Text(badge, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10))),
            const SizedBox(width: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: kElectricBlue, borderRadius: BorderRadius.circular(8)), child: Text(e.category.toUpperCase(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10))),
          ]),
          const SizedBox(height: 10),
          Text(e.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 5),
          Row(children: [Text("${e.dateTime.day}/${e.dateTime.month}/${e.dateTime.year}", style: const TextStyle(color: kSharpGreen, fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(width: 10), const Icon(Icons.circle, size: 5, color: Colors.grey), const SizedBox(width: 10), Text(e.host, style: const TextStyle(color: Colors.white70, fontSize: 14))]),
          const SizedBox(height: 5),
          Text(price, style: const TextStyle(color: kGold, fontWeight: FontWeight.bold)),
        ])),
      ])),
    );
  }
}

// ─── WALLET ───────────────────────────────────────────────────────────────────

class WalletTab extends StatelessWidget {
  final String name;
  const WalletTab({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final tickets = globalTickets.where((t) => t.holderName == name).toList();
    if (tickets.isEmpty) return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.wallet, size: 60, color: Colors.white24), SizedBox(height: 15), Text("No tickets yet", style: TextStyle(color: Colors.grey, fontSize: 18)), SizedBox(height: 8), Text("Book an event to get started", style: TextStyle(color: Colors.white24, fontSize: 13))]));
    return ListView.builder(padding: const EdgeInsets.all(20), itemCount: tickets.length, itemBuilder: (ctx, i) {
      final t = tickets[i];
      return GestureDetector(
        onTap: () => showDialog(context: ctx, builder: (_) => _QRDialog(ticket: t)),
        child: Container(margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: kSlateCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: t.isScanned ? kAlertRed.withOpacity(0.5) : kElectricBlue.withOpacity(0.3))), child: Column(children: [
          Padding(padding: const EdgeInsets.all(16), child: Row(children: [
            Container(width: 50, height: 50, decoration: BoxDecoration(color: kElectricBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.confirmation_number, color: kElectricBlue)),
            const SizedBox(width: 15),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t.eventTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(t.eventDate, style: const TextStyle(color: Colors.grey, fontSize: 12))])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: (t.isScanned ? kAlertRed : kSharpGreen).withOpacity(0.2), borderRadius: BorderRadius.circular(6)), child: Text(t.isScanned ? "USED" : "VALID", style: TextStyle(color: t.isScanned ? kAlertRed : kSharpGreen, fontSize: 10, fontWeight: FontWeight.bold))),
          ])),
          const Divider(color: Colors.white10, height: 1),
          const Padding(padding: EdgeInsets.all(12), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.qr_code, size: 14, color: Colors.grey), SizedBox(width: 5), Text("Tap to show QR code", style: TextStyle(color: Colors.grey, fontSize: 12))])),
        ])),
      );
    });
  }
}

class _QRDialog extends StatelessWidget {
  final Ticket ticket;
  const _QRDialog({required this.ticket});
  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: kSlateCard, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(ticket.eventTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
      const SizedBox(height: 5), Text(ticket.eventDate, style: const TextStyle(color: Colors.grey)),
      const SizedBox(height: 25),
      Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: QrImageView(data: ticket.qrData, version: QrVersions.auto, size: 200)),
      const SizedBox(height: 20),
      Text("ID: ${ticket.ticketId}", style: const TextStyle(color: Colors.grey, fontSize: 11, letterSpacing: 1)),
      const SizedBox(height: 5), Text(ticket.holderName, style: const TextStyle(color: kElectricBlue, fontWeight: FontWeight.bold)),
      const SizedBox(height: 20),
      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: (ticket.isScanned ? kAlertRed : kSharpGreen).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(ticket.isScanned ? Icons.block : Icons.check_circle, color: ticket.isScanned ? kAlertRed : kSharpGreen, size: 16), const SizedBox(width: 8), Text(ticket.isScanned ? "This ticket has been used" : "Valid — show this at the door", style: TextStyle(color: ticket.isScanned ? kAlertRed : kSharpGreen))])),
      const SizedBox(height: 15), TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
    ])),
  );
}

// ─── ROOM BOOKING ─────────────────────────────────────────────────────────────

class RoomBookingPage extends StatefulWidget {
  final String userName;
  const RoomBookingPage({super.key, required this.userName});
  @override
  State<RoomBookingPage> createState() => _RoomBookingPageState();
}

class _RoomBookingPageState extends State<RoomBookingPage> {
  String _building = 'All';
  DateTime _date = DateTime.now();
  int? _hour;

  List<String> get _buildings => ['All', ...globalRooms.map((r) => r.building).toSet()];
  List<Room> get _rooms => _building == 'All' ? globalRooms : globalRooms.where((r) => r.building == _building).toList();

  bool _isBooked(Room room, int hour) => globalRoomBookings.any((b) => b.roomId == room.id && b.date.year == _date.year && b.date.month == _date.month && b.date.day == _date.day && hour >= b.startHour && hour < b.endHour);

  void _book(Room room) {
    if (_hour == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Select a time slot first"), backgroundColor: kGold)); return; }
    if (_isBooked(room, _hour!)) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Slot already booked"), backgroundColor: kAlertRed)); return; }
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: kSlateCard, title: Text("Book ${room.name}"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text("${_date.day}/${_date.month}/${_date.year} at $_hour:00–${_hour! + 1}:00", style: const TextStyle(color: kElectricBlue)),
        const SizedBox(height: 15),
        TextField(controller: ctrl, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "Purpose of booking...", hintStyle: const TextStyle(color: Colors.white24), filled: true, fillColor: kSlateBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: kSharpGreen, foregroundColor: Colors.black), onPressed: () {
          setState(() => globalRoomBookings.add(RoomBooking(bookingId: 'BK-${math.Random().nextInt(90000)+10000}', roomId: room.id, roomName: room.name, building: room.building, bookedBy: widget.userName, date: _date, startHour: _hour!, endHour: _hour! + 1, purpose: ctrl.text.isEmpty ? "General use" : ctrl.text)));
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${room.name} booked for $_hour:00!"), backgroundColor: kSharpGreen));
        }, child: const Text("Confirm")),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Room Booking", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const Text("Reserve campus spaces", style: TextStyle(color: Colors.grey, fontSize: 13)),
      const SizedBox(height: 16),
      // Date picker
      GestureDetector(onTap: () async { final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 30))); if (d != null) setState(() => _date = d); }, child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: kSlateCard, borderRadius: BorderRadius.circular(10)), child: Row(children: [const Icon(Icons.calendar_today, color: kElectricBlue, size: 18), const SizedBox(width: 10), Text("${_date.day}/${_date.month}/${_date.year}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const Spacer(), const Text("Tap to change", style: TextStyle(color: Colors.grey, fontSize: 12))]))),
      const SizedBox(height: 12),
      // Time slots
      const Text("Select Time Slot", style: TextStyle(color: Colors.grey, fontSize: 12)),
      const SizedBox(height: 8),
      SizedBox(height: 50, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: 14, itemBuilder: (_, i) {
        final h = 7 + i; final sel = _hour == h;
        return GestureDetector(onTap: () => setState(() => _hour = h), child: AnimatedContainer(duration: const Duration(milliseconds: 150), margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: sel ? kElectricBlue : kSlateCard, borderRadius: BorderRadius.circular(10)), child: Text("$h:00", style: TextStyle(color: sel ? Colors.black : Colors.white, fontWeight: FontWeight.bold))));
      })),
      const SizedBox(height: 16),
      // Building filter
      SizedBox(height: 36, child: ListView(scrollDirection: Axis.horizontal, children: _buildings.map((b) => GestureDetector(onTap: () => setState(() => _building = b), child: Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: _building == b ? kPurple : kSlateCard, borderRadius: BorderRadius.circular(20)), child: Text(b, style: TextStyle(color: _building == b ? Colors.black : Colors.white, fontSize: 12, fontWeight: FontWeight.bold))))).toList())),
      const SizedBox(height: 16),
      // Rooms
      ..._rooms.map((room) {
        final booked = _hour != null ? _isBooked(room, _hour!) : false;
        return GestureDetector(onTap: () => _book(room), child: Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: kSlateCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: booked ? kAlertRed.withOpacity(0.5) : kSharpGreen.withOpacity(0.4))), child: Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: (booked ? kAlertRed : kSharpGreen).withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.meeting_room, color: booked ? kAlertRed : kSharpGreen)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(room.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text(room.building, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Wrap(spacing: 4, children: room.amenities.map((a) => Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)), child: Text(a, style: const TextStyle(fontSize: 9, color: Colors.grey)))).toList()),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: (booked ? kAlertRed : kSharpGreen).withOpacity(0.2), borderRadius: BorderRadius.circular(6)), child: Text(booked ? "BOOKED" : "AVAILABLE", style: TextStyle(color: booked ? kAlertRed : kSharpGreen, fontSize: 10, fontWeight: FontWeight.bold))),
            const SizedBox(height: 4),
            Text("Cap: ${room.capacity}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ]),
        ])));
      }),
      // My bookings
      if (globalRoomBookings.any((b) => b.bookedBy == widget.userName)) ...[
        const SizedBox(height: 20),
        const Text("My Bookings", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...globalRoomBookings.where((b) => b.bookedBy == widget.userName).map((b) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: kSlateCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: kPurple.withOpacity(0.3))), child: Row(children: [
          const Icon(Icons.bookmark, color: kPurple, size: 16), const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(b.roomName, style: const TextStyle(fontWeight: FontWeight.bold)), Text("${b.date.day}/${b.date.month} · ${b.startHour}:00–${b.endHour}:00 · ${b.purpose}", style: const TextStyle(color: Colors.grey, fontSize: 11))])),
          Text(b.bookingId, style: const TextStyle(color: Colors.white24, fontSize: 10)),
        ]))),
      ],
    ]));
  }
}

// ─── EVENT DETAILS ────────────────────────────────────────────────────────────

class EventDetailsPage extends StatefulWidget {
  final Event event; final String userName;
  const EventDetailsPage({super.key, required this.event, required this.userName});
  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  bool _showVolForm = false;
  final _skillsCtrl = TextEditingController();

  void _getTicket() {
    final has = globalTickets.any((t) => t.eventId == widget.event.id && t.holderName == widget.userName);
    if (has) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You already have a ticket!"), backgroundColor: kGold)); return; }
    final id = 'TKT-${math.Random().nextInt(90000)+10000}';
    final t = Ticket(ticketId: id, eventId: widget.event.id, eventTitle: widget.event.title, eventDate: "${widget.event.dateTime.day}/${widget.event.dateTime.month}/${widget.event.dateTime.year}", holderName: widget.userName);
    setState(() { globalTickets.add(t); widget.event.attendees++; });
    showDialog(context: context, builder: (_) => Dialog(backgroundColor: kSlateCard, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.check_circle, color: kSharpGreen, size: 60), const SizedBox(height: 15),
      const Text("Ticket Booked!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8), Text(widget.event.title, style: const TextStyle(color: Colors.grey)),
      const SizedBox(height: 25),
      Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: QrImageView(data: t.qrData, version: QrVersions.auto, size: 180)),
      const SizedBox(height: 15), Text("ID: $id", style: const TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1)),
      const SizedBox(height: 5), const Text("View in your Wallet anytime", style: TextStyle(color: kElectricBlue, fontSize: 13)),
      const SizedBox(height: 20), SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: kSharpGreen, foregroundColor: Colors.black), onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text("Done"))),
    ]))));
  }

  void _applyVol() {
    if (_skillsCtrl.text.isEmpty) return;
    final has = globalVolunteerApplications.any((a) => a.eventId == widget.event.id && a.applicantName == widget.userName);
    if (has) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Already applied!"), backgroundColor: kGold)); return; }
    setState(() {
      globalVolunteerApplications.add(VolunteerApplication(id: 'VOL-${math.Random().nextInt(90000)+10000}', eventId: widget.event.id, eventTitle: widget.event.title, applicantName: widget.userName, skills: _skillsCtrl.text));
      _showVolForm = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Application submitted! Status: Pending"), backgroundColor: kSharpGreen));
  }

  @override
  Widget build(BuildContext context) {
    final booked = globalTickets.any((t) => t.eventId == widget.event.id && t.holderName == widget.userName);
    final volApp = globalVolunteerApplications.where((a) => a.eventId == widget.event.id && a.applicantName == widget.userName).firstOrNull;

    return Scaffold(body: Stack(children: [
      Positioned(top: 0, left: 0, right: 0, height: 400, child: Image.network(widget.event.imageUrl, fit: BoxFit.cover)),
      Positioned(top: 0, left: 0, right: 0, height: 400, child: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, kSlateBg])))),
      Positioned.fill(child: SingleChildScrollView(padding: const EdgeInsets.only(top: 320), child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (widget.event.hasConflict) Container(margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: kGold.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: kGold.withOpacity(0.5))), child: const Row(children: [Icon(Icons.warning, color: kGold, size: 18), SizedBox(width: 10), Expanded(child: Text("This event overlaps with another event you may be attending.", style: TextStyle(color: kGold, fontSize: 13)))])),
        Text(widget.event.title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.1)),
        const SizedBox(height: 10),
        Row(children: [const CircleAvatar(backgroundColor: kSlateCard, radius: 20, child: Icon(Icons.verified, color: kElectricBlue, size: 20)), const SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Organized by", style: TextStyle(color: Colors.grey, fontSize: 10)), Text(widget.event.host, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))])]),
        const SizedBox(height: 30),
        const Text("LEGACY INTELLIGENCE", style: TextStyle(color: kElectricBlue, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
        const SizedBox(height: 15),
        Row(children: [Expanded(child: _box(Icons.groups, "${widget.event.prevAttendees}+", "Attendees Last Year")), const SizedBox(width: 10), Expanded(child: _box(Icons.star, "${widget.event.prevRating}", "Avg Rating"))]),
        const SizedBox(height: 15),
        Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: kSlateCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Past Feedback", style: TextStyle(color: Colors.grey, fontSize: 12)), const SizedBox(height: 5), ...widget.event.pastReviews.map((r) => Padding(padding: const EdgeInsets.only(top: 5), child: Row(children: [const Icon(Icons.format_quote, size: 12, color: kGold), const SizedBox(width: 5), Text(r, style: const TextStyle(fontStyle: FontStyle.italic))])))])),
        const SizedBox(height: 30),
        const Text("ABOUT", style: TextStyle(color: kElectricBlue, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
        const SizedBox(height: 10),
        Text(widget.event.description, style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.white70)),
        const SizedBox(height: 30),
        // Volunteer section
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: kSlateCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: kPurple.withOpacity(0.4))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Icon(Icons.volunteer_activism, color: kPurple, size: 18), const SizedBox(width: 8), const Text("Volunteer for this Event", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), const Spacer(),
            if (volApp != null) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: (volApp.status == 'accepted' ? kSharpGreen : volApp.status == 'rejected' ? kAlertRed : kGold).withOpacity(0.2), borderRadius: BorderRadius.circular(6)), child: Text(volApp.status.toUpperCase(), style: TextStyle(color: volApp.status == 'accepted' ? kSharpGreen : volApp.status == 'rejected' ? kAlertRed : kGold, fontSize: 10, fontWeight: FontWeight.bold))),
          ]),
          if (volApp == null) ...[
            const SizedBox(height: 8), const Text("Help organize, manage logistics, or assist at the event.", style: TextStyle(color: Colors.grey, fontSize: 12)), const SizedBox(height: 12),
            if (_showVolForm) ...[
              TextField(controller: _skillsCtrl, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "Your skills (e.g. logistics, design)...", hintStyle: const TextStyle(color: Colors.white24, fontSize: 12), filled: true, fillColor: kSlateBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)), maxLines: 2),
              const SizedBox(height: 10),
              Row(children: [TextButton(onPressed: () => setState(() => _showVolForm = false), child: const Text("Cancel")), const Spacer(), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: kPurple, foregroundColor: Colors.black), onPressed: _applyVol, child: const Text("Submit Application"))]),
            ] else
              SizedBox(width: double.infinity, child: OutlinedButton.icon(icon: const Icon(Icons.add, size: 16), label: const Text("Apply to Volunteer"), style: OutlinedButton.styleFrom(foregroundColor: kPurple, side: BorderSide(color: kPurple.withOpacity(0.5))), onPressed: () => setState(() => _showVolForm = true))),
          ] else ...[const SizedBox(height: 8), Text("Skills: ${volApp.skills}", style: const TextStyle(color: Colors.grey, fontSize: 12))],
        ])),
        const SizedBox(height: 100),
      ])))),
      Positioned(top: 50, left: 20, child: CircleAvatar(backgroundColor: Colors.black54, child: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)))),
      Positioned(bottom: 30, left: 20, right: 20, child: SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: booked ? Colors.grey.shade700 : kElectricBlue, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 18)), onPressed: booked ? null : _getTicket, child: Text(booked ? "✓ TICKET IN WALLET" : (widget.event.price == 0 ? "GET FREE TICKET" : "GET TICKET — ₹${widget.event.price}"))))),
    ]));
  }

  Widget _box(IconData icon, String val, String label) => Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: kSlateCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)), child: Column(children: [Icon(icon, color: kElectricBlue), const SizedBox(height: 5), Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10))]));
}

// ─── ADMIN ────────────────────────────────────────────────────────────────────

class AdminChoicePage extends StatelessWidget {
  final College college;
  const AdminChoicePage({super.key, required this.college});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Admin Portal"), backgroundColor: kSlateBg, leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginGateway())))),
    body: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      _btn(context, "CREATE A NEW EVENT", "Generate a 12-digit key & setup", Icons.add_circle, kSharpGreen, () => Navigator.push(context, MaterialPageRoute(builder: (_) => CreateEventPage(college: college)))),
      const SizedBox(height: 20),
      _btn(context, "ACCESS AN EVENT", "Enter existing Master Key", Icons.vpn_key, kElectricBlue, () => Navigator.push(context, MaterialPageRoute(builder: (_) => AccessEventPage(college: college)))),
      const SizedBox(height: 20),
      _btn(context, "VOLUNTEER MANAGEMENT", "Review & approve applications", Icons.volunteer_activism, kPurple, () => Navigator.push(context, MaterialPageRoute(builder: (_) => VolunteerManagementPage(college: college)))),
    ])),
  );

  Widget _btn(BuildContext ctx, String title, String sub, IconData icon, Color color, VoidCallback onTap) => GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(24), width: double.infinity, decoration: BoxDecoration(color: kSlateCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.5), width: 2)), child: Column(children: [Icon(icon, size: 44, color: color), const SizedBox(height: 12), Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)), Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12))])));
}

class VolunteerManagementPage extends StatefulWidget {
  final College college;
  const VolunteerManagementPage({super.key, required this.college});
  @override
  State<VolunteerManagementPage> createState() => _VolunteerManagementPageState();
}

class _VolunteerManagementPageState extends State<VolunteerManagementPage> {
  @override
  Widget build(BuildContext context) {
    final ids = globalEvents.where((e) => e.collegeId == widget.college.id).map((e) => e.id).toSet();
    final apps = globalVolunteerApplications.where((a) => ids.contains(a.eventId)).toList();
    return Scaffold(
      appBar: AppBar(title: const Text("Volunteer Applications"), backgroundColor: kSlateBg),
      body: apps.isEmpty ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.people_outline, size: 60, color: Colors.white24), SizedBox(height: 15), Text("No applications yet", style: TextStyle(color: Colors.grey, fontSize: 18))]))
      : ListView.builder(padding: const EdgeInsets.all(16), itemCount: apps.length, itemBuilder: (_, i) {
        final app = apps[i];
        return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: kSlateCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: (app.status == 'accepted' ? kSharpGreen : app.status == 'rejected' ? kAlertRed : kPurple).withOpacity(0.4))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Icon(Icons.person, color: kPurple, size: 16), const SizedBox(width: 8), Text(app.applicantName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: (app.status == 'accepted' ? kSharpGreen : app.status == 'rejected' ? kAlertRed : kGold).withOpacity(0.2), borderRadius: BorderRadius.circular(6)), child: Text(app.status.toUpperCase(), style: TextStyle(color: app.status == 'accepted' ? kSharpGreen : app.status == 'rejected' ? kAlertRed : kGold, fontSize: 10, fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 4),
          Text("Event: ${app.eventTitle}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text("Skills: ${app.skills}", style: const TextStyle(color: Colors.white70, fontSize: 13)),
          if (app.status == 'pending') ...[const SizedBox(height: 12), Row(children: [
            Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(foregroundColor: kAlertRed, side: BorderSide(color: kAlertRed.withOpacity(0.5))), onPressed: () => setState(() => app.status = 'rejected'), child: const Text("Reject"))),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: kSharpGreen, foregroundColor: Colors.black), onPressed: () => setState(() => app.status = 'accepted'), child: const Text("Accept"))),
          ])],
        ]));
      }),
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
  final _t = TextEditingController(), _d = TextEditingController(), _s = TextEditingController(text: "100"), _p = TextEditingController(text: "0"), _str = TextEditingController(), _op = TextEditingController(text: "OP-${math.Random().nextInt(9999)}");
  String _cat = "Cultural";
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  late String _key;
  VisibilityType _vis = VisibilityType.public;

  @override
  void initState() { super.initState(); final r = math.Random(); _key = "${r.nextInt(9000)+1000}-${r.nextInt(9000)+1000}-${r.nextInt(9000)+1000}"; }

  void _submit() {
    final dt = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
    final e = Event(id: DateTime.now().toString(), title: _t.text, collegeId: widget.college.id, visibility: _vis, allowedStream: _vis == VisibilityType.streamPrivate ? _str.text : null, imageUrl: "https://images.unsplash.com/photo-1514525253440-b393452e3383?q=80&w=800", dateTime: dt, category: _cat, description: _d.text, host: "Admin", price: int.tryParse(_p.text) ?? 0, totalSeats: int.tryParse(_s.text) ?? 100, attendees: 0, masterKey: _key, operatorCode: _op.text, prevAttendees: 120, prevRating: 4.5, pastReviews: ["Great initiative!", "Well organized"]);
    globalEvents.add(e);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminDashboard(event: e)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Create New Event"), backgroundColor: kSlateBg),
    body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: kGold.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: kGold)), child: Row(children: [const Icon(Icons.vpn_key, color: kGold), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("MASTER KEY", style: TextStyle(color: kGold, fontSize: 10, fontWeight: FontWeight.bold)), Text(_key, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2))]))])),
      const SizedBox(height: 20),
      _lbl("Event Title *"), _tf(_t, "Enter event title"),
      const SizedBox(height: 10),
      Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_lbl("Price (₹)"), _tf(_p, "0")])), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_lbl("Seats"), _tf(_s, "100")]))]),
      const SizedBox(height: 10),
      _lbl("Category"),
      DropdownButtonFormField<String>(value: _cat, dropdownColor: kSlateCard, items: ["Cultural","Tech","Academic","Sports","Music"].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => _cat = v!), decoration: _dec("")),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_lbl("Date"), GestureDetector(onTap: () async { final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030)); if (d != null) setState(() => _date = d); }, child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: kSlateCard, borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.calendar_today, size: 16, color: Colors.grey), const SizedBox(width: 10), Text("${_date.day}/${_date.month}/${_date.year}", style: const TextStyle(color: Colors.white))])))])),
        const SizedBox(width: 15),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_lbl("Time"), GestureDetector(onTap: () async { final t = await showTimePicker(context: context, initialTime: TimeOfDay.now()); if (t != null) setState(() => _time = t); }, child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: kSlateCard, borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.access_time, size: 16, color: Colors.grey), const SizedBox(width: 10), Text(_time.format(context), style: const TextStyle(color: Colors.white))])))])),
      ]),
      const SizedBox(height: 10),
      _lbl("Description"), TextField(controller: _d, maxLines: 4, style: const TextStyle(color: Colors.white), decoration: _dec("Describe your event...")),
      const SizedBox(height: 20), const Divider(color: Colors.white24),
      _lbl("Visibility"),
      DropdownButtonFormField<VisibilityType>(value: _vis, dropdownColor: kSlateCard, items: const [DropdownMenuItem(value: VisibilityType.public, child: Text("Public")), DropdownMenuItem(value: VisibilityType.uniPrivate, child: Text("Private (My Uni)")), DropdownMenuItem(value: VisibilityType.streamPrivate, child: Text("Private (Branch Only)"))], onChanged: (v) => setState(() => _vis = v!), decoration: _dec("")),
      if (_vis == VisibilityType.streamPrivate) ...[const SizedBox(height: 10), _lbl("Allowed Stream"), _tf(_str, "CS")],
      _lbl("Operator Password"), _tf(_op, "e.g. SCAN123"),
      const SizedBox(height: 30),
      SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: kSharpGreen, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16)), onPressed: _submit, child: const Text("PUBLISH EVENT"))),
    ])),
  );

  Widget _lbl(String t) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(t, style: const TextStyle(color: Colors.grey, fontSize: 12)));
  Widget _tf(TextEditingController c, String h) => TextField(controller: c, style: const TextStyle(color: Colors.white), decoration: _dec(h));
  InputDecoration _dec(String h) => InputDecoration(hintText: h, hintStyle: const TextStyle(color: Colors.white24), filled: true, fillColor: kSlateCard, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none));
}

class AccessEventPage extends StatefulWidget {
  final College college;
  const AccessEventPage({super.key, required this.college});
  @override
  State<AccessEventPage> createState() => _AccessEventPageState();
}

class _AccessEventPageState extends State<AccessEventPage> {
  final _k = TextEditingController();
  void _access() {
    try { final e = globalEvents.firstWhere((e) => e.masterKey == _k.text); Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminDashboard(event: e))); }
    catch (_) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid Master Key"), backgroundColor: kAlertRed)); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Access Event"), backgroundColor: kSlateBg),
    body: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text("Enter 12-Digit Master Key", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 20),
      TextField(controller: _k, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, letterSpacing: 2), decoration: InputDecoration(hintText: "XXXX-XXXX-XXXX", filled: true, fillColor: kSlateCard, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: kElectricBlue, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16)), onPressed: _access, child: const Text("ACCESS DASHBOARD"))),
    ])),
  );
}

class AdminDashboard extends StatelessWidget {
  final Event event;
  const AdminDashboard({super.key, required this.event});
  @override
  Widget build(BuildContext context) {
    final tickets = globalTickets.where((t) => t.eventId == event.id).toList();
    final apps = globalVolunteerApplications.where((a) => a.eventId == event.id).toList();
    return Scaffold(
      appBar: AppBar(title: Text(event.title), backgroundColor: kSlateBg),
      body: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: kSlateCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: kGold.withOpacity(0.5))), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("MASTER KEY", style: TextStyle(color: kGold, fontSize: 10)), Text(event.masterKey, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]), IconButton(icon: const Icon(Icons.copy, color: Colors.grey), onPressed: () {})])),
        const SizedBox(height: 20),
        Row(children: [Expanded(child: _stat("Tickets Sold", "${tickets.length}/${event.totalSeats}")), const SizedBox(width: 15), Expanded(child: _stat("Volunteers", "${apps.where((a) => a.status == 'accepted').length} accepted"))]),
        const SizedBox(height: 20),
        const Text("Live Occupancy", style: TextStyle(color: Colors.grey)), const SizedBox(height: 10),
        LinearProgressIndicator(value: event.totalSeats > 0 ? tickets.length / event.totalSeats : 0, minHeight: 10, color: kSharpGreen, backgroundColor: Colors.black),
        const SizedBox(height: 20),
        Text("Tickets (${tickets.length})", style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 8),
        Expanded(child: tickets.isEmpty ? const Center(child: Text("No tickets sold yet", style: TextStyle(color: Colors.white24))) : ListView.builder(itemCount: tickets.length, itemBuilder: (_, i) {
          final t = tickets[i];
          return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: kSlateCard, borderRadius: BorderRadius.circular(10)), child: Row(children: [const Icon(Icons.person, color: Colors.grey, size: 16), const SizedBox(width: 10), Text(t.holderName, style: const TextStyle(fontWeight: FontWeight.bold)), const Spacer(), Text(t.ticketId, style: const TextStyle(color: Colors.grey, fontSize: 11)), const SizedBox(width: 10), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: (t.isScanned ? kAlertRed : kSharpGreen).withOpacity(0.2), borderRadius: BorderRadius.circular(6)), child: Text(t.isScanned ? "USED" : "VALID", style: TextStyle(color: t.isScanned ? kAlertRed : kSharpGreen, fontSize: 10, fontWeight: FontWeight.bold)))]));
        })),
      ])),
    );
  }
  Widget _stat(String t, String v) => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: kSlateCard, borderRadius: BorderRadius.circular(12)), child: Column(children: [Text(t, style: const TextStyle(color: Colors.grey)), Text(v, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kElectricBlue), textAlign: TextAlign.center)]));
}

// ─── OPERATOR ─────────────────────────────────────────────────────────────────

class OperatorLogin extends StatefulWidget {
  const OperatorLogin({super.key});
  @override
  State<OperatorLogin> createState() => _OperatorLoginState();
}

class _OperatorLoginState extends State<OperatorLogin> {
  final _c = TextEditingController();
  void _login() {
    try { final e = globalEvents.firstWhere((x) => x.operatorCode == _c.text); Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OperatorScanPage(event: e))); }
    catch (_) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid Operator Code"), backgroundColor: kAlertRed)); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Operator Access"), backgroundColor: kSlateBg, leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginGateway())))),
    body: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.qr_code_scanner, size: 60, color: kAlertRed), const SizedBox(height: 20),
      const Text("Enter Operator Password", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const Text("Provided by your Event Head", style: TextStyle(color: Colors.grey, fontSize: 13)), const SizedBox(height: 20),
      TextField(controller: _c, style: const TextStyle(color: Colors.white, letterSpacing: 2), textAlign: TextAlign.center, decoration: InputDecoration(filled: true, fillColor: kSlateCard, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: kAlertRed, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)), onPressed: _login, child: const Text("ACCESS SCANNER", style: TextStyle(fontWeight: FontWeight.bold)))),
      const SizedBox(height: 30),
      const Text("Demo codes:", style: TextStyle(color: Colors.grey, fontSize: 12)),
      const SizedBox(height: 8),
      ...globalEvents.map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Text("${e.title}: ${e.operatorCode}", style: const TextStyle(color: Colors.white38, fontSize: 11)))),
    ])),
  );
}

class OperatorScanPage extends StatefulWidget {
  final Event event;
  const OperatorScanPage({super.key, required this.event});
  @override
  State<OperatorScanPage> createState() => _OperatorScanPageState();
}

class _OperatorScanPageState extends State<OperatorScanPage> {
  final _ctrl = TextEditingController();
  String? _result;
  bool? _valid;
  bool _flash = false;

  void _validate() {
    final input = _ctrl.text.trim();
    Ticket? found;
    try { found = globalTickets.firstWhere((t) => t.eventId == widget.event.id && (t.ticketId == input || t.qrData == input)); } catch (_) {}
    if (found == null) { setState(() { _result = "Ticket not found"; _valid = false; _flash = true; }); return; }
    if (found.isScanned) { setState(() { _result = "ALREADY USED\n${found!.holderName}"; _valid = false; _flash = true; }); return; }
    found.isScanned = true; widget.event.attendees++;
    setState(() { _result = "VALID ✓\n${found!.holderName}"; _valid = true; _flash = true; });
    _ctrl.clear();
    Future.delayed(const Duration(milliseconds: 2500), () { if (mounted) setState(() => _flash = false); });
  }

  @override
  Widget build(BuildContext context) {
    final scanned = globalTickets.where((t) => t.eventId == widget.event.id && t.isScanned).length;
    final total = globalTickets.where((t) => t.eventId == widget.event.id).length;
    return Scaffold(
      appBar: AppBar(title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.event.title, style: const TextStyle(fontSize: 16)), Text("$scanned / $total scanned", style: const TextStyle(fontSize: 12, color: Colors.grey))]), backgroundColor: kSlateBg),
      body: Stack(children: [
        Padding(padding: const EdgeInsets.all(24), child: Column(children: [
          // Viewfinder
          Container(height: 220, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20), border: Border.all(color: kAlertRed, width: 2)), child: Stack(children: [
            Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.qr_code_scanner, size: 80, color: Colors.white24), SizedBox(height: 10), Text("Point camera at ticket QR code", style: TextStyle(color: Colors.white38, fontSize: 12)), SizedBox(height: 4), Text("or use manual entry below", style: TextStyle(color: Colors.white24, fontSize: 11))])),
            Positioned(top: 20, left: 20, child: _corner()),
            Positioned(top: 20, right: 20, child: Transform.flip(flipX: true, child: _corner())),
            Positioned(bottom: 20, left: 20, child: Transform.flip(flipY: true, child: _corner())),
            Positioned(bottom: 20, right: 20, child: Transform.flip(flipX: true, flipY: true, child: _corner())),
          ])),
          const SizedBox(height: 24),
          const Text("MANUAL TICKET VALIDATION", style: TextStyle(color: Colors.grey, fontSize: 11, letterSpacing: 1)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: TextField(controller: _ctrl, style: const TextStyle(color: Colors.white, letterSpacing: 1), onSubmitted: (_) => _validate(), decoration: InputDecoration(hintText: "Enter Ticket ID (e.g. TKT-12345)", hintStyle: const TextStyle(color: Colors.white24), filled: true, fillColor: kSlateCard, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)))),
            const SizedBox(width: 10),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: kAlertRed, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20)), onPressed: _validate, child: const Text("CHECK")),
          ]),
          const SizedBox(height: 20),
          const Align(alignment: Alignment.centerLeft, child: Text("Recent Scans", style: TextStyle(color: Colors.grey, fontSize: 12))),
          const SizedBox(height: 8),
          Expanded(child: ListView(children: globalTickets.where((t) => t.eventId == widget.event.id && t.isScanned).map((t) => Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: kSlateCard, borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.check, color: kSharpGreen, size: 14), const SizedBox(width: 10), Text(t.holderName, style: const TextStyle(fontWeight: FontWeight.bold)), const Spacer(), Text(t.ticketId, style: const TextStyle(color: Colors.grey, fontSize: 11))]))).toList())),
        ])),
        // Fullscreen flash result
        if (_flash) GestureDetector(onTap: () => setState(() => _flash = false), child: Container(color: (_valid == true ? kSharpGreen : kAlertRed).withOpacity(0.92), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(_valid == true ? Icons.check_circle : Icons.cancel, size: 120, color: Colors.white), const SizedBox(height: 20), Text(_result ?? '', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center), const SizedBox(height: 30), const Text("Tap to dismiss", style: TextStyle(color: Colors.white54, fontSize: 14))])))),
      ]),
    );
  }

  Widget _corner() => SizedBox(width: 30, height: 30, child: CustomPaint(painter: _CornerPainter()));
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = kAlertRed..strokeWidth = 3..style = PaintingStyle.stroke;
    canvas.drawLine(Offset.zero, Offset(size.width, 0), p);
    canvas.drawLine(Offset.zero, Offset(0, size.height), p);
  }
  @override
  bool shouldRepaint(_) => false;
}

// ─── BACKGROUND ───────────────────────────────────────────────────────────────

class MyBackground extends StatelessWidget {
  final Widget child;
  const MyBackground({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, height: double.infinity,
    decoration: BoxDecoration(color: kSlateBg, image: DecorationImage(image: const AssetImage("assets/bg.jpg"), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.7), BlendMode.darken))),
    child: child,
  );
}
