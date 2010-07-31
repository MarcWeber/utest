import utest.TestResult;

class I {

	public function new() {}


	public function result(r:TestResult, plainTextResult: String){
		// write result of test into a file so that run-test.sh can
		// read it

		// TODO output result into file
		Server.writeFile("result.txt", [ r.allOk() ? "0" : "1", plainTextResult]);
	}

}

class Server {

	static function main() {
		var ctx = new haxe.remoting.Context();
		ctx.addObject("Server", new I());
		if( haxe.remoting.HttpConnection.handleRequest(ctx) )
			return;
		// handle normal request
		neko.Lib.print("This is a remoting server !");
	}    

	public static function writeFile(path, lines:Array<String>){
		var f =neko.io.File.write(path, true);
		for (s in lines) f.writeString(s+"\n");
		f.close();
	}

}
