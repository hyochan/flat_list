import 'package:flat_list_example/data.dart';
import 'package:flutter/material.dart';

class ListItemView extends StatelessWidget {
  final Person person;
  const ListItemView({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    return Ink(
      child: ListTile(
        onTap: () {},
        title: SizedBox(
          height: 80,
          child: Row(
            children: [
              ClipOval(
                child: Container(
                  color: Colors.black12,
                  width: 25,
                  height: 25,
                  child: Image.network(person.imageUrl, width: 25, height: 25),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(child: Text(person.fullName)),
            ],
          ),
        ),
        subtitle: Container(
          height: 40,
          margin: const EdgeInsets.only(top: 8),
          child: Text(person.jobTitle),
        ),
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      height: 52,
      color: Colors.black87,
      child: const Text('Header', style: TextStyle(color: Colors.white)),
    );
  }
}

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      height: 80,
      color: Colors.black12,
      child: const Text('Footer', style: TextStyle(color: Colors.black)),
    );
  }
}
