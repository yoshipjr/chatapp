import Firebase
import UIKit

final class FirestoreManager {

    static let shared = FirestoreManager()
    static let firestoreDb = shared.firestore
    static let auth = shared.auth
    private init() {}

    private let firestore = Firestore.firestore()
    private let auth = Auth.auth()

    enum result {
        case success
        case failure(Error)
    }

    func createUser(data: [String: Any], completion: @escaping (Result<String, Error>) -> Void) {
        firestore.collection("users").addDocument(data: data) { (error) in
            if let error = error {
                print("ユーザ情報の保存に失敗しました\(error)")
                completion(.failure(error))
                return
            }
            completion(.success("成功"))
        }
    }

    func fetchLoginUserInfo(completion: @escaping (Result<User,Error>) -> Void) {
        guard let uid = auth.currentUser?.uid else { return }
        firestore.collection("users").document(uid).getDocument { (snapshot, error) in
            if let error = error {
                print("ユーザー情報の取得に失敗しました。\(error)")
                completion(.failure(error))
            }

            guard
                let snapshot = snapshot,
                let data = snapshot.data() else
            {
                return
            }

            let user = User(dic: data)
            completion(.success(user))
        }
    }

    func fetchChataRoomsInfoFromFirestore(completion: @escaping (Result<User, Error>) -> Void) {
        firestore.collection("chatRooms").getDocuments { (snapshots, err) in
            if let err = err {
                print("ChatRooms情報の取得に失敗しました。\(err)")
                return
            }

            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                let chatroom = ChatRoom(dic: dic)

                guard let uid = Auth.auth().currentUser?.uid else { return }
                chatroom.memebers.forEach { (memberUid) in
                    guard memberUid != uid else { return }
                    self.firestore.collection("users").document(memberUid).getDocument { (snaoshot, err) in
                        if let err = err {
                            print("ユーザー情報の取得に失敗しました。\(err)")
                            completion(.failure(err))
                            return
                        }

                        guard let dic = snaoshot?.data() else { return }
                        var user = User(dic: dic)
                        user.uid = snapshot.documentID
                        completion(.success(user))
                    }
                }
            })
        }
    }

    func createUserToFirestore(email: String, password: String, userName: String, url: String, successHandler: @escaping () -> Void ) {
        auth.createUser(withEmail: email, password: password) { (response, err) in
            if let err =  err {
                print("auth情報の保存に失敗しました:", err)
                HUDManager.shared.hide()
                return
            }


            let docdata: [String : Any] = [
                "email" : email,
                "username" : userName,
                "imageUrl" : url,
                "createdAt" : Timestamp()
            ]

            guard let uid = response?.user.uid else { return }
            self.firestore.collection("users").document(uid).setData(docdata) { (err) in
                if let err = err {
                    print("データベースへの保存に失敗しました。", err)
                    HUDManager.shared.hide()
                    return
                }
                print("データベースへの保存に成功しました")
                successHandler()
            }
        }

    }

    func login(email: String, password: String, completion: @escaping (result) -> Void) {
        auth.signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                HUDManager.shared.hide()
                completion(.failure(error))
                return
            }
            HUDManager.shared.hide()
            completion(.success)
        }
    }
}


//import FirebaseCore
//
//import FirebaseFunctions
//import UserNotifications
//
//final class FirestoreManager {
//
//    // MARK: General
//
//    typealias timestamp = Timestamp
//
//    static let shared = FirestoreManager()
//    static let db = FirestoreManager().db
//
//    private let db = Firestore.firestore()
//    private let functions = Functions.functions()
//
//    private var listener: ListenerRegistration?
//    private var isFirstSubscribe: Bool = true
//
//    private init() { }
//
//    static func setupFirebase() {
//        FirebaseConfiguration.shared.setLoggerLevel(.min)
//        FirebaseApp.configure()
//    }
//    // MARK: Check In
//
//    func createUser(userId: String, userName: String, currentFcmToken: String) {
//        guard let newData = FirestoreUser(id: "",
//                                          name: userName,
//                                          fcmToken: currentFcmToken,
//                                          loggedIn: Timestamp()).toDictionary() else { return }
//        self.db.collection(FirestoreUser.collectionName).document(userId).setData(newData, merge: true) { error in
//            if let error = error {
//                CrachlyticsReporter.sendError(error)
//                print("user情報の保存に失敗しました。\(error)")
//            }
//        }
//    }
//
//    func createRoom(userId: String, userName: String, staffId: [String], staffName: [String]) {
//        guard let data = Room(id: "",
//                              userIds: [staffId, [userId]].flatMap { $0 },
//                              userNames: [staffName, [userId]].flatMap { $0 },
//                              lastMessage: "",
//                              lastMessageUserName: "",
//                              iconURLString: "",
//                              isCalled: false,
//                              peerID: "",
//                              createdAt: Timestamp(),
//                              updatedAt: Timestamp(),
//
//checkedOut: false).toDictionary() else { return }
//        db.collection(Room.collectionName).addDocument(data: data) { error in
//            if let error = error {
//                CrachlyticsReporter.sendError(error)
//                print("rooms情報の保存に失敗しました。\(error)")
//            }
//        }
//    }
//
//    // MARK: Check Out
//
//    func checkedOutRoom(roomId: String) {
//        db.collection(Room.collectionName).document(roomId).updateData(["checkedOut": true]) { error in
//            if let error = error {
//                CrachlyticsReporter.sendError(error)
//                print("Error updating document: \(error)")
//            }
//        }
//    }
//
//    // MARK: Room
//
//    /// Get a specific Room from Rooms
//    func getRoom(roomId: String, completion: @escaping (Room) -> Void) {
//        db.collection(Room.collectionName)
//            .document(roomId)
//            .getDocument { (snapshot, error) in
//                if let error = error {
//                    CrachlyticsReporter.sendError(error)
//                    Logger.error("Unable to get the document: \(error.localizedDescription)")
//                    return
//                }
//                guard let snapshot = snapshot, let data = snapshot.data() else { return }
//                guard let room = Room.initialize(id: snapshot.documentID, json: data) else { return }
//                completion(room)
//            }
//    }
//
//    func getRooms(handler: @escaping (Room) -> Void) {
//        db.collection(Room.collectionName).getDocuments { (querySnapshot, error) in
//            if let error = error {
//                CrachlyticsReporter.sendError(error)
//                return
//            }
//
//            guard let querySnapshot = querySnapshot else {
//                return
//            }
//
//            querySnapshot.documents.forEach { (snapshot) in
//                let data = snapshot.data()
//                guard let room = Room.initialize(id: snapshot.documentID, json: data) else {
//                    return
//                }
//
//                handler(room)
//            }
//        }
//    }
//
//    func fetchRooms(handler: @escaping (DocumentChange, Room) -> Void) {
//        db.collection(Room.collectionName).addSnapshotListener { querySnapshot, error in
//            if let error = error {
//                CrachlyticsReporter.sendError(error)
//                return
//            }
//
//            guard let querySnapshot = querySnapshot else {
//                return
//            }
//
//            querySnapshot.documentChanges.forEach { snapshot in
//                let data = snapshot.document.data()
//                guard let room = Room.initialize(id: snapshot.document.documentID, json: data) else {
//                    return
//                }
//
//                handler(snapshot, room)
//            }
//        }
//    }
//
//    // MARK: Video Chat History
//
//    func fetchCallHistory(roomId: String, handler: @escaping ([VideoChatHistory]?) -> Void) {
//        db.collection(Room.collectionName)
//            .document(roomId)
//            .collection(VideoChatHistory.collectionName)
//            .getDocuments { (querySnapshot, error) in
//                if let error = error {
//                    CrachlyticsReporter.sendError(error)
//                    Logger.error("Document does not exist: \(error)")
//                }
//                let videoChatHistorys = querySnapshot?.documents.compactMap({ (document) -> VideoChatHistory? in
//                    let data = document.data()
//                    guard let videoChatHistory = VideoChatHistory.initialize(id: document.documentID, json: data) else { return nil }
//                    return videoChatHistory
//                })
//                handler(videoChatHistorys)
//            }
//    }
//
//
//    func sendCallHistory(isOutgoingCall: Bool, isSuccessConnect: Bool, startCall: String?, roomId: String) {
//
//        guard isOutgoingCall else { return }
//
//        let callState: Int
//        let callTime: String
//
//        if isSuccessConnect {
//            guard let startCall = startCall else { return }
//            let endCall = Timestamp().dateValue().toString(with: .hourToMinute)
//            #if Client
//            callState = CallType.incomingCall.rawValue
//            callTime = "\(startCall)~\(endCall)"
//            #elseif Admin
//            callState = CallType.outgoingCall.rawValue
//            callTime = "\(startCall)~\(endCall)"
//            #endif
//        } else {
//            #if Client
//            callState = CallType.incomingMissedCall.rawValue
//            callTime = Timestamp().dateValue().toString(with: .hourToMinute)
//            #elseif Admin
//            callState = CallType.outgoingMissedCall.rawValue
//            callTime = Timestamp().dateValue().toString(with: .hourToMinute)
//            #endif
//        }
//
//        guard let data = VideoChatHistory(id: "",
//                                          callState: callState,
//                                          callTime: callTime,
//                                          callDate: Timestamp(date: Date())).toDictionary() else { return }
//
//        db.collection(Room.collectionName).document(roomId)
//            .collection(VideoChatHistory.collectionName)
//            .addDocument(data: data) { (error) in
//                if let error = error {
//                    CrachlyticsReporter.sendError(error)
//                    Logger.error("通話履歴のデータ送信に失敗しました。\(error)")
//                }
//            }
//    }
//
//    // MARK: Chat Messages
//
//    func sendGuestDefaultMessage(userId: String, userName: String, roomId: String) {
//        let nowTime = Timestamp().dateValue().toString(with: .yearToMinuteJapanese)
//        guard let data = ChatMessage(id: "",
//                                     userId: userId,
//                                     userName: userName,
//                                     type: .normal,
//                                     message: "\(nowTime)\nチェックインしました。",
//                                     isReadUserId: [],
//                                     isSent: true,
//                                     sentAt: Timestamp()).toDictionary() else { return }
//
//        db.collection(Room.collectionName).document(roomId)
//            .collection(ChatMessage.collectionName).addDocument(data: data) { error in
//                if let error = error {
//                    CrachlyticsReporter.sendError(error)
//                    print("チャットのデータ送信に失敗しました。\(error)")
//                }
//            }
//    }
//
//    func sendAdminDefaultMessage(userName: String, roomId: String) {
//        guard let data = ChatMessage(id: "",
//                                     userId: "",
//                                     userName: "master",
//                                     type: .system,
//                                     message: "\(userName)様、ようこそお越しくださいました。\nご用の際は、チャットまたはビデオ内線(7:00~19:00で利用可能)でご連絡ください。\nそれでは、ごゆるりとお楽しみください。",
//                                     isReadUserId: [],
//                                     isSent: true,
//                                     sentAt: Timestamp(date: Date() + 1)).toDictionary() else { return }
//
//        db.collection(Room.collectionName).document(roomId)
//            .collection(ChatMessage.collectionName).addDocument(data: data) { error in
//                if let error = error {
//                    CrachlyticsReporter.sendError(error)
//                    print("チャットのデータ送信に失敗しました。\(error)")
//                }
//            }
//    }
//
//    func fetchMessage(roomId: String, userId: String, handler: @escaping ([ChatMessage]) -> Void) {
//        db.collection(Room.collectionName).document(roomId)
//            .collection(ChatMessage.collectionName).addSnapshotListener() { querySnapshot, error in
//                if let error = error {
//                    CrachlyticsReporter.sendError(error)
//                    return
//                }
//                guard let querySnapshot = querySnapshot else {
//                    return
//                }
//
//                var unreadMessage: [ChatMessage] = []
//
//                for documentSnapshot in querySnapshot.documents {
//                    let messageId   = documentSnapshot.documentID
//                    let messageData = documentSnapshot.data()
//                    guard let chatMessage = ChatMessage.initialize(id: messageId, json: messageData) else {
//                        continue
//                    }
//
//                    if chatMessage.userId != userId && !chatMessage.isReadUserId.contains(userId) {
//                        unreadMessage.append(chatMessage)
//                    }
//                }
//                handler(unreadMessage)
//            }
//    }
//
//    func removeNotificationListener() {
//        if let listner = listener {
//            listner.remove()
//        }
//    }
//
//    // MARK: Video Chat
//
//    /// Change the call status
//    /// - Parameters:
//    ///   - roomId:   ID of each room
//    ///   - isCalled: calling state
//    ///   - peerId:   own peer ID
//    func updateIscalled(roomId: String, isCalled: Bool, peerId: String? = nil) {
//        db.collection(Room.collectionName)
//            .document(roomId)
//            .updateData(["isCalled": isCalled,
//                         "peerID": peerId ?? "peerId not included"]) { (error) in
//                if let error = error {
//                    CrachlyticsReporter.sendError(error)
//                    Logger.error("Error updating document: \(error.localizedDescription)")
//                }
//            }
//    }
//
//    // MARK: Push Notification
//
//    func setFcmToken(userId: String, fcmToken: String) {
//        db.collection(FirestoreUser.collectionName).document(userId).updateData(["fcmToken": fcmToken]) { error in
//            if let error = error {
//                CrachlyticsReporter.sendError(error)
//                print("Error updating document: \(error)")
//            }
//        }
//    }
//
//    func sendPushNotificationForMaster() {
//        db.collection(FirestoreUser.collectionName).document("master").getDocument { snapshot, error in
//
//            if let error = error {
//                CrachlyticsReporter.sendError(error)
//                return
//            }
//
//            guard let snapshot = snapshot else {
//                return
//            }
//
//            guard let data = snapshot.data() else { return }
//            guard let master = FirestoreUser.initialize(id: snapshot.documentID, json: data) else {
//                return
//            }
//
//            self.functions.httpsCallable("PushNotification").call(["fcmToken": [master.fcmToken],
//                                                                   "roomID": UserDefaultsUtils.getRoomId() ?? "",
//                                                                   "title": "ビデオ着信",
//                                                                   "body": "\(UserDefaultsUtils.getHouseName() ?? "")の\(UserDefaultsUtils.getGuestName() ?? "")様からの着信です",
//                                                                   "sound": "call.mp3",
//                                                                   "notificationType": "ビデオ内線"]) { result, error in
//                if let error = error {
//                    CrachlyticsReporter.sendError(error)
//                    print(error.localizedDescription)
//                }
//            }
//        }
//    }
//
//    func sendPushNotificationForAdministor(roomID: String, title: String, body: String, sound: String, notificationType: String) {
//        db.collection(Room.collectionName).document(roomID).getDocument { snapshot, error in
//
//            if let error = error {
//                CrachlyticsReporter.sendError(error)
//                return
//            }
//
//            guard let snapshot = snapshot,
//                  let data = snapshot.data(),
//                  let room = Room.initialize(id: snapshot.documentID, json: data) else {
//                return
//            }
//
//            let administorID = ["master", room.userIds[1]]
//            administorID.forEach { adminID in
//                self.db.collection(FirestoreUser.collectionName).document(adminID).getDocument { snapshot, error in
//                    if let error = error {
//                        print("Error updating document: \(error)")
//                    }
//
//                    guard let snapshot = snapshot else {
//                        return
//                    }
//
//                    guard let data = snapshot.data() else { return }
//                    guard let administor = FirestoreUser.initialize(id: snapshot.documentID, json: data) else {
//                        return
//                    }
//
//                    self.functions.httpsCallable("PushNotification").call(["fcmToken": [administor.fcmToken],
//                                                                           "roomID": UserDefaultsUtils.getRoomId() ?? "",
//                                                                           "title": title,
//                                                                           "body": body,
//                                                                           "sound": sound,
//                                                                           "notificationType": notificationType]) { result, error in
//                        if let error = error {
//                            CrachlyticsReporter.sendError(error)
//                            print(error.localizedDescription)
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//
//    func sendPushNotificationForGuest(roomID: String, title: String, body: String, sound: String, notificationType: String) {
//
//        db.collection(Room.collectionName).document(roomID).getDocument { snapshot, error in
//
//            if let error = error {
//                CrachlyticsReporter.sendError(error)
//                return
//            }
//
//            guard let snapshot = snapshot,
//                  let data = snapshot.data(),
//                  let room = Room.initialize(id: snapshot.documentID, json: data) else {
//                return
//            }
//
//            guard let userid = room.userIds.last else { return }
//
//            self.db.collection(FirestoreUser.collectionName).document(userid).getDocument { snapshot, error in
//                if let error = error {
//                    CrachlyticsReporter.sendError(error)
//                    print("Error updating document: \(error)")
//                }
//
//                guard let snapshot = snapshot,
//                      let data = snapshot.data(),
//                      let guest = FirestoreUser.initialize(id: snapshot.documentID, json: data) else {
//                    return
//                }
//
//                self.functions.httpsCallable("PushNotification").call(["fcmToken": [guest.fcmToken],
//                                                                       "roomID": UserDefaultsUtils.getRoomId() ?? "",
//                                                                       "title": title,
//                                                                       "body": body,
//                                                                       "sound": sound,
//                                                                       "notificationType": notificationType]) { result, error in
//                    if let error = error {
//                        CrachlyticsReporter.sendError(error)
//                        print(error.localizedDescription)
//                    }
//                }
//            }
//        }
//    }
//}
//
