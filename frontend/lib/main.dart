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
  bool isLoading = true;
  

  // For Web (Chrome): http://localhost:5000/api
  final String baseUrl = 'http://localhost:5000/api';

  @override
  void initState() {
    super.initState();
    fetchCustomers();
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
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
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
                // Validate inputs
                if (nameController.text.isEmpty ||
                    ageController.text.isEmpty ||
                    emailController.text.isEmpty) {
                  showSnackBar('Please fill all fields');
                  return;
                }

                // Create customer
                try {
                  final response = await http.post(
                    Uri.parse('$baseUrl/customers'),
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode({
                      'name': nameController.text,
                      'age': int.parse(ageController.text),
                      'email': emailController.text,
                    }),
                  );

                  if (response.statusCode == 201) {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                    showSnackBar('Customer added successfully');
                    fetchCustomers(); // Refresh the list
                  } else {
                    showSnackBar('Failed to add customer');
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
        // Simple blue AppBar - nothing fancy
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : customers.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No customers yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add your first customer!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchCustomers,
                  child: ListView.builder(
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
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
      floatingActionButton: FloatingActionButton(
        onPressed: showAddCustomerDialog,
        tooltip: 'Add Customer',
        child: const Icon(Icons.add),
      ),
    );
  }
}