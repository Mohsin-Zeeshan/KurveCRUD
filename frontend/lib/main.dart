import 'package:flutter/material.dart';
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
      ),
      home: const CustomerListScreen(),
    );
  }
}

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

  // Fetch all customers from backend
  Future<void> fetchCustomers() async {
    setState(() {
      isLoading = true;
    });

    try {
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
      // Labels and hint text for the input fields
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
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  hintText: 'Enter customer name',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                  hintText: 'Enter age (1-120)',
                ),
                keyboardType: TextInputType.number,
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
                
                // Validate name doesn't contain numbers
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
                
                // Validate email contains @
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
      appBar: AppBar(
        title: const Text('Customer Management System'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              onPressed: showAddCustomerDialog,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Customer',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by customer name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          // Customer List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredCustomers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              searchController.text.isEmpty
                                  ? 'No customers yet'
                                  : 'No customers found matching "${searchController.text}"',
                              style: const TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              searchController.text.isEmpty
                                  ? 'Add your first customer!'
                                  : 'Try a different search term',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: fetchCustomers,
                        child: ListView.builder(
                          itemCount: filteredCustomers.length,
                          itemBuilder: (context, index) {
                            final customer = filteredCustomers[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              elevation: 2,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: Text(
                                    customer.name[0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  customer.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Age: ${customer.age}'),
                                    Text('Email: ${customer.email}'),
                                  ],
                                ),
                                isThreeLine: true,
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    // Show confirmation dialog
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Delete Customer'),
                                          content: Text('Are you sure you want to delete ${customer.name}?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                deleteCustomer(customer.id);
                                              },
                                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}