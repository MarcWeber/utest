import utest.Runner;
import utest.ui.Report;
import utest.Assert;
import utest.TestResult;


// test that PHP doesn't emit warnings
// this also catches some parse errors
#if php
class TestFinal {
	public function new(){}

	public function testThatPHPDidntEmitWarnings(){
		// test that PHP has not emitted any warnings
		var s:String = untyped __call__("ob_get_clean");
		Assert.equals("",s);
	}

}
#end

class TestAll
{
	public static function addTests(runner : Runner)
	{
		issue.TestAll.addTests(runner);
		cross.TestAll.addTests(runner);
		lang.TestAll.addTests(runner);
		platform.TestAll.addTests(runner);
		std.TestAll.addTests(runner);


#if php
		runner.addCase(new TestFinal());
#end
	}
	
	public static function main()
	{
#if php
		untyped __call__("ob_start");
#end
		var runner = new Runner();
		
		addTests(runner);
		
		Report.create(runner);

		// get test result to determine exit status
		var r:TestResult = null;
                runner.onProgress.add(function(o){ if (o.done == o.totals) r = o.result;});

		runner.run();

		php.Sys.exit(r.allOk() ? 0 : 1);

	}
}
