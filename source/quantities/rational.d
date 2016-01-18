﻿module quantities.rational;

import std.conv;
import std.math;
import std.string;
import std.traits;

package:

struct RationalImpl(I)
    if (isIntegral!I)
{
    I num = 0;
    I den = 1;

    invariant()
    {
        assert(den != 0);
    }

    this(I num, I den = 1)
    {
        this.num = num;
        this.den = den;
        normalize();
    }

    this(F)(F value, int precision = 6)
        if (isFloatingPoint!F)
    {
        immutable I coef = pow(10, precision);
        this(round(value * coef).to!I, coef);
    }

    void opOpAssign(string op)(RationalImpl!I other)
        if (op == "+" || op == "-" || op == "*" || op =="/")
    {
        mixin("this = this" ~ op ~ "other;");
    }

    void opOpAssign(string op, I)(I value)
        if (isIntegral!I && (op == "+" || op == "-" || op == "*" || op =="/"))
    {
        mixin("this = this" ~ op ~ "value;");
    }

    RationalImpl!I opUnary(string op)() const
        if (op == "+" || op == "-")
    {
        return RationalImpl!I(mixin(op ~ "num"), den);
    }
    
    RationalImpl!I opBinary(string op)(RationalImpl!I other) const
        if (op == "+" || op == "-")
    {
        auto ret = RationalImpl!I(mixin("num * other.den" ~ op ~ "other.num * den"), den * other.den);
        ret.normalize();
        return ret;
    }

    RationalImpl!I opBinary(string op)(RationalImpl!I other) const
        if (op == "*")
    {
        auto ret = RationalImpl!I(num * other.num, den * other.den);
        ret.normalize();
        return ret;
    }

    RationalImpl!I opBinary(string op)(RationalImpl!I other) const
        if (op == "/")
    {
        auto ret = RationalImpl!I(num * other.den, den * other.num);
        ret.normalize();
        return ret;
    }

    RationalImpl!I opBinary(string op, I)(I value) const
        if (isIntegral!I && (op == "+" || op == "-" || op == "*" || op == "/"))
    {
        return mixin("this" ~ op ~ "RationalImpl!I(value)");
    }
    
    bool opEquals(RationalImpl!I other) const
    {
        return num == other.num && den == other.den;
    }

    int opCmp(RationalImpl!I other) const
    {
        immutable diff = (num / cast(double) den) - (other.num / cast(double) other.den);
        if (diff == 0)
            return 0;
        if (diff > 0)
            return 1;
        return -1;
    }

    int opCmp(I)(I value) const
        if (isIntegral!I)
    {
        immutable diff = (num / cast(double) den) - value;
        if (diff == 0)
            return 0;
        if (diff > 0)
            return 1;
        return -1;
    }

    void normalize()
    {
        if (den < 0)
        {
            num = -num;
            den = -den;
        }

        immutable g = gcd(num, den);
        num /= g;
        den /= g;
    }

    string toString() const
    {
        if (den == 1)
            return "%s".format(num);
        return "%s/%s".format(num, den);
    }
}

unittest
{
    /+auto r = RationalImpl!int(6, -8);
    assert(r.toString == "-3/4");
    assert((+r).toString == "-3/4");
    assert((-r).toString == "3/4");

    r = RationalImpl!int(4, 3) + RationalImpl!int(2, 5);
    assert(r.toString == "26/15");
    r = RationalImpl!int(4, 3) - RationalImpl!int(2, 5);
    assert(r.toString == "14/15");
    r = RationalImpl!int(8, 7) * RationalImpl!int(3, -2);
    assert(r.toString == "-12/7");
    r = RationalImpl!int(8, 7) / RationalImpl!int(3, -2);
    assert(r.toString == "-16/21");

    r = RationalImpl!int(4, 3);
    r += RationalImpl!int(2, 5);
    assert(r.toString == "26/15");

    r = RationalImpl!int(8, 7);
    r /= RationalImpl!int(2, -3);
    assert(r.toString == "-12/7", r.toString);

    assert(RationalImpl!int(8, 7) == RationalImpl!int(-16, -14));
+/
    assert(RationalImpl!int(2, 5) < RationalImpl!int(3, 7));
    /+
    assert(RationalImpl!int(2.5).toString == "5/2");
    assert(RationalImpl!int(0.1250001).toString == "1/8");+/
}

private:

auto gcd(I)(I a, I b)
    if (isIntegral!I)
{
    import std.math : abs;
    
    I tmp;
    a = abs(a);
    b = abs(b);
    while (a > 0) {
        tmp = a;
        a = b % a;
        b = tmp;
    }
    return b;
}

