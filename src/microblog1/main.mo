import List "mo:base/List";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Int = "mo:base/Int";
 
actor {
    public type Message = {
        text: Text;
        time: Time.Time;// the seconds from 1970-01-01 to now

 
    public type Microblog = actor {
        follow: shared(Principal) -> async ();
        follows: shared query () -> async [Principal];
        post: shared (Text) -> async ();
        posts: shared query (Time.Time) -> async [Message];
        timeline: shared (Time.Time) -> async [Message];
    };
 
    var followed : List.List<Principal> = List.nil();
 
    public shared func follow(id: Principal) : async (){
        followed := List.push(id,followed);
    };
 
    public shared query func follows() : async [Principal] {
        List.toArray(followed)
    }; 
 
    var messages : List.List<Message> = List.nil();
 
    public shared func post(text1: Text) : async () {
        let message1 = {
            text = text1;
            time = Time.now();
        };
        messages := List.push(message1,messages)
    };
 
    public shared query func posts(since: Time.Time) : async [Message] {
        var message2 : List.List<Message> = List.nil();
        
        for (msg in Iter.fromList(messages)) {
            if(msg.time >= since){
                message2 :=List.push(msg, message2);
            };
        };
        List.toArray(message2);
    };
 
    public shared func timeline(since: Time.Time) : async [Message] {
        var all : List.List<Message> = List.nil();
 
        for (id in Iter.fromList(followed)) {
            let canister : Microblog = actor(Principal.toText(id));
            let msgs = await canister.posts(since);
            for (msg in Iter.fromArray(msgs)) {
                all := List.push(msg,all);
            };
        };
 
        List.toArray(all);
    };
};
