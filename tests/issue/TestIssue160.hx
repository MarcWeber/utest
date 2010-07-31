/**
 * ...
 * @author Franco Ponticelli
 */

package issue;

import utest.Assert;

class TestIssue160
{
	public function new();
#if known_to_fail
	
	public function testIssue()
	{
		var d = switch (true) {
			case true: try 1 catch (e:Dynamic) 2;
		}
		Assert.equals(1, d);
	}
	
	public function testIssue2()
	{
		var d = switch (true) {
			case true: try throw "" catch (e:Dynamic) 2;
		}
		Assert.equals(2, d);
	}
#end
}
