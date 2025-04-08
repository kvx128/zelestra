import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String searchQuery = '';
  List<DocumentSnapshot> allDocs = [];
  bool isLoading = false;
  bool hasMore = true;
  DocumentSnapshot? lastDoc;
  final int limit = 30;
  final ScrollController _scrollController = ScrollController();

  // Horizontal scroll controller for potential future optimization
  final ScrollController _horizontalScrollController = ScrollController();

  String? sortKey;
  bool ascending = true;

  List<String> initialColumnKeys = [
    'Power_station',
    'Country',
    'Year_operational',
    'Capacity_MW',
  ];

  List<String> extraColumnKeys = [];
  bool extraColumnsLoaded = false;

  @override
  void initState() {
    super.initState();
    fetchMore();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoading &&
          hasMore) {
        fetchMore();
      }
    });
  }

  Future<void> fetchMore() async {
    if (isLoading || !hasMore) return;
    setState(() => isLoading = true);

    Query query = FirebaseFirestore.instance
        .collection('project')
        .orderBy(FieldPath.documentId)
        .limit(limit);
    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc!);
    }

    final snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      lastDoc = snapshot.docs.last;
      allDocs.addAll(snapshot.docs);

      // Load extra columns once on first fetch
      if (!extraColumnsLoaded) {
        final allKeys =
            (snapshot.docs.first.data() as Map<String, dynamic>).keys;
        final rest = allKeys.where((key) => !initialColumnKeys.contains(key));
        setState(() {
          extraColumnKeys = rest.toList();
          extraColumnsLoaded = true;
        });
      }
    }

    if (snapshot.docs.length < limit) {
      hasMore = false;
    }

    setState(() => isLoading = false);
  }

  void sortBy(String key) {
    setState(() {
      sortKey = key;
      ascending = !ascending;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<DocumentSnapshot> filteredDocs = allDocs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final city =
          data['City_lowest_administrative_level']?.toString().toLowerCase() ??
              '';
      final country = data['Country']?.toString().toLowerCase() ?? '';
      return city.contains(searchQuery) || country.contains(searchQuery);
    }).toList();

    if (sortKey != null) {
      filteredDocs.sort((a, b) {
        final aVal = (a.data() as Map<String, dynamic>)[sortKey];
        final bVal = (b.data() as Map<String, dynamic>)[sortKey];
        return ascending
            ? aVal.toString().compareTo(bVal.toString())
            : bVal.toString().compareTo(aVal.toString());
      });
    }

    final columnKeys = [...initialColumnKeys, ...extraColumnKeys];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Renewable Projects Dashboard'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/signin');
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Search by City or Country',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _horizontalScrollController,
                  child: SizedBox(
                    width: columnKeys.length * 150,
                    child: Column(
                      children: [
                        Row(
                          children: columnKeys
                              .map((key) => InkWell(
                                    onTap: () => sortBy(key),
                                    child: Container(
                                      width: 150,
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: Colors.purple.shade200,
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              key,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (sortKey == key)
                                            Icon(
                                              ascending
                                                  ? Icons.arrow_upward
                                                  : Icons.arrow_downward,
                                              size: 16,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: filteredDocs.length + (hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == filteredDocs.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                );
                              }
                              final data = filteredDocs[index].data()
                                  as Map<String, dynamic>;
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: columnKeys
                                    .map((key) => Container(
                                          width: 150,
                                          padding: const EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                          ),
                                          child: Text(
                                            data[key]?.toString() ?? '',
                                            style:
                                                const TextStyle(fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                          ),
                                        ))
                                    .toList(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
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
