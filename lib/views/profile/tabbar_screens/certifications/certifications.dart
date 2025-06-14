import 'package:flutter/material.dart';
import 'package:homease/models/certification_model.dart';
import 'package:homease/services/certification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Certifications extends StatelessWidget {
  final String? providerId;

  const Certifications({
    super.key,
    this.providerId,
  });

  @override
  Widget build(BuildContext context) {
    final userId = providerId ?? FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return Center(child: Text('User not authenticated'));
    }

    final certificationService = CertificationService();

    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<List<CertificationModel>>(
        stream: certificationService.getCertifications(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Error loading certifications: ${snapshot.error}'));
          }

          final certifications = snapshot.data ?? [];

          if (certifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.workspace_premium,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No certifications yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView(
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(16),
            children: [
              ...certifications.map((certification) => Card(
                color: Colors.white,
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            certification.isQualification
                                ? Icons.school
                                : Icons.workspace_premium,
                            color: Theme.of(context).primaryColor,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  certification.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  certification.issuer,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (certification.description.isNotEmpty) ...[
                        SizedBox(height: 12),
                        Text(
                          certification.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 16, color: Colors.grey[600]),
                          SizedBox(width: 8),
                          Text(
                            'Issued: ${DateFormat('MMM yyyy').format(certification.issueDate)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (certification.expiryDate != null) ...[
                            SizedBox(width: 16),
                            Icon(Icons.event,
                                size: 16, color: Colors.grey[600]),
                            SizedBox(width: 8),
                            Text(
                              'Expires: ${DateFormat('MMM yyyy').format(certification.expiryDate!)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (certification.certificateUrl?.isNotEmpty ??
                          false) ...[
                        TextButton.icon(
                          onPressed: () {
                            // TODO: Implement certificate view
                          },
                          icon: Icon(Icons.visibility),
                          label: Text('View Certificate'),
                        ),
                      ],
                    ],
                  ),
                ),
              )).toList(),
            ],
          );
        },
      ),
    );
  }
}
