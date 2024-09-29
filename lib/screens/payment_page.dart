import 'dart:convert'; // For hex encodingFor utf8 encoding
import 'package:convert/convert.dart';  // For hex encoding
import 'package:flutter/material.dart';
import 'package:login/screens/about_job.dart';
import 'package:login/screens/home.dart';
import 'package:login/screens/notif_page.dart';
import 'package:login/screens/post_page.dart';
import 'package:login/screens/profile_page.dart';
import 'package:reown_appkit/modal/appkit_modal_impl.dart';
import 'package:reown_appkit/reown_appkit.dart';
import '../widget/payment/balance_card.dart';
import '../widget/payment/section_title.dart';
import '../widget/payment/job_card.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart'; // Use http package

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  ReownAppKitModal? appKitModal;
   String walletAddress = '';
   String _balance = '0';

  @override
  void initState() {
    super.initState();
    initializeAppKitModal();
  }

  void initializeAppKitModal() async {
      
    appKitModal = ReownAppKitModal(
      context: context,
      projectId: '2d5e262acbc9bf4a4ee3102881528534',
      metadata: const PairingMetadata(
        name: 'Crypto Flutter',
        description: 'A Crypto Flutter Example App',
        url: 'https://www.reown.com/',
        icons: ['https://reown.com/reown-logo.png'],
        redirect: Redirect(
          native: 'cryptoflutter://',
          universal: 'https://reown.com/crpytoflutter',
          linkMode: true,
        ),
      ),
    );

    await appKitModal!.init();

     updateWalletAddress();

    // Listen for session updates
    appKitModal!.addListener(() {
      updateWalletAddress();
    });

    setState(() {});
  }

   void updateWalletAddress() {
    // Check if the session is available and update wallet address
    if (appKitModal?.session != null) {
      setState(() {
        walletAddress = appKitModal!.session!.address ?? 'No Address';
        _balance = appKitModal!.balanceNotifier.value; // Update balance
      });
    } else {
      setState(() {
        walletAddress = 'No Address';
         _balance = '0'; // magre-reeset yung balance if no session
      });
    }
  }

 // Use this chainId as a constant
void _onPersonalSign() async {

  appKitModal!.launchConnectedWallet();
    final result = await appKitModal!.request(
      topic: appKitModal!.session!.topic,
      chainId: appKitModal!.selectedChain!.chainId,
      request: SessionRequestParams(
        method: 'personal_sign',
        params: [
          'Goodmorning',  
          appKitModal!.session!.address!,
          appKitModal!.session!.topic,

        ],
      ),
    );
    debugPrint(result);
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: true,
                expandedHeight: 200.0,
                flexibleSpace: FlexibleSpaceBar(
                  title: const SizedBox.shrink(),
                  background: Container(
                    color: const Color.fromARGB(255, 3, 169, 244),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(16.0), 
                          child: Row(
                            children: [
                              BalanceCard(balance: _balance, address: walletAddress),
                              const SizedBox(width: 5),
                              //YourEarnsCard(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  const Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(
                            left:
                                30.0), 
                        child: Text(
                          'Payment',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PaymentSectionTitle(title: 'Actions'),
                      const SizedBox(height: 10),
                      //Row(
                      //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //  children: [
                      //    Visibility(
                      //        visible: appKitModal!.isConnected,
                      //        child: AppKitModalAccountButton(appKit: appKitModal!),
                      //      )                    
                      //  ],
                      //),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(height: 16),
                          AppKitModalConnectButton(
                                appKit: appKitModal!,
                                custom: ElevatedButton(
                                  onPressed: () {
                                      if (appKitModal!.isConnected) {
                                        // Add logic for disconnecting
                                        appKitModal!.disconnect(); // Example method for disconnecting
                                      } else {
                                        appKitModal!.openModalView(); // Open connection modal
                                      }
                                    },
                                  child: Text(appKitModal!.isConnected ? 'Disconnect' : 'Connect Wallet'),
                                ),
                              ),
                          const SizedBox(height: 16),
                          Visibility(
                              visible: !appKitModal!.isConnected,
                              child: AppKitModalNetworkSelectButton(
                                appKit: appKitModal!,
                                custom: ElevatedButton(
                                  onPressed: () {
                                    appKitModal!.openModalView(); // Open network selection modal
                                  },
                                  child: const Text('Select Network'),
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          Visibility(
                            visible: appKitModal!.isConnected,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                     _showSendDialog(context); // Show send dialog on press
                                  },
                                  child: const Text('Send'),
                                ),
                                const SizedBox(width: 17),
                                ElevatedButton(
                                  onPressed: () {
                                    // Define what happens when the Receive button is pressed
                                  },
                                  child: const Text('Receive'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      //Personal Sign inalis ko muna
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //   children: [
                        //  ElevatedButton(onPressed: _onPersonalSign, child: const Text('Personal Sign')),
                       // ]),
                      const SizedBox(height: 20),
                      const PaymentSectionTitle(title: 'To Pay'),
                      const SizedBox(height: 10),
                      const PaymentJobCardPage(
                          description: 'Job post details that need payment.'),
                      const SizedBox(height: 20),
                      const PaymentSectionTitle(title: 'To Receive Payment'),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return const Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: PaymentJobCardPage(
                          description: 'Job post details awaiting payment.'),
                    );
                  },
                  childCount: 10,
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        currentIndex: 3,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'About Job',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.post_add),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment_outlined),
            label: 'Payment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.lightBlue,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const JobPage()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PostPage()),
              );
              break;
            case 3:
              break;
            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
              break;
          }
        },
      ),
    );
  }
}

final customNetwork = ReownAppKitModalNetworkInfo(
  name: 'Sepolia',
  chainId: '11155111',
  currency: 'ETH',
  rpcUrl: 'https://rpc.sepolia.org/',
  explorerUrl: 'https://sepolia.etherscan.io/',
  isTestNetwork: false,
);


Widget _buildColoredIconButton(
    BuildContext context, IconData icon, String label) {
  return Column(
    children: [
      Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 3, 169, 244),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(icon, size: 20, color: Colors.white),
          onPressed: () {
            // Add navigation or action for this button
          },
        ),
      ),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 14)),
    ],
  );
}
// Method to show the dialog for sending
void _showSendDialog(BuildContext context) {
  final TextEditingController addressController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Recipient Address'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Recipient Address Starts with (0x..)'),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                hintText: 'Enter recipient address',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {

              
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Send'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  );
}