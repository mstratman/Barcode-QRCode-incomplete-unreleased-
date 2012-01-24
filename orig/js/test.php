<?

class QRBitBuffer {
	
	var $buffer;
	var $length;
	
	function QRBitBuffer() {
		$this->buffer = array();
		$this->length = 0;
	}

	function getBuffer() {
		return $this->buffer;
	}
		
	function getLengthInBits() {
		return $this->length;
	}

	function __toString() {
		$buffer = "";
		for ($i = 0; $i < $this->getLengthInBits(); $i++) {
			$buffer .= $this->get($i)? '1' : '0';
		}
		return $buffer;
	}

	function get($index) {
		$bufIndex = floor($index / 8);
		return ( ($this->buffer[$bufIndex] >> (7 - $index % 8) ) & 1) == 1;
	}

	function put($num, $length) {

		for ($i = 0; $i < $length; $i++) {
			$this->putBit( ( ($num >> ($length - $i - 1) ) & 1) == 1);
		}
	}
	
	function putBit($bit) {
		
		$bufIndex = floor($this->length / 8);
		if (count($this->buffer) <= $bufIndex) {
			$this->buffer[] = 0;
		}
		
		if ($bit) {
			$this->buffer[$bufIndex] |= (0x80 >> ($this->length % 8) );
		}

		$this->length++;
	}
}

$qr = new QRBitBuffer();
$b = $qr->getBuffer();
for ($i = 0; $i < count($b); $i++) {
    echo $b[$i];
}
?>
