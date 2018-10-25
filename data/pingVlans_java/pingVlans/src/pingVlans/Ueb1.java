package pingVlans;

public class Ueb1 {

	private String name;
	private int alter;
	
	
	void setName(String pName) {
		name = pName;
	}

	String getName() {
		return name;
	}

	public Ueb1 getInstance() {
		return this;  //hier wird kein prim. Datentyp zurückgegeben sondern das Objekt der Klasse "Ueb1"
	}
	
	public Ueb1 getNeueKlasse() {
		return new Ueb1();    //hier wird ein neues Objekt der Klasse "Ueb1" durch ein bereits vorhandenes 
		 					  // Objekt der Klasse "Ueb1" erzeugt und zurückgegeben 
	}
	
	
}
