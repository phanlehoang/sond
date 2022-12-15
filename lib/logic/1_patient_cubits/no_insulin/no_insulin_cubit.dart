// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:bloc_app/data/data_providers/patient/get_no_insulin_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bloc_app/logic/0_home_cubits/choose_patient/choose_patient_cubit.dart';
import 'package:bloc/bloc.dart';

import '../../../data/models/export.dart';

part 'no_insulin_state.dart';

MedicalTakeInsulin InitMedicalTakeInsulin() {
  return MedicalTakeInsulin(
      insulinType: InsulinType.Actrapid, time: DateTime.now(), insulinUI: 0);
}

class NoInsulinCubit extends Cubit<NoInsulinState> {
  final ChoosePatientCubit choosePatientCubit;
  StreamSubscription? choosePatientSubscription;
  NoInsulinCubit({
    required this.choosePatientCubit,
  }) : super(NoInsulinState(
          regimen: initialRegimen(),
          guide: InitMedicalTakeInsulin(),
        )) {
    monitorChoosePatientCubit();
  }
  StreamSubscription<String> monitorChoosePatientCubit() {
    NoInsulinState newState = initNoInsulinState();
    return choosePatientSubscription =
        choosePatientCubit.stream.listen((id) async {
      NoInsulinState newState2 = await getNoInsulin(id);
      emit(newState2);
    });
  }

  void getCarbonhydrate(double cho) {
    NoInsulinState newState = state.hotClone();
    newState.currentInsulin = (cho / 15).round();
    newState.guide = MedicalTakeInsulin(
      insulinType: InsulinType.Actrapid,
      time: DateTime.now(),
      insulinUI: newState.currentInsulin,
    );
    //Sau khi nhập CHO thì sẽ nhập glucose
    newState.medicalStatus = MedicalStatus.checkingGlucose;
    emit(newState);
    print(state.medicalStatus.toString() + 'cubit');
  }

  void getGuide() {
    //Thêm action tiêm insulin vào regimen
    NoInsulinState newState = state.hotClone();
    newState.guide.time = DateTime.now();
    newState.regimen.addMedicalAction(newState.guide);
    newState.medicalStatus = MedicalStatus.checkingGlucose;
    emit(newState);
    //Sau khi tiêm xong thì nhập CHO
  }

  void newStatus(MedicalStatus medicalStatus) {
    NoInsulinState newState = state.hotClone();
    newState.medicalStatus = medicalStatus;
    emit(newState);
  }

  void takeGlucose(double glucose) async {
    //Nhận kết quả glucose của bệnh nhân
    NoInsulinState newState = state.hotClone();
    MedicalCheckGlucose medicalCheckGlucose = MedicalCheckGlucose(
      time: DateTime.now(),
      glucoseUI: glucose,
    );
    newState.regimen.addMedicalAction(medicalCheckGlucose);
    if (3.9 <= glucose && glucose <= 8.3) {
      newState.notice = 'Duy trì ${newState.currentInsulin} UI Actrapid';
    } else if (8.3 <= glucose && glucose <= 11.1) {
      newState.bonusInsulin += 2;
      newState.notice =
          'Bổ sung 2 UI insulin Actrapid \n Tiêm ${newState.currentInsulin + newState.bonusInsulin} UI Actrapid';
    } else if (11.1 <= glucose) {
      newState.bonusInsulin += 4;
      newState.notice =
          'Tiêm ${newState.currentInsulin + newState.bonusInsulin} UI Actrapid';
    }
    newState.guide.insulinUI = newState.currentInsulin + newState.bonusInsulin;
    newState.medicalStatus = MedicalStatus.guidingInsulin;
    emit(newState);
    //debug
    // print(newState.medicalStatus.toString() + ' exp');
    // print('a');
    // print(state.medicalStatus.toString() + 'cubit');
  }
}
