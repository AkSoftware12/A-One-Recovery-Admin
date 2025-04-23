import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../BottomNavigation/Bottom2/screens.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: const [
          BannerSlider(),
          Expanded(child: ItemList()),
        ],
      ),
    );
  }
}



class BannerSlider extends StatelessWidget {
  const BannerSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> bannerImages = [
      'https://www.denofgeek.com/wp-content/uploads/2023/04/Tears-of-the-Kingdom-Legend-of-Zelda.jpg?resize=768%2C432',
      'https://demoseal.cloudimg.io/sample.li/birds.jpg?ci_eqs=d2F0PTEmd2F0X3VybD1odHRwOi8vc2FtcGxlLmxpL2xvdWlzLXZ1aXR0b24tbG9nby13aGl0ZS5wbmcmd2F0X3NjYWxlPTQ1JndhdF9ncmF2aXR5PXNvdXRod2VzdCZ3YXRfcGFkPTE1&ci_seal=a355cce069fbfb18a4&',
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQEmzXL7lF7jZDp61Ml5B2R8m0rNJMyUrKNp9EJGjQLmeDzndxZsesSehebHqB3M-Qy7hA&usqp=CAU',
    ];

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizedBox(
        height: 150,
        child: PageView.builder(
          itemCount: bannerImages.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  bannerImages[index],
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}



class ItemList extends StatelessWidget {
  const ItemList({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> items = List.generate(20, (index) => 'Item ${index + 1}');

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,

      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: (){

            PersistentNavBarNavigator.pushNewScreen(context,
                screen: const MainScreen2());

          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(items[index]),
              subtitle: const Text('Item subtitle here'),
            ),
          ),
        );
      },
    );
  }
}
