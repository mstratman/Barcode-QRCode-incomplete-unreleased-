
var draw_qrcode = function(text, typeNumber, errorCorrectLevel) {
	document.write(create_qrcode(text, typeNumber, errorCorrectLevel) );
};

var create_qrcode = function(text, typeNumber, errorCorrectLevel, table) {

    text = "The quick brown fox jumps over the lazy dog";
	//var qr = qrcode(typeNumber || 4, errorCorrectLevel || 'M');
	var qr = qrcode(typeNumber || 4, errorCorrectLevel || 'Q');
	qr.addData(text);
	qr.make();

    var count = qr.getModuleCount();
    var modules = qr.getModules();
    var output  = '[ ';
    for (var i = 0; i < count; i++) {
        output += '[ ';
        for (var j = 0; j < count; j++) {
            output += modules[i][j] ? 1 : 0;
            output += ',';
        }
        output += ' ],';
    }
    output += ' ]';
    console.log(output);

	return qr.createTable();
	return qr.createGif();
};

var update_qrcode = function() {
	var text = document.forms[0].elements['msg'].value.
		replace(/^[\s\u3000]+|[\s\u3000]+$/g, '');
	document.getElementById('qr').innerHTML = create_qrcode(text);
};
