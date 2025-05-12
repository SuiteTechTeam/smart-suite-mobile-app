import 'package:flutter/material.dart';
import 'package:sweetmanager/Commerce/views/subscription_plans.dart';
import 'package:sweetmanager/IAM/models/sign_in_entity.dart';
import 'package:sweetmanager/IAM/services/auth_service.dart';
import 'package:sweetmanager/IAM/views/terms_and_conditions.dart';
import 'package:sweetmanager/Shared/widgets/base_layout.dart';

class LogInScreen extends StatefulWidget{

  const LogInScreen({super.key});

  @override
  State<StatefulWidget> createState() => LogInScreenState();
}

class LogInScreenState extends State<LogInScreen> with SingleTickerProviderStateMixin{

  // Variables: services and text editing controller 

  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _emailRegistrationController = TextEditingController(); // Controller for email registration's tab

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _passwordRegistrationControler = TextEditingController();

  final TextEditingController _dniController = TextEditingController();

  // Variables: tabController and rememberMe

  String? _roleSelected;

  late TabController _tabController;

  // bool _isRememberMe = false;

  bool _isTermsAccepted = false;

  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener((){
      setState(() {
        
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();

    _emailController.dispose();

    _passwordController.dispose();

    _usernameController.dispose();

    _phoneController.dispose();

    _emailRegistrationController.dispose();

    _nameController.dispose();

    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) { // Implements design for login view.
    return BaseLayout(role: '', childScreen: getContentView(context)
    );
  }

  Widget getContentView(BuildContext context)
  {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/back_login.png'), // Replace with your background image URL
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Transparent overlay
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          // Centered Card
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 5,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Center(
                          child: Text('Welcome!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Tab Bar
                        TabBar(
                          controller: _tabController,
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Colors.blueAccent,
                          tabs: const [
                            Tab(text: 'Log in'),
                            Tab(text: 'Register an organization\'s owner'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Tab Bar View with dynamic height
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          child: _tabController.index == 0
                              ? buildLoginTab()
                              : buildRegisterTab(),
                        ),
                        const SizedBox(height: 12),
                        // Log in or Register Button
                        ElevatedButton(
                          onPressed: () async {
                            if(_tabController.index == 0)
                            {
                              String email = _emailController.text;

                              String password = _passwordController.text;

                              String? role = _roleSelected;

                              if(email.isEmpty || password.isEmpty || role == null)
                              {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please fill all the corresponding fields.'))
                                );
                                return;
                              }

                              bool response = await _authService.login(email, password, int.parse(role));

                              if(!mounted) return;

                              if(response)
                              {
                                Navigator.pushNamed(context, '/dashboard');
                              }
                              else
                              {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Something went wrong'))
                                );
                                return;
                              }
                            }
                            else
                            {
                              if(!_isTermsAccepted)
                              {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please accept the Terms and Conditions.'))
                                );
                                return;
                              }

                              String dni = _dniController.text;

                              String phoneNumber = _phoneController.text;

                              String email = _emailRegistrationController.text;

                              String name = _nameController.text;

                              String password = _passwordRegistrationControler.text;

                              if(phoneNumber.isEmpty || email.isEmpty || name.isEmpty || password.isEmpty || !name.contains(','))
                              {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please fill all the corresponding fields following the requested instructions.')));
                                
                                return;
                              }

                              List<String> parts = name.split(',');

                              // Create a username

                              String username = '';

                              name = parts[0].trim();

                              String surname = parts[1].trim();

                              username = '${name}_${surname}_${dni[0]}${dni[1]}${dni[2]}'.toLowerCase();

                              bool response = await _authService.signup(int.parse(dni), username, name, surname, email, phoneNumber, password);

                              if(!mounted) return;

                              if(response)
                              {
                                bool validation = await _authService.login(email, password, 1);

                                if(validation)
                                {

                                  Navigator.push(context, MaterialPageRoute(builder: (context) => SubscriptionPlansView(credentials: SignInEntity(email: email, password: password),)));
                                }
                                else
                                {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('The registration failed')));
                                
                                  return;
                                }
                              }
                              else
                              {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Something went wrong'))
                                );
                                return;
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 80, vertical: 16),
                          ),
                          child: Text(
                            _tabController.index == 0 ? 'Log in' : 'Register organization',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Forgot Password Text (only for login)
                        /* if (_tabController.index == 0)
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Forgot my password',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ), */
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          )
          
        ],
      )
      
    );
  }

  Widget buildLoginTab() {
    return Column(
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _roleSelected,
            items: const [
              DropdownMenuItem(value: '1' ,child: Text('OWNER')),
              DropdownMenuItem(value: '2',child: Text('ADMIN')),
              DropdownMenuItem(value: '3',child: Text('WORKER')),
            ],
            onChanged: (value){
              setState(() {
                _roleSelected = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Role',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)
              )
            ),
          ),
          const SizedBox(height: 12),
        ],
      );
  }

  Widget buildRegisterTab() {
    return Column(
        children: [
          TextField(
            controller: _dniController,
            decoration: InputDecoration(
              labelText: "Owner's DNI",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Owner’s phone number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailRegistrationController,
            decoration: InputDecoration(
              labelText: 'Owner’s email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Owner’s complete name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordRegistrationControler,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Owner’s password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          /* const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '• At least one character in uppercase and lowercase\n'
              '• At least a number\n'
              '• At least a special character\n'
              '• At least 8 characters',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 12), */
          Row(
            children: [
              Checkbox(
                value: _isTermsAccepted,
                onChanged: (value) {
                  setState(() {
                    _isTermsAccepted = value!;
                  });
                },
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Navegar a otra vista
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TermsAndConditionsPage()),
                    );
                  },
                  child: const Text(
                    'I’ve read and accept the Terms and Conditions and Privacy policy',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue, // Cambia el color para que parezca un enlace
                      decoration: TextDecoration.underline, // Subrayar como un enlace
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
    );
  }

}

