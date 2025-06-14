import 'package:flutter/material.dart';
import 'package:homease/models/portfolio_model.dart';
import 'package:homease/services/portfolio_service.dart';

class Portfolio extends StatefulWidget {
  final String? providerId;
  
  const Portfolio({
    super.key,
    this.providerId,
  });

  @override
  State<Portfolio> createState() => _PortfolioState();
}

class _PortfolioState extends State<Portfolio> {
  final PortfolioService _portfolioService = PortfolioService();
  PortfolioModel? _portfolio;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPortfolio();
  }

  Future<void> _loadPortfolio() async {
    try {
      final portfolio = await _portfolioService.getPortfolio(widget.providerId);
      setState(() {
        _portfolio = portfolio;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    if (_portfolio == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No portfolio data available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.providerId == null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Portfolio',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _showEditDialog();
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
            _buildStatCard(
              'Total Projects',
              _portfolio!.totalProjects.toString(),
              Icons.work,
            ),
            SizedBox(height: 16),
            _buildStatCard(
              'Total Spent',
              '\$${_portfolio!.totalSpent.toStringAsFixed(2)}',
              Icons.attach_money,
            ),
            SizedBox(height: 16),
            _buildSection('Bio', _portfolio!.bio),
            SizedBox(height: 16),
            _buildSection('Skills', _portfolio!.skills.join(', ')),
            SizedBox(height: 16),
            _buildSection('Achievements', _portfolio!.achievements.join('\n')),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Color(0xff48B1DB)),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog() async {
    final formKey = GlobalKey<FormState>();
    int totalProjects = _portfolio?.totalProjects ?? 0;
    double totalSpent = _portfolio?.totalSpent ?? 0.0;
    List<String> skills = _portfolio?.skills ?? [];
    String bio = _portfolio?.bio ?? '';
    List<String> achievements = _portfolio?.achievements ?? [];

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Edit Portfolio'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: totalProjects.toString(),
                  decoration: InputDecoration(labelText: 'Total Projects'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter total projects';
                    }
                    return null;
                  },
                  onChanged: (value) => totalProjects = int.tryParse(value) ?? 0,
                ),
                TextFormField(
                  initialValue: totalSpent.toString(),
                  decoration: InputDecoration(labelText: 'Total Spent'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter total spent';
                    }
                    return null;
                  },
                  onChanged: (value) => totalSpent = double.tryParse(value) ?? 0.0,
                ),
                TextFormField(
                  initialValue: bio,
                  decoration: InputDecoration(labelText: 'Bio'),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your bio';
                    }
                    return null;
                  },
                  onChanged: (value) => bio = value,
                ),
                TextFormField(
                  initialValue: skills.join(', '),
                  decoration: InputDecoration(labelText: 'Skills (comma-separated)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your skills';
                    }
                    return null;
                  },
                  onChanged: (value) => skills = value.split(',').map((e) => e.trim()).toList(),
                ),
                TextFormField(
                  initialValue: achievements.join(', '),
                  decoration: InputDecoration(labelText: 'Achievements (comma-separated)'),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your achievements';
                    }
                    return null;
                  },
                  onChanged: (value) => achievements = value.split(',').map((e) => e.trim()).toList(),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  final portfolio = PortfolioModel(
                    totalProjects: totalProjects,
                    totalSpent: totalSpent,
                    skills: skills,
                    bio: bio,
                    achievements: achievements,
                  );
                  await _portfolioService.updatePortfolio(portfolio);
                  Navigator.pop(context);
                  _loadPortfolio();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating portfolio: $e')),
                  );
                }
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}
