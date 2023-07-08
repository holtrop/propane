import testparser;
import std.stdio;
import json_types;

int main()
{
    return 0;
}

unittest
{
    string input = ``;
    auto parser = new Testparser.Parser(input);
    assert(parser.parse() == Testparser.Parser.P_SUCCESS);

    input = `{}`;
    parser = new Testparser.Parser(input);
    assert(parser.parse() == Testparser.Parser.P_SUCCESS);
    assert(cast(JSONObject)parser.result);

    input = `[]`;
    parser = new Testparser.Parser(input);
    assert(parser.parse() == Testparser.Parser.P_SUCCESS);
    assert(cast(JSONArray)parser.result);

    input = `-45.6`;
    parser = new Testparser.Parser(input);
    assert(parser.parse() == Testparser.Parser.P_SUCCESS);
    assert(cast(JSONNumber)parser.result);
    assert((cast(JSONNumber)parser.result).value == -45.6);

    input = `2E-2`;
    parser = new Testparser.Parser(input);
    assert(parser.parse() == Testparser.Parser.P_SUCCESS);
    assert(cast(JSONNumber)parser.result);
    assert((cast(JSONNumber)parser.result).value == 0.02);

    input = `{"hi":true}`;
    parser = new Testparser.Parser(input);
    assert(parser.parse() == Testparser.Parser.P_SUCCESS);
    assert(cast(JSONObject)parser.result);
    JSONObject o = cast(JSONObject)parser.result;
    assert(o.value["hi"]);
    assert(cast(JSONTrue)o.value["hi"]);

    input = `{"ff": false, "nn": null}`;
    parser = new Testparser.Parser(input);
    assert(parser.parse() == Testparser.Parser.P_SUCCESS);
    assert(cast(JSONObject)parser.result);
    o = cast(JSONObject)parser.result;
    assert(o.value["ff"]);
    assert(cast(JSONFalse)o.value["ff"]);
    assert(o.value["nn"]);
    assert(cast(JSONNull)o.value["nn"]);
}
