<?php

require_once("qrcode.php");

//---------------------------------------------------------

#print("<h4>明示的に型番を指定</h4>");

$qr = new QRCode();
// エラー訂正レベルを設定
// QR_ERROR_CORRECT_LEVEL_L : 7%
// QR_ERROR_CORRECT_LEVEL_M : 15%
// QR_ERROR_CORRECT_LEVEL_Q : 25%
// QR_ERROR_CORRECT_LEVEL_H : 30%
$qr->setErrorCorrectLevel(QR_ERROR_CORRECT_LEVEL_Q);
// 型番(大きさ)を設定
// 1～10
$qr->setTypeNumber(4);
// データ(文字列※)を設定
// ※日本語はSJIS
$qr->addData("The quick brown fox jumps over the lazy dog");
#$qr->addData("Longer text this time");
#$qr->addData('A 78+ character string needs version 2 with error correction L. Force recalculating version.');
// QRコードを作成

$qr->make();
#$qr->dumpModules();
exit;

//echo var_dump($qr->getModules());
// HTML出力
#$qr->printHTML();

$mod = $qr->modules;
$max = $qr->getModuleCount();
echo "[ ";
for ($i = 0; $i < $max; $i++) {
    echo "[ ";
    for ($j = 0; $j < $max; $j++) {
        echo $mod[$i][$j] ? 1 : 0;
        echo ",";
    }
    echo " ],";
}
echo " ]\n";

/*
$p1 = new QRPolynomial(
    array( 64, 54, 22, 38, 48, 236, 17, 236, 17, 236, 17, 236, 17, 236, 17, 236, 17, 236, 17 ),
    7
);
$p2 = new QRPolynomial(
    array( 1, 127, 122, 154, 164, 11, 68, 117 ),
    0
);
echo "--------------------\n";
$p3 = $p1->mod($p2);
echo "\n\nPolynomial: ";
echo $p3;
echo "\n";
*/


/*
$p1 = new QRPolynomial(
    array( 64, 19, 0, 236, 17, 236, 17, 236, 17, 236, 17, 236, 17, 236, 17, 236, 17, 236, 17, 236, 17, 236, 17, 236, 17, 236, 17, 236, 17, 236, 17, 236, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null ),
    18
);
$p2 = new QRPolynomial(
    array( 1, 239, 251, 183, 113, 149, 175, 199, 215, 240, 220, 73, 82, 173, 75, 32, 67, 217, 146 ),
    0
);
echo "\nPoly2: ";
echo $p1->mod($p2);
echo "\n";

$p1 = new QRPolynomial(array( 1, 68, 119, 67, 118, 220, 31, 7, 84, 92, 127, 213, 97 ));
$p2 = new QRPolynomial(array( 1, 205 ) );
echo $p1->multiply($p2);
echo "\n";

*/

//---------------------------------------------------------

#print("<h4>型番自動</h4>");

// 型番が最小となるQRコードを作成
#$qr = QRCode::getMinimumQRCode("QRコード", QR_ERROR_CORRECT_LEVEL_L);
// HTML出力
#$qr->printHTML();

?>
