import 'package:scoped_model/scoped_model.dart';
import 'dart:async';

import 'package:vacatiion/model/AdvertiserChalets/AdvertiserChaletsShow.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vacatiion/model/Advertiser/UpdateAdvertiser.dart';
import 'package:vacatiion/model/AdvertiserChalets/AdvertiserChaletsShow.dart';
import 'package:vacatiion/model/ShowChaletModel.dart';
import 'package:vacatiion/model/SuccessAvailableModel.dart';
import 'package:vacatiion/model/SuccessReservationModel.dart';
import 'package:vacatiion/model/user/UpdateUser.dart';
import 'package:vacatiion/pages/SubPages/OffersPage.dart';
import 'package:vacatiion/pages/SubPages/UserPages/Payments/PageCoupon.dart';
import 'package:vacatiion/pages/SubPages/UserPages/Payments/ReservationPaymentPageBank.dart';
import 'package:vacatiion/utility/api_utilites.dart';
import 'package:vacatiion/utility/page-route-transition.dart';
import 'package:vacatiion/utility/utility_class.dart';
import 'dart:convert';
import 'dart:core' as prefix0;
import 'dart:core';
import 'dart:io';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'dart:io';



class ScopedModelShowChalet extends Model
{
  static bool loadingPage=false;
  static bool loadingPageCopun=false;


  //-------------- Loading Home PAGE ----------------//
  showLoadingPage()
  {
    loadingPage=true;
    notifyListeners();
  }
  stopLoadingPage()
  {
    loadingPage=false;
    notifyListeners();
  }
  //------------------------------//
  showLoadingPageCopun()
  {
    loadingPageCopun=true;
    notifyListeners();
  }
  stopLoadingPageCopun()
  {
    loadingPageCopun=false;
    notifyListeners();
  }


  ///-------------------------------------------------------- StreamController Chalet -------------------------------------------//
  StreamController<ShowChalet>  streamControllerShowChalet;
  //----------Start stream-----------//
  initialStreamControllerShowChalet()
  {
    streamControllerShowChalet=StreamController<ShowChalet>.broadcast();
  }
  //---------------------- Input and Output Stream Get All Chalet ----------------------//
  Stream <ShowChalet>  get outStreamShowChalet=> streamControllerShowChalet.stream;
  Sink<ShowChalet>  get inPutStreamShowChalet => streamControllerShowChalet.sink;
  //----------Stop stream----------//
  void disposeStreamControllerShowChalet()
  {
    streamControllerShowChalet.close();
  }
  ///----------------------------------Api-----------------------------------//
  String _apiGetShowChalet=ApiUtilities.baseApi+ApiUtilities.showChalet;
  String _apiCheckChlet=ApiUtilities.baseApi+ApiUtilities.checkChaletAvailable;
  String _apiCheckReservations=ApiUtilities.baseApi+ApiUtilities.couponReservations;
  String _apiCheckreservations=ApiUtilities.baseApi+ApiUtilities.reservationsBill;


  String _apiAddChaletToOffers=ApiUtilities.baseApi+ApiUtilities.addChaletToOffers;

  String _apiRemoveOffers=ApiUtilities.baseApi+ApiUtilities.removeOffer;
  String _apiShowSkipeChalets=ApiUtilities.baseApi+ApiUtilities.skipShowhalehat;



  Future getDataForChalet({BuildContext context, int chaletId}) async {
    //showLoadingPage();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString(Utility.TOKEN);
    final response =
    await http.get(_apiGetShowChalet+"${chaletId}?token="+token, headers: {"Accept": "application/json"});

    var   data  =json.decode(response.body);

    ///========================================= Check the Status Response (SUCCESS)====================================//
    if(data['status']==Utility.VERIFICATION_CODE_SUCCESS)
    {

      inPutStreamShowChalet.add( ShowChalet.fromJson(data));
      print("-------------------------Show Chalet----------------${ShowChalet.fromJson(data).data.chalet.name}");
      //stopLoadingPage();
    }
    ///========================================= Check the Status Response (FAILED)====================================//
    else if(data['status']==Utility.VERIFICATION_CODE_FAILED)
    {

      var error =AdvertiserNoChalets.fromJson(data);
      print("============================ Get All ChALET ${error.error[0]} =================");
      stopLoadingPage();
      //------------Shaw Dialog ---------------//
      //shawAlertDialog(context: context,msg:error.error[0]);
    }else
    {
      stopLoadingPage();
      print("=========================== VERIFICATION_CODE Not compatible with schema${data["message"]} =======================");
      if(data["message"]=="Unauthenticated.")
      {
        shawAlertDialogLogin(context: context,msg: "برجاء تسجيل الدخول",title:data["message"]);
      }

    }




  }

  Future getDataForChaletSkipe({BuildContext context, int chaletId}) async {
    //showLoadingPage();

    final response =
    await http.get(_apiShowSkipeChalets+"${chaletId.toString().trim()}", headers: {"Accept": "application/json"});

    var   data  =json.decode(response.body);


    print("${data}");

    ///========================================= Check the Status Response (SUCCESS)====================================//
    if(data['status']==Utility.VERIFICATION_CODE_SUCCESS)
    {

      inPutStreamShowChalet.add(ShowChalet.fromJson(data));
      print("-------------------------Show Chalet----------------${ShowChalet.fromJson(data).data.chalet.name}");
      //stopLoadingPage();
    }
    ///========================================= Check the Status Response (FAILED)====================================//
    else if(data['status']==Utility.VERIFICATION_CODE_FAILED)
    {

      var error =AdvertiserNoChalets.fromJson(data);
      print("============================ Get All ChALET ${error.error[0]} =================");
      stopLoadingPage();
      //------------Shaw Dialog ---------------//
      //shawAlertDialog(context: context,msg:error.error[0]);
    }else
    {
      stopLoadingPage();
      print("=========================== VERIFICATION_CODE Not compatible with schema${data["message"]} =======================");
      if(data["message"]=="Unauthenticated.")
      {
        shawAlertDialogLogin(context: context,msg: "برجاء تسجيل الدخول",title:data["message"]);
      }

    }




  }

  Future getCheckChalet(
      {BuildContext context,String chaletId ,String Start,String end})async
  {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString(Utility.TOKEN);



    var uri = Uri.parse(_apiCheckChlet+token);

    var request = new http.MultipartRequest("POST", uri,);

    request.fields['chalet_id'] = "${chaletId}";
    request.fields['startDate'] = "${Start}";
    request.fields['endDate'] = "${end}";


    //----------------------Send Request for Server-----------------------//
    var response = await request.send();

    print(response.statusCode);

    response.stream.transform(utf8.decoder).listen((value)
    {

      //------------------- Receive Response in Server ---------------------//
      var data=json.decode(value);

      print("=========Status for Create Adver======"+value.toString()+"======================");

      ///========================================= Check the Status Response (SUCCESS)====================================//
      if(data['status']==Utility.VERIFICATION_CODE_SUCCESS)
      {
         var re =SuccessAvailable.fromJson(data);
         openEditPageCoupon(chaletName: re.data.chalet,
                             context: context,
                             end: re.data.endDate,chaletId: chaletId,
                             price: re.data.price.toString(),
                             start:re.data.startDate );

      }
      ///========================================= Check the Status Response (=====FAILED===) ====================================//
      else if(data['status']==Utility.VERIFICATION_CODE_FAILED)
      {
        shawAlertFailed(context: context,msg: "الشاليه غير متاح فى هذه الفتره",title: "فتره الحجز");


      }else
      {

        print("=========================== VERIFICATION_CODE Not compatible with schema =======================");

      }

    });





  }
  Future addReservationChalet({BuildContext context,String chaletId ,String Start,String end,String coupon})async
  {
    showLoadingPageCopun();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var token = prefs.getString(Utility.TOKEN);

    var uri = Uri.parse(_apiCheckReservations+token);
    var request = new http.MultipartRequest("POST", uri,);

    request.fields['chalet_id'] = "${chaletId}";
    request.fields['coupon']="${coupon}";
    request.fields['startDate'] = "${Start}";
    request.fields['endDate'] = "${end}";


    //----------------------Send Request for Server-----------------------//
    var response = await request.send();

    print(response.statusCode);

    response.stream.transform(utf8.decoder).listen((value)
    {

      //------------------- Receive Response in Server ---------------------//
      var data=json.decode(value);

      print("=========Status for Create Adver======"+value.toString()+"======================");

      ///========================================= Check the Status Response (SUCCESS)====================================//
      if(data['status']==Utility.VERIFICATION_CODE_SUCCESS)
      {
        stopLoadingPageCopun();
        var re =SuccessReservationModel.fromJson(data);
        openConfirmationPageBank(context: context,m: re);

      }
      ///========================================= Check Refer ====================================//
      else if(data['status']==Utility.VERIFICATION_CODE_FAILED)
      {
        stopLoadingPageCopun();
        shawAlertFailed(context: context,msg: "",title: "");


      }


      else
      {

        print("=========================== VERIFICATION_CODE Not compatible with schema =======================");

      }

    });





  }

  reservationsBill({String accountName,String bankName,String chaletId,File imageFile,BuildContext context})async
  {
    showLoadingPage();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString(Utility.TOKEN);


    var stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();

    var uri = Uri.parse(_apiCheckreservations+token);

    var request = new http.MultipartRequest("POST", uri,);


    var multipartFile = new http.MultipartFile('image', stream, length,filename: basename(imageFile.path));
    request.fields['account'] = "${accountName}";
    request.fields['bank'] = "${bankName}";
    request.fields['reservation_id'] = "${chaletId}";

    //contentType: new MediaType('image', 'png'));

    request.files.add(multipartFile);

    //----------------------Send Request for Server-----------------------//
    var response = await request.send();

    print(response.statusCode);

    ///===================================================================  Response ======================================================================//
    response.stream.transform(utf8.decoder).listen((value)
    {
      print("===============تأكيد الدفع=======${value.toString()}=============================");
      //------------------- Receive Response in Server ---------------------//
      var data=json.decode(value);

      print("=========Status for Create Adver======"+data['status']+"======================");
      ///========================================= Check the Status Response (SUCCESS)====================================//

      if(data['status']==Utility.VERIFICATION_CODE_SUCCESS)
      {
        shawAlertSuccess(context: context,title: "بيانات الحجز",desc: "تم حجز الشاليه بنجاح");
        stopLoadingPage();
      }
      ///========================================= Check the Status Response (=====FAILED===) ====================================//
      else if(data['status']==Utility.VERIFICATION_CODE_FAILED)
      {

        stopLoadingPage();
      }else
      {
        stopLoadingPage();
        print("=========================== VERIFICATION_CODE Not compatible with schema =======================");
      }



    });





  }

  Future addChaletToOffers({BuildContext context,String chaletId ,int discount})async
  {
    showLoadingPage();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var token = prefs.getString(Utility.TOKEN);

    var uri = Uri.parse(_apiAddChaletToOffers+chaletId.trim()+"/addOffer?token="+token);

    var request = new http.MultipartRequest("POST", uri,);

    request.fields['discount'] = "${discount.toString()}";


    //----------------------Send Request for Server-----------------------//
    var response = await request.send();

    print(response.statusCode);

    response.stream.transform(utf8.decoder).listen((value)
    {

      //------------------- Receive Response in Server ---------------------//
      var data=json.decode(value);

      print("=========Add Chalet to Offers======"+data.toString()+"======================");

      ///========================================= Check the Status Response (SUCCESS)====================================//
      if(data['status']==Utility.VERIFICATION_CODE_SUCCESS)
      {
        stopLoadingPage();
        shawAlertSuccess(context: context,title: "العروض",desc: "تم اضافه العرض بنجاح");

      }
      ///========================================= Check Refer ====================================//
      else if(data['status']==Utility.VERIFICATION_CODE_FAILED)
      {

        stopLoadingPage();
        shawAlertFailed(context: context,title: "العروض",msg: "لقد قمت بأضافه العرض من قبل");
      }
      else
      {
        stopLoadingPage();
        print("=========================== VERIFICATION_CODE Not compatible with schema =======================");

      }

    });





  }

  Future removeOffer({BuildContext context,String chaletId})async
  {
    showLoadingPage();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var token = prefs.getString(Utility.TOKEN);

    var uri = Uri.parse(_apiRemoveOffers+chaletId.trim()+"/removeOffer?token="+token);

    var request = new http.MultipartRequest("POST", uri,);


    //----------------------Send Request for Server-----------------------//
    var response = await request.send();

    print(response.statusCode);

    response.stream.transform(utf8.decoder).listen((value)
    {

      //------------------- Receive Response in Server ---------------------//
      var data=json.decode(value);

      print("=========Remove Offers====="+data.toString()+"======================");

      ///========================================= Check the Status Response (SUCCESS)====================================//
      if(data['status']==Utility.VERIFICATION_CODE_SUCCESS)
      {
        stopLoadingPage();
        shawAlertSuccess(context: context,title: "العروض",desc: "تم الحذف من العروض بنجاح");

      }
      ///========================================= Check Refer ====================================//
      else if(data['status']==Utility.VERIFICATION_CODE_FAILED)
      {

        stopLoadingPage();
        shawAlertFailed(context: context,title: "العروض",msg: "لا توجد عروض او تم حذفه من قبل");
      }
      else
      {
        stopLoadingPage();
        print("=========================== VERIFICATION_CODE Not compatible with schema =======================");

      }

    });





  }


  ///-----------------------------------Alert Massage---------------------------------//
  void shawAlertFailed({BuildContext context,String msg,String title})
  {
    Alert(
      context: context,
      type: AlertType.info,
      title: title,
      desc: msg,
      style: Utility.alertStyle,
      buttons: [
        DialogButton(
          child: Text(
            "إلغاء",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          gradient: LinearGradient(colors: [
            Color.fromRGBO(116, 116, 191, 1.0),
            Color.fromRGBO(52, 138, 199, 1.0)
          ]),
        )
      ],
    ).show();
  }

  void shawAlertSuccess({BuildContext context,String title,String desc})
  {
    Alert(
      context: context,
      type: AlertType.success,
      title: title,
      desc: desc,
      style: Utility.alertStyle,
      buttons: [
        DialogButton(
          child: Text(
            "إلغاء",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          gradient: LinearGradient(colors: [
            Color.fromRGBO(116, 116, 191, 1.0),
            Color.fromRGBO(52, 138, 199, 1.0)
          ]),
        )
      ],
    ).show();
  }

  void shawAlertDialogLogin({BuildContext context,String msg,String title})
  {
    Alert(
      context: context,
      type: AlertType.warning,
      title: title,
      desc: msg,
      style: Utility.alertStyle,
      buttons: [

        DialogButton(
          child: Text(
            "تسجيل الدخول ",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: ()
          {
            //------------ Dismiss Dialog ------------//
            Navigator.pop(context);
            //------------- open First PAGE -------------//
            Utility.openLoginAccount(context);
          },
          color: Color.fromRGBO(0, 179, 134, 1.0),
        ),
        DialogButton(
          child: Text(
            "إلغاء",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          gradient: LinearGradient(colors: [
            Color.fromRGBO(116, 116, 191, 1.0),
            Color.fromRGBO(52, 138, 199, 1.0)
          ]),
        )
      ],
    ).show();
  }
   ///-----------------------------------Open Ather PAge----------------------//
  void openEditPageCoupon({BuildContext context,String price,String start,String end,String chaletId,String chaletName})
  {
    Navigator.push(
        context, SizeRoute(page: PageCoupon(chaletId: chaletId,chaletName: chaletName,endDate: end,startDate: start,totalPrice: price,)));
  }

  void openConfirmationPageBank({BuildContext context,SuccessReservationModel m})
  {
    //ReservationConfirmationPage
    Navigator.pushReplacement(
        context, SizeRoute(page:  ReservationPaymentPageBank(m: m,)));
  }

}