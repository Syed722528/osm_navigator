import 'package:flutter/material.dart';

import '../models/saved.dart';

class SavedLocationPage extends StatelessWidget {
  // Temporarily Storing data in the app

  const SavedLocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color set to black
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Saved Locations',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: saved.isEmpty
          ? Center(
              child: Text('No saved locations',style: TextStyle(color: Colors.white
              ),),
            )
          : ListView.builder(
              itemCount: saved.length,
              itemBuilder: (context, index) {
                Saved location = saved[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Colors.black, // Card color set to white
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            location.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            location.address,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    "${location.latitude}, ${location.longitude}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  // Handle the deletion logic here
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
