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


class ScopedModelMainPageUser extends Model
{
  static bool loadingHomePage;
  static bool showhintAddCategory=true;
  static bool checkExistChalet=false;
  static int numbersOfChalets=3;
  static  bool checkExistOffers=false;
  ///-------------------------------------------------------- StreamController Chalet -------------------------------------------//
  StreamController<AllChaletsAndOffersModel>  streamControllerUserChalets;
  //----------Start stream-----------//
  initialStreamControllerChalet()
  {
    streamControllerUserChalets=StreamController<AllChaletsAndOffersModel>.broadcast();
  }
  //---------------------- Input and Output Stream Get All Chalet ----------------------//
  Stream <AllChaletsAndOffersModel>  get outAllChaletUser => streamControllerUserChalets.stream;
  Sink<AllChaletsAndOffersModel>  get inPutAllChaletUser => streamControllerUserChalets.sink;
  //----------Stop stream----------//
  void disposeStreamControllerChalet()
  {
    streamControllerUserChalets.close();
  }

  ///===================================================== StreamController Offers ============================================//
  StreamController<AllChaletsAndOffersModel>    streamControllerUserOffers;
  //---------------------- Input and Output Stream Get All Chalet ----------------------//
  Stream<AllChaletsAndOffersModel> get outAllOffersUser =>streamControllerUserOffers.stream;
  Sink<AllChaletsAndOffersModel> get inPutAllOffersUser => streamControllerUserOffers.sink;
  //----------Start stream-----------//
  initialStreamControllerOffers()
  {
    streamControllerUserOffers=StreamController<AllChaletsAndOffersModel>.broadcast();
  }
  //----------Stop stream----------//
  void disposeStreamControllerOffers()
  {
    streamControllerUserOffers.close();
  }


  //-----------Get All Data by Token---------------//
  String _apiGetAllChaletsUser=ApiUtilities.baseApi+ApiUtilities.userChalets;
  String _apiGetAllOffersUser=ApiUtilities.baseApi+ApiUtilities.userOffers;
  String _apiAddFavorites=ApiUtilities.baseApi+ApiUtilities.addFavorites;
  String _apiGitTOPFIVE=ApiUtilities.baseApi+ApiUtilities.topFiveApi;



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
  //---------------change Number Items-------------//
  changeNumberItems(int i)
  {
    numbersOfChalets=i;
    notifyListeners();
  }
  //------------------Check Chalet available-------------//
  checkExistChaletV()
  {
    checkExistChalet=true;
    notifyListeners();
  }
  checkNotExistChaletV()
  {
    checkExistChalet=false;
    notifyListeners();
  }
  //--------------------Check Offers available------------------------//
  methdcheckExistOffers()
  {
    checkExistOffers=true;
  }
  methdcheckNotExistOffers()
  {
    checkExistOffers=false;
  }



  Future getAllChaletUser({BuildContext context}) async {
    showLoadingHomePage();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString(Utility.TOKEN);
    final response =
    await http.get(_apiGetAllChaletsUser+token, headers: {"Accept": "application/json"});

    var   data  =json.decode(response.body);

    ///========================================= Check the Status Response (SUCCESS)====================================//
    if(data['status']==Utility.VERIFICATION_CODE_SUCCESS)
    {
      checkExistChaletV();
      changeNumberItems(AllChaletsAndOffersModel.fromJson(data).data.length);
      inPutAllChaletUser.add( AllChaletsAndOffersModel.fromJson(data));
      print("-------------------------Test----------------${AllChaletsAndOffersModel.fromJson(data).data.length}");
      stopLoadingHomePage();
    }
    ///========================================= Check the Status Response (FAILED)====================================//
    else if(data['status']==Utility.VERIFICATION_CODE_FAILED)
    {
      checkNotExistChaletV();
      var error =AdvertiserNoChalets.fromJson(data);
      print("============================ Get All ChALET ${error.error[0]} =================");
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

  Future getAllOffersUser({BuildContext context}) async {
    showLoadingHomePage();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString(Utility.TOKEN);
    final response =
    await http.get(_apiGetAllOffersUser+token, headers: {"Accept": "application/json"});

    var   data  =json.decode(response.body);

    ///========================================= Check the Status Response (SUCCESS)====================================//
    if(data['status']==Utility.VERIFICATION_CODE_SUCCESS)
    {
      methdcheckExistOffers();
      changeNumberItems(AllChaletsAndOffersModel.fromJson(data).data.length);
      inPutAllOffersUser.add( AllChaletsAndOffersModel.fromJson(data));
      print("-------------------------Test----------------${AllChaletsAndOffersModel.fromJson(data).data.length}");
      stopLoadingHomePage();
    }
    ///========================================= Check the Status Response (FAILED)====================================//
    else if(data['status']==Utility.VERIFICATION_CODE_FAILED)
    {
      methdcheckNotExistOffers();
      var error =AdvertiserNoChalets.fromJson(data);
      print("============================ Get All ChALET ${error.error[0]} =================");
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

  Future getAllTopFive({BuildContext context}) async {
    showLoadingHomePage();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString(Utility.TOKEN);
    final response =
    await http.get(_apiGitTOPFIVE+token, headers: {"Accept": "application/json"});

    var   data  =json.decode(response.body);

    ///========================================= Check the Status Response (SUCCESS)====================================//
    if(data['status']==Utility.VERIFICATION_CODE_SUCCESS)
    {
      methdcheckExistOffers();
      changeNumberItems(AllChaletsAndOffersModel.fromJson(data).data.length);
      inPutAllOffersUser.add( AllChaletsAndOffersModel.fromJson(data));
      print("-------------------------Test----------------${AllChaletsAndOffersModel.fromJson(data).data.length}");
      stopLoadingHomePage();
    }
    ///========================================= Check the Status Response (FAILED)====================================//
    else if(data['status']==Utility.VERIFICATION_CODE_FAILED)
    {
      methdcheckNotExistOffers();
      var error =AdvertiserNoChalets.fromJson(data);
      print("============================ Get All ChALET ${error.error[0]} =================");
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

  Future addFavorites ({String chaletId,BuildContext context})async
  {
    print("-----------------------${chaletId}--------------");
    showLoadingHomePage();
    print("------------------------------------TTTTTTTTTTTTTTTTTTTT----------------------");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString(Utility.TOKEN);
    //------------------- Send Request in Server ---------------------//
    var response = await http.post(_apiAddFavorites+token, body: {'chalet_id': "${chaletId.trim()}",});

    //------------------- Receive Response in Server ---------------------//
    var data=json.decode(response.body);


    ///========================================= Check the Status Response (SUCCESS)====================================//
    if(data['status']==Utility.VERIFICATION_CODE_SUCCESS)
    {


      Utility.showToast("تم الاضافه الى المفضله",context: context,duration:Toast.LENGTH_LONG,chooseColor: 2,gravity:Toast.BOTTOM);
      stopLoadingHomePage();
    }
    ///========================================= Check the Status Response (FAILED)====================================//
    else if(data['status']==Utility.VERIFICATION_CODE_FAILED)
    {
      Utility.showToast("تم الاضافه من قبل",context: context,duration:Toast.LENGTH_LONG,chooseColor: 1,gravity:Toast.BOTTOM);
      print("--------------${data.toString()}");
      stopLoadingHomePage();

    }



    return addFavorites;
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