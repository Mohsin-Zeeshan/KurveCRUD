// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Customer Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF2196F3),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),  
        fontFamily: 'Roboto',
      ),
      home: const CustomerListScreen(), // Main screen of the app
    );
  }
}

// Model class to represent a customer
class Customer {
  final int id;
  final String name;
  final int age;
  final String email;

  Customer({
    required this.id,
    required this.name,
    required this.age,
    required this.email,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      email: json['email'],
    );
  }
}

// Main screen that displays the list of customers
class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  List<Customer> customers = [];
  List<Customer> filteredCustomers = [];
  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();

  final String baseUrl = 'http://localhost:5000/api';

  @override
  void initState() {
    super.initState();
    fetchCustomers();
    searchController.addListener(_filterCustomers);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Function to filter customers based on search input
  void _filterCustomers() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredCustomers = customers;
      } else {
        filteredCustomers = customers
            .where((customer) => customer.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  // Fetch all customers from the backend API
  Future<void> fetchCustomers() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Send GET request
      final response = await http.get(Uri.parse('$baseUrl/customers')); 
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          customers = data.map((json) => Customer.fromJson(json)).toList();
          filteredCustomers = customers;
          isLoading = false;
        });
      } else {
        // Handle error
        showSnackBar('Failed to load customers');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      showSnackBar('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Delete a customer
  Future<void> deleteCustomer(int id) async {
    try {
      // Send DELETE request
      final response = await http.delete(Uri.parse('$baseUrl/customers/$id'));
      
      if (response.statusCode == 200) {
        showSnackBar('Customer deleted successfully');
        fetchCustomers(); // Refresh the list
      } else {
        showSnackBar('Failed to delete customer');
      }
    } catch (e) {
      showSnackBar('Error: $e');
    }
  }

  // Show snackbar for messages
  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Show dialog to add new customer
  void showAddCustomerDialog() {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      // input fields
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Customer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  hintText: 'Enter customer name',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  hintText: 'Enter email address',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Client-side validation
                final name = nameController.text.trim();
                final ageText = ageController.text.trim();
                final email = emailController.text.trim();
                
                // Validate inputs
                if (name.isEmpty || ageText.isEmpty || email.isEmpty) {
                  showSnackBar('Please fill all fields');
                  return;
                }
                
                // Validate name only has the name
                if (name.contains(RegExp(r'[0-9]'))) {
                  showSnackBar('Name cannot contain numbers');
                  return;
                }
                
                // Validate age
                final age = int.tryParse(ageText);
                if (age == null || age < 1 || age > 120) {
                  showSnackBar('Age must be between 1 and 120');
                  return;
                }
                
                // Validate email contains atleast an @
                if (!email.contains('@')) {
                  showSnackBar('Email must contain @ symbol');
                  return;
                }

                // Create customer
                try {
                  final response = await http.post(
                    Uri.parse('$baseUrl/customers'),
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode({
                      'name': name,
                      'age': age,
                      'email': email,
                    }),
                  );

                  if (response.statusCode == 201) {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                    showSnackBar('Customer added successfully');
                    fetchCustomers(); // Refresh the list
                  } else {
                    final error = json.decode(response.body)['error'] ?? 'Failed to add customer';
                    showSnackBar(error);
                  }
                } catch (e) {
                  showSnackBar('Error: $e');
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2196F3),
        title: const Text(
          'Customer Management System',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              onPressed: showAddCustomerDialog,
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text(
                'Add Customer',
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 3,
              ),
            ),
          ),
        ],
      ),
           body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2196F3),
              Color(0xFFF5F7FA),
            ],
            stops: [0.0, 0.3],
          ),
        ),
        child: Column(
          children: [
            // Search Bar
            Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search by customer name...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF2196F3),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
            // Customer List
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                      ),
                    )
                  : filteredCustomers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.people_outline, 
                                  size: 80, 
                                  color: Color(0xFF2196F3),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                searchController.text.isEmpty
                                    ? 'No customers yet'
                                    : 'No customers found matching "${searchController.text}"',
                                style: const TextStyle(
                                  fontSize: 22, 
                                  color: Color(0xFF37474F),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                searchController.text.isEmpty
                                    ? 'Add your first customer!'
                                    : 'Try a different search term',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: const Color(0xFF2196F3),
                          onRefresh: fetchCustomers,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 20),
                            itemCount: filteredCustomers.length,
                            itemBuilder: (context, index) {
                              final customer = filteredCustomers[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.blue.shade50,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {},
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 56,
                                            height: 56,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFF2196F3),
                                                  Color(0xFF1976D2),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF2196F3).withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Text(
                                                customer.name[0].toUpperCase(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  customer.name,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF37474F),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.cake,
                                                      size: 16,
                                                      color: Colors.grey[600],
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${customer.age} years',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey[700],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 2),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.email,
                                                      size: 16,
                                                      color: Colors.grey[600],
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        customer.email,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey[700],
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade50,
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                // Show confirmation dialog
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(16),
                                                      ),
                                                      title: const Text(
                                                        'Delete Customer',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      content: Text(
                                                        'Are you sure you want to delete ${customer.name}?',
                                                        style: const TextStyle(fontSize: 16),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(context).pop();
                                                          },
                                                          child: Text(
                                                            'Cancel',
                                                            style: TextStyle(
                                                              color: Colors.grey[600],
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.of(context).pop();
                                                            deleteCustomer(customer.id);
                                                          },
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: Colors.red,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                          ),
                                                          child: const Text(
                                                            'Delete',
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}