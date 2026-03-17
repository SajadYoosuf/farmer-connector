import 'package:customer_app/ui/message/chat/chat_page.dart';
import 'package:flutter/material.dart';

Widget MessageHeader(context) {
  return Container(
    height: 160,
    color: Color.fromRGBO(154, 238, 86, 1),
    child: SafeArea(
      bottom: false,
      child: Column(
        children: [
          ///appbar section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 35),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(232, 236, 244, 1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: IconButton(
                    onPressed: () {
                    },
                    icon: Icon(
                      Icons.chevron_left,
                      fontWeight: FontWeight.w600,
                      size: 30,
                      color: Color.fromRGBO(30, 35, 44, 1),
                    ),
                  ),
                ),
                Text(
                  'messages',
                  style: TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 1),
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Color.fromRGBO(15, 87, 0, 1),
                  ),
                  child: Icon(
                    Icons.notifications,
                    color: Color.fromRGBO(255, 255, 255, 1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget MessageList() {
  return Container(
    decoration: BoxDecoration(
      color: Color.fromRGBO(255, 255, 255, 1),
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    child: ListView.builder(
      shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: 10,
        itemBuilder: (context, index) {
          return
            InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage()));
              },
              child: MessageTile(
                  name: 'Alfredo Lubin',
                  image: 'assets/images/person.png'
              ),
            );
        }

  ));

}

//Message tile
class MessageTile extends StatefulWidget {
  final String name;
  final String image;
  const MessageTile({super.key, required this.name, required this.image});

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey[300],
            backgroundImage: widget.image.isNotEmpty
                ? AssetImage(widget.image)
                : null,
            child: widget.image.isEmpty
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),

          title: Text(
            widget.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Row(
            children: const [
              Icon(Icons.done_all, size: 18, color: Colors.blue),
              SizedBox(width: 5),
              Text("HELLO"),
            ],
          ),
        ),
        const Divider(indent: 80, endIndent: 20),
      ],
    );
  }
}
