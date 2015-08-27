/**
 * Copyright: Copyright (c) 2011 Jacob Carlborg. All rights reserved.
 * Authors: Jacob Carlborg
 * Version: Initial created: Aug 6, 2011
 * License: $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost Software License 1.0)
 */
module tests.Slice;

import orange.serialization.Serializer;
import orange.serialization.archives.XmlArchive;
import orange.test.UnitTester;
import tests.Util;

Serializer serializer;
XmlArchive!(char) archive;

class J
{
    int[] firstSource;
    int[] firstSlice;

    int[] secondSlice;
    int[] secondSource;

    int[4] firstStaticSource;
    int[] firstStaticSlice;

    int[] firstEmpty;
    int[] secondEmpty;

    int[][] thirdEmpty;
}

J j;
J jDeserialized;

unittest
{
    archive = new XmlArchive!(char);
    serializer = new Serializer(archive);

    j = new J;
    j.firstSource = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9].dup;
    j.firstSlice = j.firstSource[3 .. 7];

    j.secondSource = [10, 11, 12, 13, 14, 15].dup;
    j.secondSlice = j.secondSource[1 .. 4];

    j.firstStaticSource = [16, 17, 18, 19];
    j.firstStaticSlice = j.firstStaticSource[1 .. 3];

    describe("serialize slices") in {
        it("should return serialized slices") in {
            auto expected = q"xml
<?xml version="1.0" encoding="UTF-8"?>
<archive version="1.0.0" type="org.dsource.orange.xml">
    <data>
        <object runtimeType="tests.Slice.J" type="tests.Slice.J" key="0" id="0">
            <array type="int" length="0" key="firstEmpty" id="36"/>
            <array type="int" length="0" key="secondEmpty" id="37"/>
            <array type="int[]" length="0" key="thirdEmpty" id="38"/>
            <slice length="3" key="secondSlice" offset="1">21</slice>
            <array type="int" length="4" key="firstStaticSource" id="28">
                <int key="0" id="29">16</int>
                <int key="1" id="30">17</int>
                <int key="2" id="31">18</int>
                <int key="3" id="32">19</int>
            </array>
            <array type="int" length="10" key="firstSource" id="1">
                <int key="0" id="2">0</int>
                <int key="1" id="3">1</int>
                <int key="2" id="4">2</int>
                <int key="3" id="5">3</int>
                <int key="4" id="6">4</int>
                <int key="5" id="7">5</int>
                <int key="6" id="8">6</int>
                <int key="7" id="9">7</int>
                <int key="8" id="10">8</int>
                <int key="9" id="11">9</int>
            </array>
            <array type="int" length="6" key="secondSource" id="21">
                <int key="0" id="22">10</int>
                <int key="1" id="23">11</int>
                <int key="2" id="24">12</int>
                <int key="3" id="25">13</int>
                <int key="4" id="26">14</int>
                <int key="5" id="27">15</int>
            </array>
            <slice length="2" key="firstStaticSlice" offset="1">28</slice>
            <slice length="4" key="firstSlice" offset="3">1</slice>
        </object>
    </data>
</archive>
xml";
            serializer.reset();
            serializer.serialize(j);

            assert(expected.equalToXml(archive.data));
        };
    };

    describe("deserialize slices") in {
        jDeserialized = serializer.deserialize!(J)(archive.untypedData);

        it("should return deserialized strings equal to the original strings") in {
            assert(j.firstSource == jDeserialized.firstSource);
            assert(j.secondSource == jDeserialized.secondSource);
        };

        it("should return deserialized slices equal to the original slices") in {
            assert(j.firstSlice == jDeserialized.firstSlice);
            assert(j.secondSlice == jDeserialized.secondSlice);
        };

        it("the slices should be equal to a slice of the original sources") in {
            assert(jDeserialized.firstSource[3 .. 7] == jDeserialized.firstSlice);
            assert(jDeserialized.secondSource[1 .. 4] == jDeserialized.secondSlice);
            assert(jDeserialized.firstStaticSource[1 .. 3] == jDeserialized.firstStaticSlice);

            assert(j.firstSource[3 .. 7] == jDeserialized.firstSlice);
            assert(j.secondSource[1 .. 4] == jDeserialized.secondSlice);
            assert(j.firstStaticSource[1 .. 3] == jDeserialized.firstStaticSlice);
        };

        it("the slices should be able to modify the sources") in {
            jDeserialized.firstSlice[0] = 55;
            jDeserialized.secondSlice[0] = 3;
            jDeserialized.firstStaticSlice[0] = 1;

            assert(jDeserialized.firstSource == [0, 1, 2, 55, 4, 5, 6, 7, 8, 9]);
            assert(jDeserialized.secondSource == [10, 3, 12, 13, 14, 15]);
            assert(jDeserialized.firstStaticSource == [16, 1, 18, 19]);
        };
    };
}
