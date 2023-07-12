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
    p_context_t context;
    p_context_init(&context, input);
    assert(p_parse(&context) == P_SUCCESS);

    input = `{}`;
    p_context_init(&context, input);
    assert(p_parse(&context) == P_SUCCESS);
    assert(cast(JSONObject)p_result(&context));

    input = `[]`;
    p_context_init(&context, input);
    assert(p_parse(&context) == P_SUCCESS);
    assert(cast(JSONArray)p_result(&context));

    input = `-45.6`;
    p_context_init(&context, input);
    assert(p_parse(&context) == P_SUCCESS);
    assert(cast(JSONNumber)p_result(&context));
    assert((cast(JSONNumber)p_result(&context)).value == -45.6);

    input = `2E-2`;
    p_context_init(&context, input);
    assert(p_parse(&context) == P_SUCCESS);
    assert(cast(JSONNumber)p_result(&context));
    assert((cast(JSONNumber)p_result(&context)).value == 0.02);

    input = `{"hi":true}`;
    p_context_init(&context, input);
    assert(p_parse(&context) == P_SUCCESS);
    assert(cast(JSONObject)p_result(&context));
    JSONObject o = cast(JSONObject)p_result(&context);
    assert(o.value["hi"]);
    assert(cast(JSONTrue)o.value["hi"]);

    input = `{"ff": false, "nn": null}`;
    p_context_init(&context, input);
    assert(p_parse(&context) == P_SUCCESS);
    assert(cast(JSONObject)p_result(&context));
    o = cast(JSONObject)p_result(&context);
    assert(o.value["ff"]);
    assert(cast(JSONFalse)o.value["ff"]);
    assert(o.value["nn"]);
    assert(cast(JSONNull)o.value["nn"]);
}
