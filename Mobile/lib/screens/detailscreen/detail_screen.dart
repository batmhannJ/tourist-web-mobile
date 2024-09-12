import 'package:flutter/material.dart';
import 'package:flutter_application_2/model/place_model.dart';
import 'package:flutter_application_2/utilities/colors.dart';
class DetailScreen extends StatefulWidget {
  final PlaceInfo placeInfo;
  const DetailScreen({super.key, required this.placeInfo});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteClr,
      body: Stack(
        children: [
          Image.asset(
            widget.placeInfo.image, 
            width: double.infinity, 
            fit: BoxFit.cover,
            height: MediaQuery.of(context).size.height*0.5,
          ),
          SafeArea(
            child: Column(
              children: [
                //appbar buttons
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(100),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Container(
                          height: 25,
                          width: 25,
                          decoration: const BoxDecoration(
                            color: kPrimaryClr,
                            shape: BoxShape.circle
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.arrow_back, 
                              color: kWhiteClr,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                   Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(100),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Container(
                        height: 25,
                        width: 25,
                        decoration: const BoxDecoration(
                          color: kWhiteClr,
                          shape: BoxShape.circle
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.bookmark_rounded, 
                            color: kPrimaryClr,
                            size: 25,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ///
            SizedBox(
              height: MediaQuery.of(context).size.height*0.3,
            ),
            Expanded(
              child: Container(
               
                width: double.infinity,
                decoration: BoxDecoration(
                  color: kWhiteClr,
                  borderRadius: BorderRadius.circular(30)
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                      widget.placeInfo.name,
                      style: const TextStyle(
                      fontSize: 26, 
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                     const SizedBox(
                        height: 12,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on, 
                          color: kPrimaryClr,
                          ),
                          const SizedBox(
                        width: 12,
                      ),
                          Text(
                            widget.placeInfo.location, 
                            style: const TextStyle(
                              color: Colors.grey, 
                              fontSize: 20,
                            ),
                            )
                        ],
                      ),
                     const SizedBox(
                        height: 15,
                      ),
                     const  Text(
                      "Trip details",
                      style: TextStyle(
                      fontSize: 23, 
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                    const SizedBox(
                        height: 10,
                      ),
                                   Text(
                            widget.placeInfo.desc, 
                            style: const TextStyle(
                              color: Colors.grey, 
                              fontSize: 18,
                            ),
                            ),  const SizedBox(
                        height: 10,
                      ),
                            const Divider(
                              height: 5,
                              color: Colors.black,
                            ),
                             const SizedBox(
                        height: 20,
                      ),
                       
                      ],
                    ),
                  ),
                ),
              ),
            )
              ],
            ),
          )
        ],
      ),

    );
  }
}