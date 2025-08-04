import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_lock_flutter/executables/controllers/method_channel_controller.dart';
import 'package:app_lock_flutter/services/constant.dart';
import '../../models/application_model.dart';

class AppsController extends GetxController implements GetxService {
  SharedPreferences prefs;
  AppsController({required this.prefs});

  String? dummyPasscode;
  int? selectQuestion;
  TextEditingController typeAnswer = TextEditingController();
  TextEditingController checkAnswer = TextEditingController();
  TextEditingController searchApkText = TextEditingController();
  List<AppInfo> unLockList = [];
  List<ApplicationDataModel> searchedApps = [];
  List<ApplicationDataModel> lockList = [];
  List<String> selectLockList = [];
  bool addToAppsLoading = false;

  List<String> excludedApps = ["com.android.settings"];

  int appSearchUpdate = 1;
  int addRemoveToUnlockUpdate = 2;
  int addRemoveToUnlockUpdateSearch = 3;

  changeQuestionIndex(index) {
    selectQuestion = index;
    update();
  }

  resetAskQuetionsPage() {
    selectQuestion = null;
    typeAnswer.clear();
    checkAnswer.clear();
  }

  savePasscode(counter) {
    prefs.setString(AppConstants.setPassCode, counter);
    Get.find<MethodChannelController>().setPassword();
    log("${prefs.getString(AppConstants.setPassCode)}", name: "save passcode");
  }

  getPasscode() {
    return prefs.getString(AppConstants.setPassCode) ?? "";
  }

  removePasscode() {
    return prefs.remove(AppConstants.setPassCode);
  }

  setSplash() {
    prefs.setBool("Splash", true);
    return prefs.getBool("Splash");
  }

  getSplash() async {
    final prefs = await SharedPreferences.getInstance();
    if ((prefs.getBool("Splash")) != null) {
      return true;
    } else {
      return false;
    }
  }

  excludeApps() {
    for (var e in excludedApps) {
      unLockList.removeWhere((element) => element.packageName == e);
    }
  }

  getAppsData() async {
    unLockList = await InstalledApps.getInstalledApps();
    excludeApps();
    update();
  }

  addRemoveFromLockedAppsFromSearch(ApplicationData app) {
    addToAppsLoading = true;
    update();
    try {
      if (selectLockList.contains(app.appName)) {
        selectLockList.remove(app.appName);
        lockList.removeWhere(
            (element) => element.application!.appName == app.appName);
      } else {
        if (lockList.length < 16) {
          selectLockList.add(app.appName);
          lockList.add(
            ApplicationDataModel(
              isLocked: true,
              application: ApplicationData(
                appName: app.appName,
                icon: getAppIcon(app.appName),
                installTimeMillis: app.installTimeMillis,
                packageName: app.packageName,
                versionCode: app.versionCode,
                versionName: app.versionName,
              ),
            ),
          );
        } else {
          Fluttertoast.showToast(
              msg: "You can add only 16 apps in locked list");
        }
      }
    } catch (e) {
      log("-------$e", name: "addRemoveFromLockedAppsFromSearch");
    }
    addToAppsLoading = false;
    update();
  }

  addToLockedApps(AppInfo app, context) async {
    addToAppsLoading = true;
    update([addRemoveToUnlockUpdate]);
    try {
      if (selectLockList.contains(app.name)) {
        selectLockList.remove(app.name);
        lockList.removeWhere((em) => em.application!.appName == app.name);
        log("REMOVE: $selectLockList");
      } else {
        if (lockList.length < 16) {
          selectLockList.add(app.name);
          lockList.add(
            ApplicationDataModel(
              isLocked: true,
              application: ApplicationData(
                appName: app.name,
                icon: app.icon,
                installTimeMillis: "${app.installedTimestamp}",
                packageName: app.packageName,
                versionCode: '${app.versionCode}',
                versionName: app.versionName,
              ),
            ),
          );
          log("ADD: $selectLockList", name: "addToLockedApps");
          Get.find<MethodChannelController>().addToLockedAppsMethod();
        } else {
          Fluttertoast.showToast(
              msg: "You can add only 16 apps in locked list");
        }
      }
    } catch (e) {
      log("-------$e", name: "addToLockedApps");
    }
    prefs.setString(
        AppConstants.lockedApps, applicationDataModelToJson(lockList));
    addToAppsLoading = false;
    update([addRemoveToUnlockUpdate]);
  }

  getLockedApps() {
    try {
      lockList = applicationDataModelFromJson(
          prefs.getString(AppConstants.lockedApps) ?? '');
      selectLockList.clear();
      log('${lockList.length}', name: "STORED LIST");
      for (var e in lockList) {
        selectLockList.add(e.application!.appName);
      }
      log('${lockList.length}-$selectLockList', name: "Locked Apps");
    } catch (e) {
      log("-------$e", name: "getLockedApps");
    }

    update();
  }

  Uint8List getAppIcon(String appName) {
    return unLockList[unLockList.indexWhere((element) {
      return appName == element.name;
    })]
        .icon!;
  }

  appSearch() {
    searchedApps.clear();
    if (searchApkText.text.length > 2) {
      for (var e in unLockList) {
        if (e.name
            .toUpperCase()
            .contains(searchApkText.text.toUpperCase().trim())) {
          searchedApps.add(
            ApplicationDataModel(
              isLocked: null,
              application: ApplicationData(
                appName: e.name,
                icon: e.icon,
                installTimeMillis: "${e.installedTimestamp}",
                packageName: e.packageName,
                versionCode: '${e.versionCode}',
                versionName: e.versionName,
              ),
            ),
          );
        }
      }
      update([appSearchUpdate]);
    }
  }
}
