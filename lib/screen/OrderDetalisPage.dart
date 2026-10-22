import 'dart:io';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';



class OrderDetalisPage extends StatelessWidget {
  final Map<String,dynamic> orderData;
   OrderDetalisPage({super.key, required this.orderData});


  Future<void> _generatePDF(BuildContext context, Map<String, dynamic> orderData) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Order Invoice',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 16),

                pw.Text('Order Details',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Divider(),

                pw.Text('Order ID: ${orderData['orderId']}'),
                pw.Text('Customer Name: ${orderData['CustomerName']}'),
                pw.Text('City: ${orderData['City']}'),
                pw.Text('State: ${orderData['State']}'),
                pw.Text('Country: ${orderData['Country']}'),
                pw.Text('Pin Code: ${orderData['PinCode']}'),

                pw.SizedBox(height: 20),
                pw.Text('Products',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Divider(),

                pw.Table.fromTextArray(
                  headers: ['Product Name', 'Quantity', 'Price', 'Total'],
                  data: List.generate(orderData['Products'].length, (index) {
                    final product = orderData['Products'][index] as Map<String, dynamic>;
                    final total = product['quantity'] * product['Price'];
                    return [
                      product['productName'],
                      product['quantity'].toString(),
                      product['Price'].toString(),
                      total.toString()
                    ];
                  }),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellAlignment: pw.Alignment.centerLeft,
                  cellStyle: const pw.TextStyle(fontSize: 12),
                  border: pw.TableBorder.all(width: 0.5),
                ),

                pw.SizedBox(height: 20),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    "Total Amount: ${orderData['TotalAmount']}",
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    if (await _requestStoragePermission()) {
      final directory = Directory('/storage/emulated/0/My Project');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final filePath = '${directory.path}/Order_${orderData['orderId']}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      Get.snackbar("PDF Saved", "PDF saved successfully!",
          colorText: Colors.green, snackPosition: SnackPosition.TOP);
    } else {
      Get.snackbar("PDF Not Created", "Storage permission denied!",
          colorText: Colors.red, snackPosition: SnackPosition.TOP);
    }
  }

  Future<bool> _requestStoragePermission() async{
    if(await Permission.storage.request().isGranted){
      return true;
    }
    else if(await Permission.manageExternalStorage.request().isGranted){
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE2D9FB),
      appBar: AppBar(
        title: Text("Order Detelis"),
        backgroundColor: Color(0xFFE2D9FB),
        centerTitle: true,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('  Order Address',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            SizedBox(height: 12),

            // Customer Info Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(' Order Summary',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                    SizedBox(height: 12),
                    Divider(),

                    buildInfoRow('Order ID', orderData['orderId']),
                    buildInfoRow('Customer Name', orderData['CustomerName']),
                    buildInfoRow('City', orderData['City']),
                    buildInfoRow('State', orderData['State']),
                    buildInfoRow('Country', orderData['Country']),
                    buildInfoRow('PinCode', orderData['PinCode']),
                    buildInfoRow('Mobile Number', orderData['MobileNumber']),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),
            Text(' Products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.deepPurple)),
            SizedBox(height: 8),

            // Products List
            Expanded(
              child: ListView.builder(
                itemCount: orderData['Products'].length,
                itemBuilder: (context, index) {
                  final product = orderData['Products'][index] as Map<String, dynamic>;
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.shopping_bag, color: Colors.deepPurple),
                        ),
                        title: Text(
                          "${product['productName']}",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          "Qty: ${product['quantity']}  •  ₹${product['Price']}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 12),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.currency_rupee, color: Colors.green, size: 24),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Total Amount",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.green[900],
                      ),
                    ),
                  ),
                  Text(
                    "₹${orderData['TotalAmount']}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _generatePDF(context,orderData),
                icon: Icon(Icons.picture_as_pdf,color: Colors.white,),
                label: Text("Generate Bill",style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  textStyle: TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  Widget buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 8),
          Text('$label: ',
              style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black87)),
          Expanded(
            child: Text('$value',
                style: TextStyle(color: Colors.black54), overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}


