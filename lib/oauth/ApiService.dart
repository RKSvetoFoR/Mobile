import 'package:dio/dio.dart';
import 'BearerInterceptor.dart';
import 'package:eios/oauth/OAuth.dart';

class ApiService {
  Dio _dio;
  OAuth _oAuth;
  static const BASE_URL = 'https://papi.mrsu.ru/';
  String token = "hello token";
  SignalR signalR;

  ApiService() {
    _dio = Dio();
    _dio.options.baseUrl = BASE_URL;
    _dio.interceptors.add(LogInterceptor(responseBody: true));

    _oAuth = OAuth(
        tokenUrl: 'https://p.mrsu.ru/OAuth/Token',
        clientId: '8',
        clientSecret: 'qweasd',
        storage: OAuthSecureStorage(),
        dio: _dio);

    _dio.interceptors.add(BearerInterceptor(_dio, _oAuth));
  }


  Future<void> login(String user, String password) async {
    await _oAuth.storage.clear();
    await _oAuth.requestToken(
        grantType: 'password', username: user, password: password);

    this.token = await _oAuth.storage.storage.read(key: _oAuth.storage.accessTokenKey);
// print(
// await _oAuth.storage.storage.read(key: _oAuth.storage.accessTokenKey));
  }


  Future<String> getToken() async {
    return await _oAuth.storage.storage.read(key: _oAuth.storage.accessTokenKey);
  }

  Future<void> loadAndSaveRole() async {
    print("test");
    Response result = await _dio.get("v1/User");
    final roleName = Role
        .fromJson(result.data)
        .role;
    await _oAuth.storage.saveRole(roleName);
//final pushToken = await PushNotificationsManager().init();
//print(pushToken);
//await _oAuth.storage.savePushToken(pushToken);
  }

  Future<void> logout() async {
    Map<String, String> header = {
      "Authorization" : "Bearer " + await getToken()
    };
    signalR = SignalR(
        'https://p.mrsu.ru',
        "chatHub",
        headers: header,
        hubMethods: ["GetConversations"],
        statusChangeCallback: (status) => print(status),
        hubCallback: _onNewMessage
    );

    final isConnected = await signalR.isConnected;
    if (isConnected) {
      signalR.stop();
    }
    await _oAuth.storage.clear();
  }

  Future<String> getRole() async {
    return _oAuth.storage.getRole();
  }

  Future<String> getPushToken() async {
    return _oAuth.storage.getPushToken();
  }

  Future<User> getUserData() async {
    Response result = await _dio.get("v1/User");
    print(result.data);
    var user = User.fromJson(result.data);
    return user;
  }


  _onNewMessage(String methodName, dynamic message) {
    print('MethodName = $methodName, Message = $message');
  }

  Future<void> postMark(List<Map<String, String>> data) async{
    await _dio.post("v1/TeacherControlDotMark", data: data);
  }

  Future<void> postProfile(Map<String, dynamic> data, String code) async{
    await _dio.post("v1/Questionnaire?code=" + code, data: data);
  }

  Future<Info> getInfoDiscipline(int id) async{
    Response result = await _dio.get('v1/Discipline/' + id.toString());
    final info = Info.fromJson(result.data);
    return info;
  }

  Future<StudentInfo> getStudentInfo() async{
    Response result = await _dio.get('v1/StudentInfo');
    final info = StudentInfo.fromJson(result.data);
    print(info.info);
    return info;
  }

  Future<List<Pool>> getListPools() async{
    Response result = await _dio.get('v1/PoolProfileForPass');
    final list = ListPools.fromJson(result.data);
    return list.pools;
  }

  Future<List<Test>> getListActualTests() async{
    Response result = await _dio.get('v1/TestProfileForPass?archive=false');
    final list = ListTests.fromJson(result.data);
    return list.tests;
  }

  Future<List<Test>> getListArchiveTests() async{
    Response result = await _dio.get('v1/TestProfileForPass?archive=true');
    final list = ListTests.fromJson(result.data);
    return list.tests;
  }

  Future<void> putAnswer(Map<String, dynamic> data) async{
    await _dio.put("v1/SessionQuestion", data: data);
  }

  Future<ResultTest> endTest(int id) async {
    Response result = await _dio.post("v1/TestPoolResult?sessionId=" + id.toString());
    var data = ResultTest.fromJson(result.data);
    return data;
  }

  Future<Session> postTestSession(int profileId) async{
    Response result = await _dio.post("v1/Session?profileId=" + profileId.toString());
    var session = Session.fromJson(result.data);
    return session;
  }

  Future<SessionInfo> getTestSessionInfo(int sessionId) async {
    Response testData = await _dio.get("v1/TestPoolResult?sessionId=" + sessionId.toString());
    var result = SessionInfo.fromJson(testData.data);
    return result;
  }

  Future<List<Niokr>> getNiokrs() async{
    Response result = await _dio.get('v1/NIOKR');
    final list = ListNiokr.fromJson(result.data);
    return list.niokrs;
  }

  Future<Niokr> getNiokr(int id) async{
    Response result = await _dio.get('v1/NIOKR/' + id.toString());
    final niokr = Niokr.fromJson(result.data);
    return niokr;
  }

  Future<List<Grant>> getGrants() async{
    Response result = await _dio.get('v1/Grant');
    final list = ListGrant.fromJson(result.data);
    return list.grants;
  }

  Future<Grant> getGrant(int id) async{
    Response result = await _dio.get('v1/Grant/' + id.toString());
    final grant = Grant.fromJson(result.data);
    return grant;
  }

  Future<List<Patent>> getPatents() async{
    Response result = await _dio.get('v1/Patent');
    final list = ListPatent.fromJson(result.data);
    return list.patents;
  }

  Future<Patent> getPatent(int id) async{
    Response result = await _dio.get('v1/Patent/' + id.toString());
    final grant = Patent.fromJson(result.data);
    return grant;
  }

  Future<List<Publication>> getPublications() async{
    Response result = await _dio.get('v1/Publication');
    final list = ListPublication.fromJson(result.data);
    return list.publications;
  }

  Future<Publication> getPublication(int id) async{
    Response result = await _dio.get('v1/Publication/' + id.toString());
    final public = Publication.fromJson(result.data);
    return public;
  }

  Future<DocumentsEducationStudent> getDocumentsEducationStudent() async{
    Response result = await _dio.get('v1/UserEducation');
    final documents = DocumentsEducationStudent.fromJson(result.data);
    return documents;
  }

  Future<DocumentsEducationTeacher> getDocumentsEducationTeacher() async{
    Response result = await _dio.get('v1/UserEducation');
    final documents = DocumentsEducationTeacher.fromJson(result.data);
    return documents;
  }

  Future<List<Reference>> getReferences() async{
    Response result = await _dio.get('v1/ReferenceId');
    final references = References.fromJson(result.data);
    return references.references;
  }

  Future<List<SentReference>> getSentReferences() async{
    Response result = await _dio.get('v1/Reference');
    final references = ListSentReference.fromJson(result.data);
    return references.references;
  }

  Future<void> postReference(Map<String, dynamic> data) async{
    await _dio.post("v1/Reference", data: data);
  }

  Future<Profile> getQuestionnaire(String code) async{
    Response result = await _dio.get('v1/Questionnaire?code=' + code);
    if (result.data == null) {
      var map = {
        "ПроцентЗаполненности": 0.0,
        "Согласие": false,
        "ДиаспораДаНет": false,
        "ВыпускающаяКафедра": null,
        "КодСпециальности": null,
        "СНИЛСДаНет": false,
        "СНИЛС": null,
        "ИнвалидностьДаНет": false,
        "ГруппаИнвалидности": null,
        "СреднийБалл": 0.0,
        "ЦелевойПриемДаНет": false,
        "ЦелевоеПредприятие": null,
        "ДипломТема": null,
        "ДипломПредприятие": null,
        "Достижения": null,
        "ТрудоустройствоПродолжитОбучениеДаНет": false,
        "ТрудоустройствоПродолжениеОбучения": null,
        "ТрудоустройствоПродолжениеОбученияДругое": null,
        "ТрудоустройствоПродолжениеОбученияВуз": null,
        "ТрудоустройствоПродолжениеОбученияФакультет": null,
        "ТрудоустройствоТрудоустроенДаНет": false,
        "ТрудоустройствоТрудоустроенПоСпециальностиДаНет": false,
        "ТрудоустройствоТрудоустроенРегион": null,
        "ТрудоустройствоТрудоустроенГород": null,
        "ТрудоустройствоТрудоустроенМесто": null,
        "ТрудоустройствоТрудоустроенДолжность": null,
        "ТрудоустройствоОпределилсяСРаботойДаНет": false,
        "ТрудоустройствоОпределилсяСРаботойСфераДеятельности": null,
        "ТрудоустройствоОпределилсяСРаботойСфераДеятельностиДругое": null,
        "ТрудоустройствоОпределилсяСРаботойПредпМестоРаботы": null,
        "ТрудоустройствоСвоеДелоДаНет": false,
        "ТрудоустройствоСвоеДелоКомментарий": null,
        "ТрудоустройствоАрмияДаНет": false,
        "ТрудоустройствоОтпускПоУходуЗаРебенкомДаНет": false,
        "ТрудоустройствоНеОпределилсяСРаботойДаНет": false,
        "ТрудоустройствоИностранныйГражданинДаНет": false,
        "ОпытРаботыДаНет": false,
        "ОпытРаботы": null,
        "ТелефонДомашний": null,
        "ТелефонМобильный": null,
        "ЭлектроннаяПочта": null,
        "МониторингИнформацияПолученаДаНет": false,
        "МониторингИнформацияПолученаИнформация": null,
        "МониторингОтправилиВакансииДаНет": false,
        "МониторингНеДозвонилисьДаНет": false,
        "Примечание": null
      };

      return Profile(map, false);
    }
    else {
      final profile = Profile.fromJson(result.data);
      return profile;
    }
  }

  Future<Question> getQuestion(int id) async{
    print(id);
    Response result = await _dio.get('v1/SessionQuestion/' + id.toString());
    final question = Question.fromJson(result.data);
    return question;
  }

// Future<List<Future<Question>>> getTest() async{
// Response result = await _dio.get('/TestSession/1567820');
// var questionsId = await result.data['SessionQuestionsId'];
// var test = (questionsId as List).map(
// (e) async{
// Response resultQuestion = await _dio.get('/SessionQuestion/' + e.toString());
// final question = Question.fromJson(resultQuestion.data);
// return question;
// }
// ).toList();
// //var test = questionsId.map((questionId) => questionId).toList;
// print(test);
// return test;
// }

  Future<List<Debt>> getDebts() async{
    Response result = await _dio.get('v1/Debts');
    final debts = ListDebt.fromJson(result.data);
    return debts.debts;
  }

  Future<List<News>> getNews() async{
    Response result = await _dio.get('v1/News');
    final listNews = ListNews.fromJson(result.data);
    return listNews.news;
  }

  Future<List<Events>> getEvents(String date) async{
    Response result = await _dio.get('v1/Events?date=' + date);
    final events = Events.fromJson(result.data);
    return events.events;
  }

  Future<Event> getEvent(int id) async{
    Response result = await _dio.get('v1/Event?eventid=' + id.toString());
    final event = Event.fromJson(result.data);
    return event;
  }

  Future<List<Events>> getAllEvents() async{
    Response result = await _dio.get('v1/Events');
    final events = Events.fromJson(result.data);
    return events.events;
  }

  Future<Events> getMyEvents() async{
    final events = List<Events>();
    Response result;

    result = await _dio.get('v1/Events?mode=0');
    if(Events.fromJson(result.data).events.length != 0)
      events.add(Events(0, "Созданные события", "", "", Events.fromJson(result.data).events));
    result = await _dio.get('v1/Events?mode=1');
    if(Events.fromJson(result.data).events.length != 0)
      events.add(Events(0, "Подписки", "", "", Events.fromJson(result.data).events));
    result = await _dio.get('v1/Events?mode=2');
    if(Events.fromJson(result.data).events.length != 0)
      events.add(Events(0, "Ответственные события", "", "", Events.fromJson(result.data).events));

    return Events(0,"", "", "", events);
  }

  Future<ListFilters> getFilter() async {
    final role = await getRole();
    Response result;
    if (role == 'students')
      result = await _dio.get('v1/StudentSemester');
    else if (role == 'teachers')
      result = await _dio.get("v1/TeacherSemester");
    final filters = ListFilters.fromJson(result.data);
    return filters;
  }

  Future<Faculties> getDisciplineList(String year, int period) async {
    final role = await getRole();
    Response result;
    if (role == 'students') {
      if (period == -1)
        result = await _dio.get("v1/StudentSemester?selector=current");
      else
        result = await _dio.get("v1/StudentSemester?year=" + year +
            "&period=" + period.toString());
    }
    else if (role == 'teachers'){
      if (period == -1)
        result = await _dio.get("v1/TeacherSemester?selector=current");
      else
        result = await _dio.get("v1/TeacherSemester?year=" + year +
            "&period=" + period.toString());
    }

    final faculties = Faculties.fromJson(result.data, role);
    return faculties;
  }

  Future<TableStudent> getRatingPlanStudent(int id) async {
    Response result = await _dio.get("v1/StudentRatingPlan/" + id.toString());
    final table = TableStudent.fromJson(result.data);
    return table;
  }

  Future<ListSection> getRatingPlanTeacher(int id) async {
    Response result = await _dio.get("v1/TeacherRatingPlan/" + id.toString());
    final sections = ListSection.fromJson(result.data);
    return sections;
  }

  Future<ListStudent> getStudentList(int id, String group) async {
    Response result = await _dio.get("v1/TeacherControlDotMark?controlDotId=" +
        id.toString() + "&group=" + group);
    final students = ListStudent.fromJson(result.data);
    return students;
  }

  Future<List<Word>> getNationality() async {
    Response result = await _dio.get("v1/Abiturs?DirectoryName=nationalities");
    final list = Directory.fromJson(result.data);
    return list.list;
  }

  Future<List<Word>> getCitizenships() async {
    Response result = await _dio.get("v1/Abiturs?DirectoryName=citizenships");
    final list = Directory.fromJson(result.data);
    return list.list;
  }

  Future<List<Word>> getDocuments() async {
    Response result = await _dio.get("v1/Abiturs?DirectoryName=documents");
    final list = Directory.fromJson(result.data);
    return list.list;
  }

  Future<List<Word>> getTypesEducation() async {
    Response result = await _dio.get("v1/Abiturs?DirectoryName=typesofeducation");
    final list = Directory.fromJson(result.data);
    return list.list;
  }

  Future<List<Word>> getTypesSchool(String id) async {
    Response result = await _dio.get("v1/Abiturs?TypeOfEducationId=" + id);
    final list = Directory.fromJson(result.data);
    return list.list;
  }

  Future<List<Word>> getListSchool(String id) async {
    Response result = await _dio.get("v1/Abiturs?TypeOfInstitutId=" + id);
    final list = Directory.fromJson(result.data);
    return list.list;
  }

  Future<List<Word>> getConfirmationDocument(String id) async {
    Response result = await _dio.get("v1/Abiturs?TypeOfEducationForDocId=" + id);
    final list = Directory.fromJson(result.data);
    return list.list;
  }

  Future<List<Word>> getLangs() async {
    Response result = await _dio.get("v1/Abiturs?DirectoryName=langs");
    final list = Directory.fromJson(result.data);
    return list.list;
  }

  Future<List<Word>> getExams() async {
    Response result = await _dio.get("v1/Abiturs?DirectoryName=exams");
    final list = Directory.fromJson(result.data);
    return list.list;
  }

  Future<List<Word>> getCampaigns() async {
    Response result = await _dio.get("v1/Abiturs?DirectoryName=campaigns");
    final list = Directory.fromJson(result.data);
    return list.list;
  }

  Future<List<Word>> getFaculties(String id) async {
    Response result = await _dio.get("v1/Abiturs?CampaignId=" + id);
    final list = Directory.fromJson(result.data);
    return list.list;
  }

  Future<List<Word>> getDirections(String idCampany, String idFaculties) async {
    Response result = await _dio.get("v1/Abiturs?CampaignId=" + idCampany + "&FacultyId=" + idFaculties);
    final list = Directory.fromJson(result.data);
    return list.list;
  }

  Future<List<Word>> getFormsEducation(String idCampany, String idFaculties, String idDirect) async {
    Response result = await _dio.get("v1/Abiturs?CampaignId=" + idCampany + "&FacultyId="
        + idFaculties + "&SpecId=" + idDirect);
    final list = Directory.fromJson(result.data);
    return list.list;
  }

  Future<List<Word>> getGrounds(String idCampany, String idFaculties,
      String idDirect, String idForm) async {
    Response result = await _dio.get("v1/Abiturs?CampaignId=" + idCampany + "&FacultyId="
        + idFaculties + "&SpecId=" + idDirect + "&FormId=" + idForm + "&Foreign=false");
    final list = Directory.fromJson(result.data);
    return list.list;
  }

  Future<List<Word>> getCategories() async {
    Response result = await _dio.get("v1/Abiturs?DirectoryName=categories");
    final list = Directory.fromJson(result.data);
    return list.list;
  }

  Future<void> postApplicant(Map<String, dynamic> data) async{
    await _dio.post("v1/Abiturs", data: data);
  }

  Future<bool> getGroupTeacher() async {
    Response result = await _dio.get("v1/User");
    var check = false;
    for (var e in result.data['Roles']) {
      if (e['Name'] == "Дирекция развития МГУ") check = true;
    }
    return check;
  }

  Future<String> getPaymentUrl(String paymentId, String amount) async {
    Response result = await _dio.get("v1/Pay/" + paymentId + "?amount=" + amount);
    return Payment.fromJson(result.data).formUrl;
  }

  Future<String> getSentStatusPayment(String url) async {
    await _dio.get("v1/Pay/" + url);
  }

  Future<void> postCode(String code) async {
    await _dio.post("v1/StudentAttendanceCode?code=" + code);
  }

  Future<ListStudent> getAttendanceList(int id) async{
    Response result = await _dio.get("v1/TeacherAttendance/" + id.toString());
    if (result.data.length == 0) return ListStudent([]);
    final idTask = result.data.first['Id'];
    result = await _dio.get("v1/TeacherAttendanceMark/" + idTask.toString() + "?gr=403");
    final list = await ListStudent.fromJson(result.data);
    return list;
  }

  Future<void> postAttendance(List<Map<String, dynamic>> data) async{
    print(data);
    await _dio.post("v1/TeacherAttendanceMark", data: data);
  }

  Future<void> postNotification(Map<String, dynamic> data) async{
    await _dio.post("v1/Notification", data: data);
  }

  Future<void> deleteNotification(Map<String, dynamic> data) async{
    await _dio.delete("v1/Notification", data: data);
  }

  Future<List<Turnstiles>> getTurnstiles(String date) async{
    Response result = await _dio.get('v1/Security?date=' + date);
    final turnstiles = Turnstiles.fromJson(result.data);
    return turnstiles.turnstiles;
  }

  Future<ListForumMessages> getForum(String disciplineId) async {
    Response result = await _dio.get('v1/ForumMessage?disciplineId=${disciplineId}');
    final forumMessage = ListForumMessages.fromJson(result.data);
    return forumMessage;
  }

  Future<void> deleteForumMessage(String messageId) async {
    await _dio.delete('v1/ForumMessage/${messageId}');
  }

  Future<void> postForumMessage(String disciplineId, String msg) async {
    var message = {
      "text" : msg
    };
    await _dio.post('v1/ForumMessage?disciplineId=${disciplineId}', data: message);
  }

  Future<ListResults> getTestPoolResult(int profileId) async {
    Response result = await _dio.get('v1/TestPoolResult?profileId=$profileId');
    final testsAndPoolsResult = ListResults.fromJson(result.data);
    return testsAndPoolsResult;
  }

  Future<ListSection> getV2TeacherRatingPlan(int disciplineId) async {
    Response result = await _dio.get('v2/TeacherRatingPlan/$disciplineId');
    final testsAndPoolsResult = ListSection.fromJson(result.data);
    return testsAndPoolsResult;
  }

  Future<RatingPlan> getV2StudentRatingPlanForTeacher(String disciplineId, String studentId) async {
    Response result = await _dio.get('v2/StudentRatingPlan?disciplineId=$disciplineId&studentId=$studentId');
    final ratingPlan = RatingPlan.fromJson(result.data);
    return ratingPlan;
  }

  Future<ListStudent> getStudentAttendanceList(int id, String group) async{
    Response result = await _dio.get("v1/TeacherAttendance/" + id.toString());
    if (result.data.length == 0) return ListStudent([]);
    final idTask = result.data.first['Id'];
    result = await _dio.get("v1/TeacherAttendanceMark/" + idTask.toString() + "?gr=${group}");
    final list = await ListStudent.fromJson(result.data);
    return list;
  }
}