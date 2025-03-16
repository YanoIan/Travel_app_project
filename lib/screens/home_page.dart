import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'preferences_page.dart';
import 'favorites_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // Track the active tab
  List<Recommendation> recommendations = [];
  bool isLoading = true;
  final Color primaryColor = Color(0xFF1A4A8B); // Primary brand color

  @override
  void initState() {
    super.initState();
    loadRecommendations(); // Load recommendations when the page is initialized
  }

  Future<void> loadRecommendations() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => isLoading = false);
        return;
      }

      final response = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!response.exists) {
        setState(() {
          isLoading = false;
          recommendations = [];
        });
        return;
      }

      final data = response.data();
      if (data != null && data.containsKey('recommendations')) {
        final recsData = data['recommendations'] as List<dynamic>;
        if (recsData.isNotEmpty) {
          setState(() {
            recommendations = recsData
                .map((json) =>
                    Recommendation.fromJson(json as Map<String, dynamic>))
                .toList();
          });
        } else {
          setState(() => recommendations = []);
        }
      } else {
        setState(() => recommendations = []);
      }
    } catch (e) {
      print('Error loading recommendations: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      floatingActionButton: _buildQuizFAB(), // Floating button for quiz
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildQuizFAB() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PreferencesPage()),
        );
      },
      backgroundColor: primaryColor,
      child: Icon(Icons.travel_explore, color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 2)
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() {
            _currentIndex = index;
            if (index == 0) loadRecommendations();
          }),
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 8,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outlined),
              activeIcon: Icon(Icons.favorite_rounded),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return isLoading
            ? _buildLoading()
            : recommendations.isEmpty
                ? _buildEmptyState()
                : _buildContent();
      case 1:
        return FavoritesPage();
      case 2:
        return ProfilePage();
      default:
        return _buildContent();
    }
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primaryColor),
          SizedBox(height: 16),
          Text('Finding your perfect destinations...',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(height: 80),
            Icon(Icons.travel_explore, size: 100, color: primaryColor),
            SizedBox(height: 40),
            Text('Ready to Explore?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                )),
            SizedBox(height: 16),
            Text(
              'Take our quick quiz to get personalized travel recommendations',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 4,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PreferencesPage()),
                );
              },
              child: Text('Take Travel Quiz',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          floating: true,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text('Discover',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                )),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.grey.shade100],
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          sliver: SliverToBoxAdapter(
            child: Text('Featured Destination',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildFeaturedDestination(),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recommended for You',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text('See All', style: TextStyle(color: primaryColor)),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildRecommendedDestinations(),
        ),
      ],
    );
  }

  Widget _buildFeaturedDestination() {
    final featured = recommendations.first;
    return Container(
      height: 200,
      margin: EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(featured.images.first),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(featured.name,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.attach_money, color: Colors.amber, size: 20),
                    Text(featured.budget,
                        style: TextStyle(color: Colors.white70)),
                    SizedBox(width: 16),
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    Text('4.8', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedDestinations() {
    return SizedBox(
      height: 280, // Increased height to accommodate content
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          return _buildRecommendationCard(index);
        },
      ),
    );
  }

  Widget _buildRecommendationCard(int index) {
    final rec = recommendations[index];
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      margin: EdgeInsets.only(right: 16, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: SingleChildScrollView(
        // Added ScrollView
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                rec.images.first,
                height: 120, // Reduced image height
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rec.name,
                    style: TextStyle(
                      fontSize: 16, // Reduced font size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4), // Reduced spacing
                  Text(
                    rec.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.grey, fontSize: 12), // Reduced font size
                  ),
                  SizedBox(height: 8), // Reduced spacing
                  Row(
                    children: [
                      Icon(Icons.hiking,
                          color: primaryColor, size: 16), // Reduced icon size
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          rec.activities.join(', '),
                          style: TextStyle(
                            fontSize: 12, // Reduced font size
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(Recommendation recommendation) {
    // TODO: Implement navigation to detail page
    print('Navigate to detail page for ${recommendation.name}');
  }
}

class Recommendation {
  final String id;
  final String name;
  final String description;
  final String budget;
  final List<String> images;
  final List<String> activities;
  final String travelTip;

  Recommendation({
    required this.id,
    required this.name,
    required this.description,
    required this.budget,
    required this.images,
    required this.activities,
    required this.travelTip,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      budget: json['budget'],
      images: List<String>.from(json['images'] ?? []),
      activities: List<String>.from(json['activities'] ?? []),
      travelTip: json['travelTip'] ?? '',
    );
  }
}
