import 'dart:async';

import 'package:toast/toast.dart';
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
import 'package:vacatiion/model/AllChaletsAndOffersModel.dart';
import 'package:vacatiion/model/BannerModel.dart';
import 'package:vacatiion/pages/SubPages/OffersPage.dart';
import 'package:vacatiion/utility/api_utilites.dart';
import 'package:vacatiion/utility/utility_class.dart';
import 'dart:convert';
import 'dart:core' as prefix0;
import 'dart:core';
import 'dart:io';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'dart:io';


class ScopedModelBannerUser extends Model
{
  static bool loadingHomePage=false;

  ///-------------------------------------------------------- StreamController Chalet -------------------------------------------//
  StreamController<BannerModel>  streamControllerUserBanner;
  //----------Start stream-----------//
  initialStreamControllerBanner()
  {
    streamControllerUserBanner=StreamController<BannerModel>.broadcast();
  }
  //---------------------- Input and Output Stream Get All Chalet ----------------------//
  Stream <BannerModel>  get outAllImagesBanner => streamControllerUserBanner.stream;
  Sink<BannerModel>  get inPutImagesBanner => streamControllerUserBanner.sink;
  //----------Stop stream----------//
  void disposeStreamControllerBanner()
  {
    streamControllerUserBanner.close();
  }




  //-----------Get All Data by Token---------------//
  String _apiGetImagesBanner=ApiUtilities.baseApi+ApiUtilities.bannerApi;



  //-------------- Loading Home PAGE ----------------//
  showLoadingHomePage()
  {
    loadingHomePage=true;
    notifyListeners();
  }
  stopLoadingHomePage()
  {
    loadingHomePage=false;
    notifyListeners();
  }




  Future getAllBanners({BuildContext context}) async {


   // SharedPreferences prefs = await SharedPreferences.getInstance();
    //---- var token = prefs.getString(Utility.TOKEN);

    final response =
    await http.get(_apiGetImagesBanner, headers: {"Accept": "application/json"});

    var   data  =json.decode(response.body);

     print("============================PRint------${data.toString()}----------------------");
    ///========================================= Check the Status Response (SUCCESS)====================================//
    if(data['status']==Utility.VERIFICATION_CODE_SUCCESS)
    {


      inPutImagesBanner.add(BannerModel.fromJson(data));
      print("-------------------------Test Banner----------------${BannerModel.fromJson(data).data.length}");
      stopLoadingHomePage();
    }
    ///========================================= Check the Status Response (FAILED)====================================//
    else if(data['status']==Utility.VERIFICATION_CODE_FAILED)
    {


      stopLoadingHomePage();
      //------------Shaw Dialog ---------------//
      //shawAlertDialog(context: context,msg:error.error[0]);
    }else
    {
      stopLoadingHomePage();
      print("=========================== VERIFICATION_CODE Not compatible with schema${data["message"]} =======================");
      if(data["message"]=="Unauthenticated.")
      {
        shawAlertDialogLogin(context: context,msg: "برجاء تسجيل الدخول",title:data["message"]);
      }

    }




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
}