
class Serializable<T> {

	Serializable();
	
	static Serializable fromMap(Map<String, dynamic> map) => Serializable<dynamic>();
	Map<String, dynamic> toMap() => {};
	Map<String, dynamic> toJson() => toMap();
	Map<String, dynamic> get data => toMap();
}