import 'package:flutter/material.dart';

void main() => runApp(const Campus361App());

class Campus361App extends StatelessWidget {
  const Campus361App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campus 361',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const RootShell(),
    );
  }
}

/// ===================== ROOT with Bottom Navigation (Home · Map · SOS) =====================
class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const FacultyDirectoryScreen(),
      const MapScreen(),
      const SosScreen(),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.sos), label: 'SOS'),
        ],
      ),
    );
  }
}

/// ===================== DATA MODELS =====================
class Faculty {
  final String id;
  final String name;
  final String school;
  final String dept; // "Computer Science", "Electrical Engineering", "Mechanical Engineering", "Mathematics"
  const Faculty({required this.id, required this.name, required this.school, required this.dept});
}

class FacultySlot {
  final int weekday; // 1=Mon..5=Fri
  final TimeOfDay start;
  final TimeOfDay end;
  final String courseCode;
  final String courseTitle;
  final String room;
  /// Example: "CSE-A (Y1) • Sem 1", "EEE-B (Y3) • Sem 5", "MATH (Y2) • Sem 3"
  final String label;
  const FacultySlot({
    required this.weekday,
    required this.start,
    required this.end,
    required this.courseCode,
    required this.courseTitle,
    required this.room,
    required this.label,
  });
}

class TeachingNeed {
  /// The department that must teach this block (respects cross-dept teaching)
  final String requiredDept;
  /// The displayed label with batch/division + year + semester
  final String label;
  final List<String> codes;
  final List<String> titles;
  final List<String> rooms;
  const TeachingNeed({
    required this.requiredDept,
    required this.label,
    required this.codes,
    required this.titles,
    required this.rooms,
  });
}

/// build 3 fixed periods/day (Mon–Fri) for a need/faculty
List<FacultySlot> makeWeek(String label, List<String> codes, List<String> titles, List<String> rooms) {
  const times = [
    [9, 0, 10, 0],     // P1
    [10, 15, 11, 15],  // P2
    [11, 30, 12, 30],  // P3
  ];
  final out = <FacultySlot>[];
  for (int day = 1; day <= 5; day++) {
    for (int i = 0; i < 3; i++) {
      out.add(FacultySlot(
        weekday: day,
        start: TimeOfDay(hour: times[i][0], minute: times[i][1]),
        end: TimeOfDay(hour: times[i][2], minute: times[i][3]),
        courseCode: codes[i],
        courseTitle: titles[i],
        room: rooms[i],
        label: label,
      ));
    }
  }
  return out;
}

/// ===================== CONSTANTS =====================
const String sc = 'School of Computing';
const String se = 'School of Engineering';
const String ss = 'School of Science';

/// ===================== 5 FACULTY / DEPT =====================
final List<Faculty> kFaculty = [
  // CSE (5)
  Faculty(id: 'CSE101', name: 'Dr. Ananya Rao',     school: sc, dept: 'Computer Science'),
  Faculty(id: 'CSE102', name: 'Prof. Bharat Iyer',  school: sc, dept: 'Computer Science'),
  Faculty(id: 'CSE103', name: 'Dr. Charu Menon',    school: sc, dept: 'Computer Science'),
  Faculty(id: 'CSE104', name: 'Prof. Dev Patel',    school: sc, dept: 'Computer Science'),
  Faculty(id: 'CSE105', name: 'Dr. Esha Kurup',     school: sc, dept: 'Computer Science'),

  // EEE (5)
  Faculty(id: 'EEE201', name: 'Prof. Meera Thomas', school: se, dept: 'Electrical Engineering'),
  Faculty(id: 'EEE202', name: 'Dr. Nikhil Varma',   school: se, dept: 'Electrical Engineering'),
  Faculty(id: 'EEE203', name: 'Prof. Omana Raj',    school: se, dept: 'Electrical Engineering'),
  Faculty(id: 'EEE204', name: 'Dr. Pradeep Nair',   school: se, dept: 'Electrical Engineering'),
  Faculty(id: 'EEE205', name: 'Prof. Rekha Pillai', school: se, dept: 'Electrical Engineering'),

  // ME (5)
  Faculty(id: 'ME301', name: 'Dr. Aditya Menon',    school: se, dept: 'Mechanical Engineering'),
  Faculty(id: 'ME302', name: 'Prof. Bhavana Raj',   school: se, dept: 'Mechanical Engineering'),
  Faculty(id: 'ME303', name: 'Dr. Chetan Pillai',   school: se, dept: 'Mechanical Engineering'),
  Faculty(id: 'ME304', name: 'Prof. Divya Mathew',  school: se, dept: 'Mechanical Engineering'),
  Faculty(id: 'ME305', name: 'Dr. Ebin Varghese',   school: se, dept: 'Mechanical Engineering'),

  // Mathematics (5)
  Faculty(id: 'MATH401', name: 'Dr. Krishnan Nair',   school: ss, dept: 'Mathematics'),
  Faculty(id: 'MATH402', name: 'Prof. Lakshmi Menon', school: ss, dept: 'Mathematics'),
  Faculty(id: 'MATH403', name: 'Dr. Manoj Thomas',    school: ss, dept: 'Mathematics'),
  Faculty(id: 'MATH404', name: 'Prof. Neha Varghese', school: ss, dept: 'Mathematics'),
  Faculty(id: 'MATH405', name: 'Dr. Omprakash R.',    school: ss, dept: 'Mathematics'),
];

/// ===================== NEEDS (ODD TERM: Sem 1/3/5/7) — CSE ONLY A & B =====================
/// Year-1 CSE is split — CS owns CS101/PH101/Lab; **Math owns MA101** via separate blocks.
List<TeachingNeed> buildNeeds() {
  final needs = <TeachingNeed>[];
  final semOfYear = {1: 1, 2: 3, 3: 5, 4: 7};

  // ---------- CSE: ONLY A,B per year ----------
  Map<String, List<(String code, String title, String room)>> cseY1_CS_Block(String div) => {
        'A': [('CS101','Programming I','B-101$div'), ('PH101','Physics','B-105$div'), ('CS101-L','Programming Lab','CLab-1$div')],
        'B': [('PH101','Physics','B-105$div'), ('CS101-L','Programming Lab','CLab-1$div'), ('CS101','Programming I','B-101$div')],
      };
  Map<String, List<(String, String, String)>> cseY2Div(String div) => {
        'A': [('CS301','OS','B-301$div'), ('CS305','DBMS','B-303$div'), ('CS307','COA','B-305$div')],
        'B': [('CS305','DBMS','B-303$div'), ('CS307','COA','B-305$div'), ('CS301','OS','B-301$div')],
      };
  Map<String, List<(String, String, String)>> cseY3Div(String div) => {
        'A': [('CS501','AI Basics','B-501$div'), ('CS505','TOC','B-503$div'), ('CS507','Compiler Design','B-505$div')],
        'B': [('CS505','TOC','B-503$div'), ('CS507','Compiler Design','B-505$div'), ('CS501','AI Basics','B-501$div')],
      };
  Map<String, List<(String, String, String)>> cseY4Div(String div) => {
        'A': [('CS701','Cloud','B-701$div'), ('CS705','Security','B-703$div'), ('EL701','Elective I','B-705$div')],
        'B': [('CS705','Security','B-703$div'), ('EL701','Elective I','B-705$div'), ('CS701','Cloud','B-701$div')],
      };

  for (final year in [1,2,3,4]) {
    final sem = semOfYear[year]!;
    for (final div in ['A','B']) {
      final seq = switch (year) {
        1 => cseY1_CS_Block(div)[div]!,
        2 => cseY2Div(div)[div]!,
        3 => cseY3Div(div)[div]!,
        4 => cseY4Div(div)[div]!,
        _ => cseY1_CS_Block(div)[div]!,
      };
      final codes  = [seq[0].$1, seq[1].$1, seq[2].$1];
      final titles = [seq[0].$2, seq[1].$2, seq[2].$2];
      final rooms  = [seq[0].$3, seq[1].$3, seq[2].$3];

      needs.add(TeachingNeed(
        requiredDept: 'Computer Science',
        label: 'CSE-$div (Y$year) • Sem $sem',
        codes: codes, titles: titles, rooms: rooms,
      ));
    }
  }

  // Separate Math blocks for **CSE Year 1** (A & B)
  for (final div in ['A','B']) {
    needs.add(TeachingNeed(
      requiredDept: 'Mathematics',
      label: 'CSE-$div (Y1) • Sem 1 (Math)',
      codes: ['MA101','MA101-T1','MA101-T2'],
      titles: ['Calculus for CS','Tutorial A','Tutorial B'],
      rooms: ['B-MA1','B-T1','B-T2'],
    ));
  }

  // Cross: EEE teaching Digital for CSE-B in Year 2 (Sem 3)
  needs.add(TeachingNeed(
    requiredDept: 'Electrical Engineering',
    label: 'CSE-B (Y2) • Sem 3 (EE)',
    codes: ['EE210','EE211','TUT-EE'],
    titles:['Digital Electronics','Signals for CS','Tutorials'],
    rooms: ['B-EE1','B-EE2','T-EE'],
  ));
  // Cross: CS teaching Programming for Engineers in ME-A (Y1)
  needs.add(TeachingNeed(
    requiredDept: 'Computer Science',
    label: 'ME-A (Y1) • Sem 1 (CS)',
    codes: ['CS-FE1','CS-FE2','TUT-CS'],
    titles:['Programming for Engineers','Python Lab','Tutorials'],
    rooms: ['M-Comp1','M-CLab','T-CS'],
  ));

  // ---------- EEE core (A,B per year) ----------
  for (final year in [1,2,3,4]) {
    final sem = semOfYear[year]!;
    for (final div in ['A','B']) {
      final data = {
        1: (['EE101','PH101','EL-BAS'], ['Basic EE','Physics I','Elec Basics Lab'], ['E-101$div','E-105$div','ELab-0$div']),
        3: (['EE301','EE305','EE310'], ['Power Systems I','Control Systems','Analog Electronics'], ['E-301$div','E-303$div','E-305$div']),
        5: (['EE501','EE505','EE510'], ['Embedded Systems','Networks (EE)','Mini Project'], ['E-501$div','E-503$div','ELab-1$div']),
        7: (['EE701','EE705','EE710'], ['Major Project','Renewable Energy','Viva'], ['ELab-2$div','E-705$div','Hall-F$div']),
      }[sem]!;
      final codes  = data.$1, titles = data.$2, rooms = data.$3;
      needs.add(TeachingNeed(
        requiredDept: 'Electrical Engineering',
        label: 'EEE-$div (Y$year) • Sem $sem',
        codes: codes, titles: titles, rooms: rooms,
      ));
    }
  }

  // Cross: ME teaching Robotics for EEE-B (Y4)
  needs.add(TeachingNeed(
    requiredDept: 'Mechanical Engineering',
    label: 'EEE-B (Y4) • Sem 7 (ME)',
    codes: ['ME-ROB','ME-AUT','TUT-ME'],
    titles:['Industrial Robotics','Automation Systems','Tutorials'],
    rooms: ['E-ROB','E-AUT','T-ME'],
  ));

  // ---------- ME core (A,B per year) ----------
  for (final year in [1,2,3,4]) {
    final sem = semOfYear[year]!;
    for (final div in ['A','B']) {
      final data = {
        1: (['ME101','ME102','ME103'], ['Engineering Mechanics','Engineering Graphics','Workshop'], ['M-101$div','M-102$div','M-103$div']),
        3: (['ME301','ME305','ME310'], ['Fluid Mechanics','Machine Design','Metrology'], ['M-301$div','M-305$div','M-310$div']),
        5: (['ME501','ME505','ME510'], ['Automation','Elective','Seminar'], ['M-501$div','M-505$div','M-510$div']),
        7: (['ME701','ME705','ME710'], ['Major Project','Research','Review'], ['M-701$div','M-705$div','Hall-M$div']),
      }[sem]!;
      needs.add(TeachingNeed(
        requiredDept: 'Mechanical Engineering',
        label: 'ME-$div (Y$year) • Sem $sem',
        codes: data.$1, titles: data.$2, rooms: data.$3,
      ));
    }
  }

  // ---------- Mathematics programme (one class per year) ----------
  final mathYear = {
    1: [('MA101','Calculus I','Sci-101'), ('MA115','Linear Algebra I','Sci-115'), ('TUT101','Tutorial','Sci-T1')],
    2: [('MA305','Real Analysis','Sci-305'), ('MA310','Numerical','Sci-310'), ('MA315','Tutorial','Sci-315')],
    3: [('MA505','Operations Research','Sci-505'), ('MA510','Optimization','Sci-510'), ('MA515','Tutorial','Sci-515')],
    4: [('MA705','Seminar','Sci-705'), ('MA710','Research','Sci-710'), ('MA715','Presentation','Sci-715')],
  };
  for (final year in [1,2,3,4]) {
    final sem = semOfYear[year]!;
    final seq = mathYear[year]!;
    needs.add(TeachingNeed(
      requiredDept: 'Mathematics',
      label: 'MATH (Y$year) • Sem $sem',
      codes: [seq[0].$1, seq[1].$1, seq[2].$1],
      titles:[seq[0].$2, seq[1].$2, seq[2].$2],
      rooms: [seq[0].$3, seq[1].$3, seq[2].$3],
    ));
  }

  // First-year Math inside EEE/ME as well (both A & B)
  for (final div in ['A','B']) {
    needs.add(TeachingNeed(
      requiredDept: 'Mathematics',
      label: 'EEE-$div (Y1) • Sem 1 (Math)',
      codes: ['MA101','MA101-T1','MA101-T2'],
      titles: ['Math I for EEE','Tutorial A','Tutorial B'],
      rooms: ['E-MA1','E-T1','E-T2'],
    ));
    needs.add(TeachingNeed(
      requiredDept: 'Mathematics',
      label: 'ME-$div (Y1) • Sem 1 (Math)',
      codes: ['MA101','MA101-T1','MA101-T2'],
      titles: ['Math I for ME','Tutorial A','Tutorial B'],
      rooms: ['M-MA1','M-T1','M-T2'],
    ));
  }

  return needs;
}

/// ===================== AUTO-ALLOCATION (no overlaps; everyone gets a class) =====================
/// CHANGE: Mathematics needs are sorted so that **MATH (Y1..Y4)** are assigned *before* any cross-dept math blocks.
/// That guarantees visible faculty for Math Year 2/3/4 even if there are few math staff.
Map<String, List<FacultySlot>> buildAllocation(List<Faculty> faculty) {
  final needs = buildNeeds();

  // Group faculty by department
  final byDept = <String, List<Faculty>>{};
  for (final f in faculty) {
    byDept.putIfAbsent(f.dept, () => []).add(f);
  }
  // Group needs by requiredDept
  final needsByDept = <String, List<TeachingNeed>>{};
  for (final n in needs) {
    needsByDept.putIfAbsent(n.requiredDept, () => []).add(n);
  }

  // Stable sort faculty
  for (final list in byDept.values) {
    list.sort((a, b) => a.id.compareTo(b.id));
  }

  // Custom sort for needs:
  int _yearFromLabel(String lbl) {
    final m = RegExp(r'\(Y(\d)\)').firstMatch(lbl);
    return m != null ? int.tryParse(m.group(1)!) ?? 99 : 99;
  }
  for (final entry in needsByDept.entries) {
    final dept = entry.key;
    final list = entry.value;
    if (dept == 'Mathematics') {
      // Priority: programme classes "MATH (Y#) • Sem #" first by year asc, then any cross-dept math by label
      list.sort((a, b) {
        final aProg = a.label.startsWith('MATH ');
        final bProg = b.label.startsWith('MATH ');
        if (aProg != bProg) return aProg ? -1 : 1;
        if (aProg && bProg) {
          final ya = _yearFromLabel(a.label);
          final yb = _yearFromLabel(b.label);
          if (ya != yb) return ya.compareTo(yb);
        }
        return a.label.compareTo(b.label);
      });
    } else {
      list.sort((a, b) => a.label.compareTo(b.label));
    }
  }

  final allocation = <String, List<FacultySlot>>{};
  final supportCounters = <String, int>{};

  for (final entry in byDept.entries) {
    final dept = entry.key;
    final profs = entry.value;
    final deptNeeds = (needsByDept[dept] ?? <TeachingNeed>[]).toList();

    int p = 0, n = 0;

    // First: pair each faculty with one real block (round-robin)
    while (p < profs.length && n < deptNeeds.length) {
      final f = profs[p];
      final need = deptNeeds[n];
      allocation[f.id] = makeWeek(need.label, need.codes, need.titles, need.rooms);
      p += 1;
      n += 1;
    }

    // If extra faculty exist, create Support/Tutorial blocks so nobody is idle
    while (p < profs.length) {
      final f = profs[p];
      final count = (supportCounters[dept] ?? 0) + 1;
      supportCounters[dept] = count;

      final lbl = switch (dept) {
        'Computer Science'       => 'CSE • Support $count',
        'Electrical Engineering' => 'EEE • Support $count',
        'Mechanical Engineering' => 'ME • Support $count',
        'Mathematics'            => 'MATH • Tutorials $count',
        _ => '$dept • Support $count',
      };

      final codes = ['TUT','TUT','TUT'];
      final titles= ['Tutorials / Mentoring','Tutorials / Mentoring','Tutorials / Mentoring'];
      final rooms = ['T-1','T-2','T-3'];

      allocation[f.id] = makeWeek(lbl, codes, titles, rooms);
      p += 1;
    }
  }

  return allocation;
}

/// Build once at startup
final Map<String, List<FacultySlot>> kSlots = buildAllocation(kFaculty);

/// ===== helpers for badges/filters =====
String _batchToken(String lbl) {
  final i = lbl.indexOf('•');
  return (i == -1) ? lbl : lbl.substring(0, i).trim(); // "CSE-A (Y1)" or "MATH (Y3)"
}
int _yearFromBadge(String lbl) {
  final m = RegExp(r'\(Y(\d)\)').firstMatch(lbl);
  return m != null ? int.tryParse(m.group(1)!) ?? -1 : -1;
}
int _semFromBadge(String lbl) {
  final m = RegExp(r'Sem\s+(\d+)').firstMatch(lbl);
  return m != null ? int.tryParse(m.group(1)!) ?? -1 : -1;
}
String badgeFrom(String lbl) {
  final token = _batchToken(lbl);
  final y = _yearFromBadge(lbl);
  final s = _semFromBadge(lbl);
  if (y == -1 || s == -1) return token;
  return '$token • Y$y • Sem $s';
}

/// ===================== DIRECTORY (Dept + Year filters + Search) =====================
class FacultyDirectoryScreen extends StatefulWidget {
  const FacultyDirectoryScreen({super.key});
  @override
  State<FacultyDirectoryScreen> createState() => _FacultyDirectoryScreenState();
}

class _FacultyDirectoryScreenState extends State<FacultyDirectoryScreen> {
  String query = '';
  String selectedDept = 'All';
  String selectedYear = 'All';

  List<String> get deptFilters => const [
        'All',
        'Computer Science',
        'Electrical Engineering',
        'Mechanical Engineering',
        'Mathematics',
      ];
  List<String> get yearFilters => const ['All', 'Year 1', 'Year 2', 'Year 3', 'Year 4'];

  bool _matchesDept(Faculty f) => selectedDept == 'All' || f.dept == selectedDept;
  bool _matchesYear(Faculty f) {
    if (selectedYear == 'All') return true;
    final want = {'Year 1':1,'Year 2':2,'Year 3':3,'Year 4':4}[selectedYear]!;
    final lbl = (kSlots[f.id]?.isNotEmpty ?? false) ? kSlots[f.id]!.first.label : '';
    return _yearFromBadge(lbl) == want;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<Faculty>>{};
    for (final f in kFaculty) {
      final lbl = (kSlots[f.id]?.isNotEmpty ?? false) ? kSlots[f.id]!.first.label : '';
      final badge = badgeFrom(lbl);
      final hay = '${f.name} ${f.id} ${f.dept} $badge'.toLowerCase();
      if (query.isNotEmpty && !hay.contains(query.toLowerCase())) continue;
      if (!_matchesDept(f)) continue;
      if (!_matchesYear(f)) continue;
      grouped.putIfAbsent(f.dept, () => []).add(f);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Faculty Directory'), centerTitle: true),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search name, id, dept, "CSE-A", "Y3", "Sem 5"...',
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (v) => setState(() => query = v.trim()),
            ),
          ),
          // Department chips
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: deptFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final label = deptFilters[i];
                return ChoiceChip(
                  label: Text(label),
                  selected: selectedDept == label,
                  onSelected: (_) => setState(() => selectedDept = label),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Year chips (Y1..Y4 -> Sem 1/3/5/7)
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: yearFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final label = yearFilters[i];
                return ChoiceChip(
                  label: Text(label),
                  selected: selectedYear == label,
                  onSelected: (_) => setState(() => selectedYear = label),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Department sections
          Expanded(
            child: grouped.isEmpty
                ? const Center(child: Text('No faculty found'))
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    children: grouped.entries.map((entry) {
                      final dept = entry.key;
                      final profs = entry.value;
                      IconData icon;
                      if (dept.contains('Computer')) {
                        icon = Icons.computer;
                      } else if (dept.contains('Electrical')) {
                        icon = Icons.flash_on;
                      } else if (dept.contains('Mechanical')) {
                        icon = Icons.engineering;
                      } else {
                        icon = Icons.functions;
                      }
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                        child: ExpansionTile(
                          leading: Icon(icon, color: Colors.teal),
                          title: Text(dept, style: const TextStyle(fontWeight: FontWeight.w600)),
                          children: profs.map((f) {
                            final lbl = (kSlots[f.id]?.isNotEmpty ?? false) ? kSlots[f.id]!.first.label : 'Unassigned';
                            final badge = badgeFrom(lbl);
                            return ListTile(
                              title: Text(f.name),
                              subtitle: Text('${f.id} • ${f.school}'),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.teal.shade200),
                                ),
                                child: Text(badge, style: const TextStyle(fontWeight: FontWeight.w600)),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => FacultyTimetableScreen(faculty: f, label: lbl)),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

/// ===================== TIMETABLE VIEWER =====================
class FacultyTimetableScreen extends StatelessWidget {
  final Faculty faculty;
  final String label;
  const FacultyTimetableScreen({super.key, required this.faculty, required this.label});

  static String _day(int weekday) => const ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'][weekday];

  @override
  Widget build(BuildContext context) {
    final raw = (kSlots[faculty.id] ?? []).toList();
    raw.sort((a, b) {
      if (a.weekday != b.weekday) return a.weekday.compareTo(b.weekday);
      final am = a.start.hour * 60 + a.start.minute;
      final bm = b.start.hour * 60 + b.start.minute;
      return am.compareTo(bm);
    });

    final byDay = {for (var d = 1; d <= 5; d++) d: <FacultySlot>[]};
    for (final s in raw) {
      byDay[s.weekday]!.add(s);
    }

    return Scaffold(
      appBar: AppBar(title: Text(faculty.name)),
      body: raw.isEmpty
          ? const Center(child: Text('No timetable assigned.'))
          : ListView(
              padding: const EdgeInsets.all(12),
              children: List.generate(5, (i) {
                final d = i + 1;
                final slots = byDay[d]!;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ExpansionTile(
                    initiallyExpanded: d == 1,
                    title: Text('${_day(d)}  •  $label'),
                    children: slots.isEmpty
                        ? [const ListTile(title: Text('No classes'))]
                        : slots.map((s) => ListTile(
                              leading: const Icon(Icons.schedule),
                              title: Text('${s.courseCode} • ${s.courseTitle}'),
                              subtitle: Text('${s.room}   •   ${s.start.format(context)} – ${s.end.format(context)}'),
                            )).toList(),
                  ),
                );
              }),
            ),
    );
  }
}

/// ===================== MAP (placeholder) =====================
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Map')),
      body: const Center(
        child: Text(
          'Map coming soon.\nHook your campus map here.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

/// ===================== SOS (placeholder) =====================
class SosScreen extends StatelessWidget {
  const SosScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency SOS')),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('SOS triggered (demo). Wire to phone/alert here.')),
            );
          },
          icon: const Icon(Icons.sos),
          label: const Text('Send SOS'),
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
        ),
      ),
    );
  }
}
