import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
        elevation: 1,
        leading: Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(232, 236, 244, 1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },

            icon: Icon(
              Icons.chevron_left,
              fontWeight: FontWeight.w600,
              size: 30,
              color: Color.fromRGBO(30, 35, 44, 1),
            ),
          ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/person.png'),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alfredo Lubin',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color.fromRGBO(0, 0, 0, 1),
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      color: Color.fromRGBO(88, 255, 38, 1),
                      size: 10,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Available Now',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color.fromRGBO(155, 235, 91, 1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Color.fromRGBO(92, 92, 92, 0.1)),
            ),
            child: const Row(
              children: [
                Icon(Icons.call, color: Colors.white, size: 16),
                SizedBox(width: 5),
                Text(
                  "Call",
                  style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1)),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 180),
          Center(
            child: const Text(
              "Today",
              style: TextStyle(
                color: Color.fromRGBO(0, 0, 0, 0.72),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          const SizedBox(height: 50),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(width: 10),
              const CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage('assets/images/person.png'),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(12),
                width: MediaQuery.of(context).size.width * 0.6,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(25),
                    topRight: Radius.circular(25),
                    topLeft: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(2, 4), // x, y
                    ),
                  ],
                ),
                child: const Text(
                  "Madam, we have packed your product and it is ready for dispatch. Thank you for your order.",
                ),
              ),
            ],
          ),
          SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.6,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(155, 235, 91, 1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                  ),
                  border: Border.all(color: Color.fromRGBO(0, 0, 0, 0.06)),
                ),
                child: const Text(
                  "ok",
                  style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1)),
                ),
              ),
              const CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage('assets/images/women.png'),
              ),
              const SizedBox(width: 10),
            ],
          ),
          const Spacer(),
          // INPUT FIELD
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(241, 245, 249, 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Color.fromRGBO(76, 108, 154, 1),
                  ),
                ),
                const SizedBox(width: 10),
                // TEXT FIELD
                Expanded(
                  child: TextField(
                    // controller: controller,
                    decoration: InputDecoration(
                      hintText: "Type your message",
                      hintStyle: TextStyle(
                        color: Color.fromRGBO(85, 85, 85, 1),
                      ),
                      filled: true,
                      fillColor: Color.fromRGBO(241, 245, 249, 1),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // SEND BUTTON
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(155, 235, 91, 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
