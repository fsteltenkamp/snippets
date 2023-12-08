<?php
	function gerade_zahlen($start=0,$end=100){
		// Gerade Zahlen lassen sich immer GLATT durch 2 Teilen. Das heißt es bleibt kein rest übrig.
		$geradezahlen = array(); //Hier kommen nacher alle Primzahlen rein.
		//Zahlen zwischen den angegebenen Start und endzahlen durchlaufen:
		for($i = $start; $i <= $end; $i++){
			// Check: Ist die Zahl $i glatt durch 2 Teilbar?
			if(($i % 2) == 0){
				//$i ist eine Gerade Zahl! also kommt sie mit ins Array.
				array_push($geradezahlen,$i); //Mit array_push() Fügen wir die Gerade Zahl $i dem Array hinzu.
			}
		}
		return $geradezahlen;
	}
	
	var_dump(gerade_zahlen());
?>
