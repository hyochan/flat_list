import 'package:faker_dart/faker_dart.dart';

class Person {
  final String fullName;
  final String jobTitle;
  final String companyName;
  final String imageUrl;

  Person()
      : fullName = Faker.instance.name.fullName(),
        jobTitle = Faker.instance.name.jobTitle(),
        companyName = Faker.instance.company.companyName(),
        imageUrl =
            Faker.instance.image.loremPicsum.image(width: 25, height: 25),
        super();
}

var data = List.generate(10, (index) => Person());

var getMoreData = () {
  return List.generate(10, (index) => Person());
};
