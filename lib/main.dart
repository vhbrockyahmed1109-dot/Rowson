import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const RowsonApp());
}

class RowsonApp extends StatelessWidget {
  const RowsonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ROWSON Marketplace',
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      home: const RowsonHome(),
    );
  }
}

class Property {
  String title;
  String category;
  String location;
  String price;
  String description;
  String seller;
  String phone;
  bool featured;

  Property({
    required this.title,
    required this.category,
    required this.location,
    required this.price,
    required this.description,
    required this.seller,
    required this.phone,
    this.featured = false,
  });
}

class RowsonHome extends StatefulWidget {
  const RowsonHome({super.key});

  @override
  State<RowsonHome> createState() => _RowsonHomeState();
}

class _RowsonHomeState extends State<RowsonHome> {
  int selectedIndex = 0;

  String currentUser = '';
  String currentPhone = '';
  String searchText = '';
  String selectedCategory = 'সব';

  int totalAds = 0;
  int totalIncome = 0;

  final TextEditingController searchController =
      TextEditingController();

  final List<Property> properties = [
    Property(
      title: '৫ কাঠা জমি বিক্রি হবে',
      category: 'জমি',
      location: 'মিরপুর, ঢাকা',
      price: '৫০,০০,০০০',
      description: 'আবাসিক এলাকায় ভালো লোকেশনে জমি।',
      seller: 'রহিম',
      phone: '01700000000',
      featured: true,
    ),
    Property(
      title: 'সুন্দর ৩ বেডরুমের ফ্ল্যাট',
      category: 'ফ্ল্যাট',
      location: 'উত্তরা, ঢাকা',
      price: '৮০,০০,০০০',
      description: 'লিফট ও পার্কিং সুবিধাসহ ফ্ল্যাট।',
      seller: 'করিম',
      phone: '01800000000',
    ),
    Property(
      title: 'দুই তলা বাড়ি বিক্রি',
      category: 'বাড়ি',
      location: 'সাভার, ঢাকা',
      price: '১,২০,০০,০০০',
      description: 'পরিবারের বসবাসের উপযোগী বাড়ি।',
      seller: 'জামাল',
      phone: '01900000000',
    ),
  ];

  final List<String> categories = [
    'সব',
    'জমি',
    'ফ্ল্যাট',
    'বাড়ি',
  ];

  List<Property> get filteredProperties {
    return properties.where((property) {
      final categoryMatch =
          selectedCategory == 'সব' ||
          property.category == selectedCategory;

      final query = searchText.toLowerCase();

      final searchMatch =
          property.title.toLowerCase().contains(query) ||
          property.location.toLowerCase().contains(query) ||
          property.category.toLowerCase().contains(query);

      return categoryMatch && searchMatch;
    }).toList();
  }

  // PHONE CALL
  Future<void> callSeller(String phone) async {
    final Uri uri = Uri(
      scheme: 'tel',
      path: phone,
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // WHATSAPP
  Future<void> whatsappSeller(String phone) async {
    String number = phone.replaceAll(RegExp(r'\D'), '');

    if (number.startsWith('0')) {
      number = '88$number';
    }

    final Uri uri = Uri.parse('https://wa.me/$number');

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  // ADD PROPERTY
  void addProperty() {
    if (currentUser.isEmpty || currentPhone.isEmpty) {
      showMessage('আগে আপনার অ্যাকাউন্ট তৈরি করুন এবং ফোন নম্বর দিন।');
      setState(() => selectedIndex = 3);
      return;
    }

    if (totalAds > 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('বিজ্ঞাপন ফি'),
          content: const Text(
            'আপনার প্রথম বিজ্ঞাপন ফ্রি। '
            'পরবর্তী বিজ্ঞাপনের ফি ৳২০০।\n\n'
            'Featured বিজ্ঞাপন ৳৫০০ / ৭ দিন।',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('বাতিল'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                showPostForm();
              },
              child: const Text('এগিয়ে যান'),
            ),
          ],
        ),
      );
    } else {
      showPostForm();
    }
  }

  void showPostForm() {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();

    String category = 'জমি';
    bool featured = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('নতুন বিজ্ঞাপন দিন'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'বিজ্ঞাপনের নাম',
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(
                      labelText: 'ক্যাটাগরি',
                    ),
                    items: ['জমি', 'ফ্ল্যাট', 'বাড়ি']
                        .map((item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => category = value);
                      }
                    },
                  ),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'ঠিকানা / এলাকা',
                    ),
                  ),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'দাম (টাকা)',
                    ),
                  ),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'বিস্তারিত বিবরণ',
                    ),
                  ),
                  CheckboxListTile(
                    value: featured,
                    title: const Text('Featured বিজ্ঞাপন ৳৫০০'),
                    onChanged: (value) {
                      setDialogState(() {
                        featured = value ?? false;
                      });
                    },
                  ),
                  const Text(
                    'বিক্রেতার ফোন ও WhatsApp নম্বর '
                    'আপনার অ্যাকাউন্ট থেকে নেওয়া হবে।',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('বাতিল'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.trim().isEmpty ||
                      locationController.text.trim().isEmpty ||
                      priceController.text.trim().isEmpty) {
                    return;
                  }

                  if (totalAds > 0) {
                    totalIncome += featured ? 500 : 200;
                  }

                  setState(() {
                    properties.insert(
                      0,
                      Property(
                        title: titleController.text.trim(),
                        category: category,
                        location: locationController.text.trim(),
                        price: priceController.text.trim(),
                        description:
                            descriptionController.text.trim(),
                        seller: currentUser,
                        phone: currentPhone,
                        featured: featured,
                      ),
                    );

                    totalAds++;
                    selectedCategory = 'সব';
                    searchText = '';
                  });

                  Navigator.pop(dialogContext);
                  showMessage('আপনার বিজ্ঞাপন যুক্ত হয়েছে।');
                },
                child: const Text('প্রকাশ করুন'),
              ),
            ],
          );
        },
      ),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // PROPERTY DETAILS
  void showPropertyDetails(Property property) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(property.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ক্যাটাগরি: ${property.category}'),
              Text('ঠিকানা: ${property.location}'),
              Text('দাম: ৳${property.price}'),
              const Divider(),
              Text('বিক্রেতা: ${property.seller}'),
              Text('ফোন: ${property.phone}'),
              const Divider(),
              Text('বিস্তারিত: ${property.description}'),
              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => callSeller(property.phone),
                  icon: const Icon(Icons.call),
                  label: const Text('ফোন করুন'),
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () =>
                      whatsappSeller(property.phone),
                  icon: const Icon(Icons.chat),
                  label: const Text('WhatsApp করুন'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('বন্ধ করুন'),
          ),
        ],
      ),
    );
  }

  // HOME PAGE
  Widget homePage() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          color: Colors.green,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to ROWSON',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'আপনার পছন্দের সম্পত্তি খুঁজুন',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'জমি, ফ্ল্যাট বা এলাকা খুঁজুন',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onChanged: (value) {
              setState(() => searchText = value);
            },
          ),
        ),

        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: categories.map((category) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: ChoiceChip(
                  label: Text(category),
                  selected: selectedCategory == category,
                  onSelected: (_) {
                    setState(() => selectedCategory = category);
                  },
                ),
              );
            }).toList(),
          ),
        ),

        const Padding(
          padding: EdgeInsets.all(12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'সাম্প্রতিক বিজ্ঞাপন',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        Expanded(
          child: filteredProperties.isEmpty
              ? const Center(child: Text('কোনো বিজ্ঞাপন পাওয়া যায়নি'))
              : ListView.builder(
                  itemCount: filteredProperties.length,
                  itemBuilder: (context, index) {
                    final property = filteredProperties[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: const Icon(
                            Icons.home_work,
                            color: Colors.green,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                property.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (property.featured)
                              const Icon(
                                Icons.star,
                                color: Colors.orange,
                              ),
                          ],
                        ),
                        subtitle: Text(
                          '${property.category} | ${property.location}\n'
                          '৳${property.price}',
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => showPropertyDetails(property),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // PROFILE PAGE
  Widget profilePage() {
    final nameController = TextEditingController(text: currentUser);
    final phoneController = TextEditingController(text: currentPhone);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const CircleAvatar(
          radius: 45,
          child: Icon(Icons.person, size: 50),
        ),
        const SizedBox(height: 15),
        const Center(
          child: Text(
            'ROWSON Account',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 20),

        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'আপনার নাম',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'ফোন নম্বর',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 15),

        ElevatedButton(
          onPressed: () {
            if (nameController.text.trim().isEmpty ||
                phoneController.text.trim().isEmpty) {
              showMessage('নাম ও ফোন নম্বর লিখুন।');
              return;
            }

            setState(() {
              currentUser = nameController.text.trim();
              currentPhone = phoneController.text.trim();
            });

            showMessage('অ্যাকাউন্টের তথ্য সংরক্ষণ হয়েছে।');
          },
          child: const Text('অ্যাকাউন্ট তৈরি / আপডেট'),
        ),

        const Divider(height: 35),

        const Text(
          'আপনার ব্যবসার হিসাব',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.campaign),
          title: const Text('মোট বিজ্ঞাপন'),
          trailing: Text('$totalAds'),
        ),
        ListTile(
          leading: const Icon(Icons.account_balance_wallet),
          title: const Text('বিজ্ঞাপন থেকে আয় (ডেমো)'),
          trailing: Text('৳$totalIncome'),
        ),
        ListTile(
          leading: const Icon(Icons.star),
          title: const Text('Featured বিজ্ঞাপন'),
          subtitle: const Text('৳৫০০ / ৭ দিন'),
        ),
        ListTile(
          leading: const Icon(Icons.card_membership),
          title: const Text('Monthly Membership'),
          subtitle: const Text('৳১,০০০ / মাস'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      homePage(),
      const Center(child: Text('আপনার পছন্দের বিজ্ঞাপন')),
      const Center(child: Text('বিজ্ঞাপন পরিচালনা')),
      profilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ROWSON',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box),
            onPressed: addProperty,
          ),
        ],
      ),

      body: pages[selectedIndex],

      floatingActionButton: selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: addProperty,
              icon: const Icon(Icons.add),
              label: const Text('বিজ্ঞাপন দিন'),
            )
          : null,

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'হোম',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite),
            label: 'পছন্দ',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt),
            label: 'বিজ্ঞাপন',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'অ্যাকাউন্ট',
          ),
        ],
      ),
    );
  }
}
