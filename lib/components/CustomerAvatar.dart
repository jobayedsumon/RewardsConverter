import 'package:flutter/material.dart';

class CustomerAvatar extends StatelessWidget {
  final image;
  final name;

  const CustomerAvatar({Key? key, this.image = null, this.name})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return image != null
        ? CircleAvatar(
            radius: 30.0,
            backgroundImage: NetworkImage(image),
          )
        : CircleAvatar(
            radius: 30.0,
            child: Text(
              name != null ? name[0].toUpperCase() : '',
              style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
  }
}
