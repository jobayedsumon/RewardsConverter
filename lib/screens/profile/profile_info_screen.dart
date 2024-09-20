import 'package:rewards_converter/components/CustomerAvatar.dart';
import 'package:rewards_converter/helpers/alerts.dart';
import 'package:rewards_converter/helpers/dioUtil.dart';
import 'package:rewards_converter/includes/CustomAppBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const payoutOptions = [
  // {
  //   'id': 1,
  //   'name': 'Paypal',
  //   'icon': Icons.paypal,
  // },
  {
    'id': 3,
    'name': 'Bkash',
    'icon': Icons.payment,
  },
  {
    'id': 4,
    'name': 'Nagad',
    'icon': Icons.payments,
  },
  {
    'id': 2,
    'name': 'Tether (USDT) - Binance.com',
    'icon': Icons.wifi_tethering,
  },
];

class ProfileInfoScreen extends StatefulWidget {
  final profileData;
  final getProfileData;

  const ProfileInfoScreen({super.key, this.profileData, this.getProfileData});

  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  var formData = {};
  var _selectedPayoutOption = 1;
  Map userData = {};
  var dio = DioUtil.getInstance();

  var nameController = new TextEditingController();
  var emailController = new TextEditingController();
  var phoneController = new TextEditingController();
  var beneficiaryNameController = new TextEditingController();
  var payoutIdController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    userData = widget.profileData;
    nameController.text = userData['name'] ?? '';
    emailController.text = userData['email'] ?? '';
    phoneController.text = userData['phone_number'] ?? '';
    beneficiaryNameController.text = userData['beneficiary_name'] ?? '';
    payoutIdController.text = userData['payout_id'] ?? '';
    _selectedPayoutOption = userData['payout_method'] ?? 2;
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    beneficiaryNameController.dispose();
    payoutIdController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(showBalance: false),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  width: double.infinity,
                  child: Card(
                    elevation: 5.0,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomerAvatar(
                            image: userData['image'],
                            name: '${userData['name']} ',
                          ),
                          Text(
                            "${userData['name'] ?? ''}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "UID: ${userData['uuid'] ?? ''}",
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                                MaterialButton(
                                  minWidth: 0,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  onPressed: () {
                                    Clipboard.setData(new ClipboardData(
                                        text: userData['uuid']));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text('Copied to clipboard'),
                                    ));
                                  },
                                  child: Icon(
                                    Icons.copy,
                                    size: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Card(
                elevation: 5.0,
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        TabBar(
                          tabs: const <Tab>[
                            Tab(text: 'PERSONAL INFO'),
                            Tab(text: 'PAYOUT INFO'),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: TabBarView(
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    SizedBox(height: 5.0),
                                    TextField(
                                      controller: nameController,
                                      decoration: InputDecoration(
                                        labelText: 'Name',
                                        icon: Icon(Icons.person),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(50.0),
                                        ),
                                        // isDense: true,
                                        isDense: true,
                                      ),
                                    ),
                                    SizedBox(height: 15.0),
                                    TextField(
                                      controller: phoneController,
                                      decoration: InputDecoration(
                                        labelText: 'Phone Number',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(50.0),
                                        ),
                                        icon: Icon(Icons.phone),
                                        isDense: true,
                                      ),
                                    ),
                                    SizedBox(height: 15.0),
                                    TextField(
                                      readOnly: true,
                                      controller: emailController,
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        icon: Icon(Icons.email),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(50.0),
                                        ),
                                        isDense: true,
                                        //disable
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: <Widget>[
                                    SizedBox(height: 5.0),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(Icons.attach_money, size: 20.0),
                                        SizedBox(width: 15.0),
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.black45,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(50.0),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: DropdownButton<String>(
                                                  isExpanded: true,
                                                  value: _selectedPayoutOption
                                                      .toString(),
                                                  hint: Text(
                                                      'Select Payout Method'),
                                                  style: TextStyle(
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    color: Colors.black,
                                                  ),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _selectedPayoutOption =
                                                          int.parse(value!);
                                                    });
                                                  },
                                                  items: payoutOptions
                                                      .map((option) {
                                                    return DropdownMenuItem<
                                                            String>(
                                                        value: option['id']
                                                            .toString(),
                                                        child: Row(
                                                          children: [
                                                            Icon(option['icon']
                                                                as IconData?),
                                                            SizedBox(
                                                                width: 10.0),
                                                            Text(option['name']
                                                                .toString()),
                                                          ],
                                                        ));
                                                  }).toList(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 15.0),
                                    TextField(
                                      controller: beneficiaryNameController,
                                      decoration: InputDecoration(
                                        labelText: 'Beneficiary Name',
                                        icon: Icon(Icons.person),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(50.0),
                                        ),
                                        // isDense: true,
                                        isDense: true,
                                      ),
                                    ),
                                    SizedBox(height: 15.0),
                                    TextField(
                                      controller: payoutIdController,
                                      decoration: InputDecoration(
                                        labelText: _selectedPayoutOption == 3
                                            ? 'Bkash Wallet Number'
                                            : _selectedPayoutOption == 4
                                                ? 'Nagad Wallet Number'
                                                : 'Binance Pay ID or Email',
                                        icon: Icon(
                                          _selectedPayoutOption == 2
                                              ? Icons.email
                                              : Icons.phone_android,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(50.0),
                                        ),
                                        // isDense: true,
                                        isDense: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30.0),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  elevation: 5.0,
                ),
                onPressed: () {
                  updateProfileData();
                },
                child: Text('Save', style: TextStyle(fontSize: 20.0)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void updateProfileData() async {
    try {
      var response = await dio.post('/customer/update', data: {
        'name': nameController.text,
        'email': emailController.text,
        'phone_number': phoneController.text,
        'beneficiary_name': beneficiaryNameController.text,
        'payout_id': payoutIdController.text,
        'payout_method': _selectedPayoutOption,
      });

      var data = response.data;
      if (data['success']) {
        showSuccess(context, data['message']);
        var user = data['user'];
        user['name'] = user['name'] != 'N/A' ? user['name'] : '';
        setState(() {
          userData = user;
          nameController.text = user['name'] ?? '';
          emailController.text = user['email'] ?? '';
          phoneController.text = user['phone_number'] ?? '';
          beneficiaryNameController.text = user['beneficiary_name'] ?? '';
          payoutIdController.text = user['payout_id'] ?? '';
          _selectedPayoutOption = user['payout_method'] ?? 1;
        });
        widget.getProfileData();
      } else {
        showError(context, data['message']);
      }
    } catch (e) {
      print(e);
    }
  }
}
