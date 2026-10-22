import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Veiwbrand extends StatefulWidget {
  const Veiwbrand({super.key});

  @override
  State<Veiwbrand> createState() => _VeiwbrandState();
}

class _VeiwbrandState extends State<Veiwbrand> {
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey.shade100,
        title:Text(
          'Show All Brand',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder(
          stream: _firestore.collection('Brands').orderBy('createdAt',descending: true).snapshots(),
          builder: (context,snapshots){
            if(snapshots.connectionState==ConnectionState.waiting){
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if(!snapshots.hasData||snapshots.data!.docs.isEmpty){
              return Center(
                child: Text("No Data Found"),
              );
            }
            final brandDocs=snapshots.data!.docs;
            return Padding(padding: EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.7,
                ),
                itemCount: brandDocs.length,
                itemBuilder: (context, index) {
                  final brandData = brandDocs[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                          child: Image.network(brandData['imageUrl'],
                            height: 140,
                            width:double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context,error,stackTrace)=>Icon(Icons.broken_image),
                          ),
                        ),
                        Expanded(child: Padding(padding: EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(brandData['Name'],style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600,color: Colors.indigo,),),
                              SizedBox(height: 6,),
                              Text(brandData['Description'],style: TextStyle(fontSize: 12),maxLines: 3,overflow: TextOverflow.ellipsis,),
                              Spacer(),
                              Row(
                                children: [
                                  Icon(Icons.phone,size: 14,color: Colors.grey,),
                                  SizedBox(width: 5,),
                                  Expanded(child: Text(brandData['Contact'],style: TextStyle(fontSize: 13),overflow: TextOverflow.ellipsis,)),
                                ],
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  );
                },
              ),
            );
          }),
    );
  }
}
