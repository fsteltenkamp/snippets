<?php
    function ascii_caesar_encrypt($string_to_encrypt,$key){
		$array = str_split($string_to_encrypt);
		$encrypted = "";
		for($i = 0;$i < strlen($string_to_encrypt);$i++){
			$ascii = ord($array[$i]);
			$ascii = $ascii+$key;
			$newchar = chr($ascii);
			$encrypted.= $newchar;
		}
		return $encrypted;
	}
	
	function ascii_caesar_decrypt($string_to_decrypt,$key_start = 1,$key_end = 100){
		$array = str_split($string_to_decrypt);
		$key = 0;
		for($key = $key_start; $key < $key_end; $key++){
			$decrypted = "";
			for($i = 0; $i < strlen($string_to_decrypt); $i++){
				$ascii = ord($array[$i]);
				$ascii = $ascii-$key;
				$newchar = chr($ascii);
				$decrypted.= $newchar;
			}
			echo "KEY: $key DECRYPTED STRING: $decrypted <br/>";
		}
	}
?>
