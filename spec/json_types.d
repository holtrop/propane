class JSONValue
{
}

class JSONObject : JSONValue
{
    JSONValue[string] value;

    this()
    {
    }

    this(JSONValue[string] value)
    {
        this.value = value;
    }
}

class JSONArray : JSONValue
{
    JSONValue[] value;

    this()
    {
    }

    this(JSONValue[] value)
    {
        this.value = value;
    }
}

class JSONNumber : JSONValue
{
    double value;

    this(double value)
    {
        this.value = value;
    }
}

class JSONString : JSONValue
{
    string value;

    this(string value)
    {
        this.value = value;
    }
}

class JSONTrue : JSONValue
{
}

class JSONFalse : JSONValue
{
}

class JSONNull : JSONValue
{
}
