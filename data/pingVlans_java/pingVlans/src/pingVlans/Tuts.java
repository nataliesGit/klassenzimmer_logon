package pingVlans;

import java.util.Random;

public class Tuts {

	public static void main(String[] hugo) {
		
//		System.out.println("test");
		
		Ueb1 uebung1 = new Ueb1();
		uebung1.setName("Julia");
		System.out.println(uebung1.getName());
		
//		Random zufallsgenerator = new Random();
		
		int gzahl = Integer.MAX_VALUE;   //Integer ist eine Wrapper Klasse, d.h. sie stattet primitive Zahlen 
										 // mit Methoden aus
		
		System.out.println(gzahl);
		
		gzahl = gzahl + 1;
		
		System.out.println(gzahl);
		
		
		float f3 = 5.0f/3;
		System.out.println(f3);
		
		System.out.println(uebung1.getInstance());
	}

}

